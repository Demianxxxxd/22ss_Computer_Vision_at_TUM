%% function switch
function cv=main
cv.TIP_GUI=@TIP_GUI;
cv.find_corner=@find_corner;
cv.find_line_x=@find_line_x;
cv.find_line_y=@find_line_y;
cv.TIP_GUI=@TIP_GUI;
cv.TIP_get5rects=@TIP_get5rects;
cv.computeH=@computeH;
end

%% TIP_GUI
function [vx, vy, irx, iry, orx, ory] = TIP_GUI(im)

[ymax,xmax,~] = size(im);

imshow(im);

% innere recheck
[rx,ry] = ginput(2);

hold on;

irx = round([rx(1) rx(2) rx(2) rx(1) rx(1)]);
iry =  round([ry(1) ry(1) ry(2) ry(2) ry(1)]);
plot(irx,iry,'g'); 
hold off

while 1
  
  % vanish point，Press Enter for next step
  [vxnew,vynew,button] = ginput(1);

    if (isempty(button))
      break
    end
  vx = vxnew; vy=vynew;

  [ox,oy] = find_corner(vx,vy,irx(1),iry(1),0,0);
  orx(1) = ox;  ory(1) = oy;
  [ox,oy] = find_corner(vx,vy,irx(2),iry(2),xmax,0);
  orx(2) = ox;  ory(2) = oy;
  [ox,oy] = find_corner(vx,vy,irx(3),iry(3),xmax,ymax);
  orx(3) = ox;  ory(3) = oy;
  [ox,oy] = find_corner(vx,vy,irx(4),iry(4),0,ymax);
  orx(4) = ox;  ory(4) = oy;
  orx = round(orx);
  ory = round(ory);
 
  % draw 
  imshow(im);
  hold on;
  % irx = round([rx(1) rx(2) rx(2) rx(1) rx(1)]);
  % iry =  round([ry(1) ry(1) ry(2) ry(2) ry(1)]); code 47,48 done
  plot(irx,iry,'g'); 
  plot([vx irx(1)], [vy iry(1)], 'r-.');
  plot([orx(1) irx(1)], [ory(1) iry(1)], 'r');
  plot([vx irx(2)], [vy iry(2)], 'r-.');
  plot([orx(2) irx(2)], [ory(2) iry(2)], 'r');
  plot([vx irx(3)], [vy iry(3)], 'r-.');
  plot([orx(3) irx(3)], [ory(3) iry(3)], 'r');
  plot([vx irx(4)], [vy iry(4)], 'r-.');
  plot([orx(4) irx(4)], [ory(4) iry(4)], 'r');
  hold off;
  drawnow;
end
end
%% find_corner
function [x,y] = find_corner(vx,vy,rx,ry,limitx,limity)

y1 = limity;
x1 = find_line_x(vx,vy,rx,ry,limity);
x2 = limitx;
y2 = find_line_y(vx,vy,rx,ry,limitx);
if (sum(([vx vy]-[x1 y1]).^2) > sum(([vx vy]-[x2 y2]).^2)) % rx(1) rx(2) ry(1) ry(2)
  x = x1;
  y = y1;
else
  x = x2;
  y = y2;
end
end
%% find_line_x
function x = find_line_x(x1,y1,x2,y2,y)

m = (y1-y2)./(x1-x2);
b = y1 - m*x1;
x = (y-b)/m;
end
%% find_line_y
function y = find_line_y(x1,y1,x2,y2,x)

m = (y1-y2)./(x1-x2);
b = y1 - m*x1;
y = m*x + b;
end
%% TIP_get5rects
% expand the image so that each "face" of the box is a proper rectangle
function [big_im,big_im_alpha,vx,vy,ceilrx,ceilry,floorrx,floorry,...
    leftrx,leftry,rightrx,rightry,backrx,backry] = ...
    TIP_get5rects(im,vx,vy,irx,iry,orx,ory)
[ymax,xmax,cdepth] = size(im);
lmargin = -min(orx);
rmargin = max(orx) - xmax;
tmargin = -min(ory);
bmargin = max(ory) - ymax;
big_im = zeros([ymax+tmargin+bmargin xmax+lmargin+rmargin cdepth]);
big_im_alpha = zeros([size(big_im,1) size(big_im,2)]);
big_im(tmargin+1:end-bmargin,lmargin+1:end-rmargin,:) = im2double(im);
big_im_alpha(tmargin+1:end-bmargin,lmargin+1:end-rmargin) = 1;
% update all variables for the new image
vx = vx + lmargin;
vy = vy + tmargin;
irx = irx + lmargin;
iry = iry + tmargin;
orx = orx + lmargin;
ory = ory + tmargin;
%%%%%%%%%%%% define 5 Vierecks
% ceiling 
ceilrx = [orx(1) orx(2) irx(2) irx(1)];
ceilry = [ory(1) ory(2) iry(2) iry(1)];
if (ceilry(1) < ceilry(2))
     ceilrx(1) = round(find_line_x(vx,vy,ceilrx(1),ceilry(1),ceilry(2)));
     ceilry(1) = ceilry(2);
else
     ceilrx(2) = round(find_line_x(vx,vy,ceilrx(2),ceilry(2),ceilry(1)));
     ceilry(2) = ceilry(1);
end

% floor
floorrx = [irx(4) irx(3) orx(3) orx(4)];
floorry = [iry(4) iry(3) ory(3) ory(4)];
if (floorry(3) > floorry(4))
     floorrx(3) = round(find_line_x(vx,vy,floorrx(3),floorry(3),floorry(4)));
     floorry(3) = floorry(4);
else
     floorrx(4) = round(find_line_x(vx,vy,floorrx(4),floorry(4),floorry(3)));
     floorry(4) = floorry(3);
end

% left
leftrx = [orx(1) irx(1) irx(4) orx(4)];
leftry = [ory(1) iry(1) iry(4) ory(4)];
if (leftrx(1) < leftrx(4))
     leftry(1) = round(find_line_y(vx,vy,leftrx(1),leftry(1),leftrx(4)));
     leftrx(1) = leftrx(4);
else
     leftry(4) = round(find_line_y(vx,vy,leftrx(4),leftry(4),leftrx(1)));
     leftrx(4) = leftrx(1);
end

% right
rightrx = [irx(2) orx(2) orx(3) irx(3)];
rightry = [iry(2) ory(2) ory(3) iry(3)];
if (rightrx(2) > rightrx(3))
     rightry(2) = round(find_line_y(vx,vy,rightrx(2),rightry(2),rightrx(3)));
     rightrx(2) = rightrx(3);
else
     rightry(3) = round(find_line_y(vx,vy,rightrx(3),rightry(3),rightrx(2)));
     rightrx(3) = rightrx(2);
end

backrx = irx;
backry = iry;
end
%ComputeH
function [h, t] = computeH(s, d)
    
    s = [s(:,1:4); ones(1,4)];
    d = [d(:,1:4); ones(1,4)];
    h_33 = 1;
    syms h_11 h_12 h_13 h_21 h_22 h_23 h_31 h_32
    [a,b,c,d,e,f,g,i] = ...
    solve((h_11*s(1,1)+h_12*s(2,1)+h_13*s(3,1))/(h_31*s(1,1)+h_32*s(2,1)+h_33*s(3,1)) - d(1,1),...
          (h_11*s(1,2)+h_12*s(2,2)+h_13*s(3,2))/(h_31*s(1,2)+h_32*s(2,2)+h_33*s(3,2)) - d(1,2),...
          (h_11*s(1,3)+h_12*s(2,3)+h_13*s(3,3))/(h_31*s(1,3)+h_32*s(2,3)+h_33*s(3,3)) - d(1,3),...
          (h_11*s(1,4)+h_12*s(2,4)+h_13*s(3,4))/(h_31*s(1,4)+h_32*s(2,4)+h_33*s(3,4)) - d(1,4),...
          (h_21*s(1,1)+h_22*s(2,1)+h_23*s(3,1))/(h_31*s(1,1)+h_32*s(2,1)+h_33*s(3,1)) - d(2,1),...
          (h_21*s(1,2)+h_22*s(2,2)+h_23*s(3,2))/(h_31*s(1,2)+h_32*s(2,2)+h_33*s(3,2)) - d(2,2),...
          (h_21*s(1,3)+h_22*s(2,3)+h_23*s(3,3))/(h_31*s(1,3)+h_32*s(2,3)+h_33*s(3,3)) - d(2,3),...
          (h_21*s(1,4)+h_22*s(2,4)+h_23*s(3,4))/(h_31*s(1,4)+h_32*s(2,4)+h_33*s(3,4)) - d(2,4));            
    h = double([a,b,c; d,e,f; g,i,1]);
    t = maketform ('projective', h');
    
end