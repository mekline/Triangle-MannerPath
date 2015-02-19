function new_img = moveImg2(img,x,y,bkg,f)

[m n p] = size(img);
big_img = ones(m + f*2 + abs(x),n + f*2 + abs(y),p)*bkg;
big_img(f + abs(x) + 1:f + abs(x) + m,f + abs(y) + 1:f + abs(y) + n,1:p) = img;
new_img = uint8(big_img(f+abs(x)+x+1:f+abs(x)+x+m,f+abs(y)+y+1:f+abs(y)+y+n,1:p));
