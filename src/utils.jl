

function is_squarematrix(m::Matrix)
  if size(m)[1] == size(m)[2]
    return true
  else
    return false
  end
end
