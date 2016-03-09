function new_img = placeImg(img, backimg, x,y)

%This redraws img on the bkg image at point x,y in the backimg, making sure nothing falls off the 
%color spectrum or edge of the image!

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

new_img = drawOnBackground(img, backimg, x, y);
