function fig = hfigure(h)

while h > 0
  
  fig	= h;
  h	= get(h, 'Parent');
  
end

end