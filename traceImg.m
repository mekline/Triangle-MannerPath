function new_img = traceImg(img, backimg, x,y)

%This actually just draws a dot in the center of the img, 
%again making sure nothing falls off the 
%color spectrum or edge of the image!
%x,y is the top lh corner

img = uint8(img);
backimg = uint8(backimg);

[m n p] = size(img);
[q r s] = size(backimg);

x = round(abs(x));
y = round(abs(y));

if x<1
    x = 1;
end

if y<1
    y = 1;
end


if x+m > q
    x = q-m;
end

if y+n > r
    y = r-n;
end

%Now find the midpoint, with a buffer for a little picture!

x = x + round(m/2)-2;
y = y + round(n/2)-2;

dot = ones(4,4,3)*255;

new_img = drawOnBackground(dot, backimg, x, y);