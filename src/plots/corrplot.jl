

function corrplot(z::Matrix; kwargs...)
  # Check if the matrix is square
  is_squarematrix(z) || @error "Input must be a square matrix"  

  # Generate column names
  ncols = size(z)[1]
  colnames = "C" .* (string.(1:ncols))

  corrplot(z, colnames; kwargs...)
end

"""
   corrplot(z::Matrix, colnames::Vector; 
             maskupper::Bool,
             height::Int, width::Int,
             title::String,
             xlabel::String, ylabel::String)

Generate a correlation plot given a square matrix of numbers.

# Arguments
- `z::Matrix`: square matrix
- `colnames::Vector`: vector of strings representing colnames
- `maskupper::Bool`: wether to mask upper right triangle
- `height::Int`, `width::Int`: dimension of the plot
- `xlabel::String`, `ylabel::String`: title of x & y axis
- `title::String`: title of the plot
- `color_scheme::String`: vega color scheme https://vega.github.io/vega/docs/schemes/
- `color_reverse::Bool`: reverse the order of color scheme

"""
function corrplot(z::Matrix, colnames::Vector;
                  maskupper = true,
                  height = 400, width = 400,
                  title = "Correlation Plot",
                  xlabel = "", ylabel = "",
                  color_scheme = "greenblue", color_reverse=false,
                  nan_inf_color = :red)

  # Check if matrix is square
  is_squarematrix(z) || @error "Input must be a square matrix"

  # convert Matrix of numbers to "Any" such that
  # `Inf` and `NaN` can be changed to string equivalent
  # else vega would just show "null" for those cells
  dat = convert(Array{Any}, z)

  # find all the cells with Inf and NaN in them and
  nanidx = Tuple.(findall(isnan, dat))
  infidx = Tuple.(findall(isinf, dat))



  # masking upper right triangle of square matrix
  if maskupper == true
    for i in 1:size(dat)[1]-1
      for j in i+1:size(dat)[2]
        dat[i,j] = "masked"
      end
    end
  end

  # convert NaN and Inf to equivalent string representation
  for (r,c) in nanidx
    dat[r,c]="NaN"
  end

  for (r,c) in infidx
    dat[r,c]="Inf"
  end


  # Create a DataFrame, add a new column and stack to long form
  df = DataFrame(dat, Symbol.(colnames))
  df[!, :rows] = colnames
  df = stack(df, Symbol.(colnames))


  # Plot
  plt = df |>
        @vlplot(
          x = {"variable:o", title=ylabel, sort=colnames},
          y = {"rows:o", title=xlabel, sort=colnames},
          width = width,
          height = height,
          title = title
        ) +
        @vlplot(
          :rect,
          color = { "value:q",
                    title="",
                    scale = { scheme = color_scheme, reverse = color_reverse }
                   }
         ) +
        @vlplot(
          :text,
          text = "value:n",
          color = {condition = [
                          {test = "datum['value'] < 0.5", value = :black},
                          {test = "datum['value'] == 'Inf'", value = nan_inf_color},
                          {test = "datum['value'] == 'NaN'", value = nan_inf_color},
                         ],
                   value = :white
                  }
         )

  return plt

end
