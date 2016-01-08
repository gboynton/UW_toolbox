function h = subp(nr,nc,j, spacing)
% function h = subp(nr,nc,j, spacing)


if nargin < 4,
  spacing = .04;
end;
if nargin < 3,
  % by default, create a single axes
  nr = 1; nc = 1; j = 1;
end;

if j > nr*nc, warning('subaxes index outside valid range (ncols x nrows)'); end;

sizex = 1/nc - spacing;
sizey = 1/nr - spacing;

startx = spacing/2 + 1/nc*rem(j-1,nc);      
starty = 1 + spacing/2 - 1/nr - 1/nr*floor((j-1)/nc);  

posax = [startx, starty, sizex, sizey];

if nargout > 0,
  h = axes('pos',posax);
else,
  axes('pos',posax);
end;
