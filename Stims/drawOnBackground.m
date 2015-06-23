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
        %check if it's the  BLACK (we'll allow for variance!)
        isBG = sum(pix);
        %isBG = 150;

        if isBG > tolerance
            newImg(x+i-1, y+j-1,:) = pix; %bump the index so the first pixel is still at (100,100)!
            
        end
    end
end


end

function isAbove = thresh(mypix)
    
    isAbove = 0;
end