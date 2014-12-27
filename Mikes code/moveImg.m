function new_img = moveImg(img,x,y,bkg)

[m n p] = size(img);
big_img = ones(m+2*abs(x),n+2*abs(y),p)*bkg;
big_img(abs(x)+1:abs(x)+m,abs(y)+1:abs(y)+n,1:p) = img;
new_img = uint8(big_img(abs(x)+x+1:abs(x)+x+m,abs(y)+y+1:abs(y)+y+n,1:p));
