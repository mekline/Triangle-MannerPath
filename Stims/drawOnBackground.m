function newImg = drawOnBackground(img, backimg, x, y)

%This takes a (color) image matrix, and draws it on another, but skips replace
%if the img is [0 255 0] at that pixel.
%x, y gives the top x and y of where you'll draw the img
%tolerance lets us deal with fuzzy image boundaries!

tolerance = 140;

%How big is the img? (and how many layers?)
[q r s] = size(img);

newImg = backimg;


for i=1:q
    for j=1:r
        pix = img(i, j, :); %Get that pixel in the img
        isBG = 0; %check if it's the stupid green (we'll allow for variance!)
        refColor = [0 255 0];
        for j=1:3
        	isBG = isBG + |pix(j) - refcolor(j)| %We want to be a minimum total distance from the refcolor

        if isBG > tolerance
            newImg(x+i-1, y+j-1,:) = pix; %bump the index so the first pixel is still at (100,100)!
            
        end
    end
end


end