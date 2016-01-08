function z = lots0minima(p)

z = -.33*cos(2*pi*p.x).*cos(2*pi*p.y)+abs(p.x.^2+p.y.^2)+2;
