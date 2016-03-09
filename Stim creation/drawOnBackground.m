function newimg = drawOnBackground(img, backimg, x, y, tolerance, mycolor)

%This takes a (color) image matrix, and draws it on another, but skips replace
%if the img is near [0 255 0] at that pixel.
%x, y gives the top x and y of where you'll draw the img
%tolerance lets us deal with fuzzy image boundaries!
%use mycolor to choose an erasing color other than black

if nargin < 5
    tolerance = 75;
end

if nargin < 6
    mycolor = [0 0 0];
end

%Convert the images to doubles!
img = im2double(img)*255;
backimg = im2double(backimg)*255;


%How big is the img? (and how many layers?)
[q r s] = size(img);

%Put it on a green background for convenient masking
bigimg = zeros(size(backimg));
bigimg(:,:,1) = mycolor(1);
bigimg(:,:,2) = mycolor(2);
bigimg(:,:,3) = mycolor(3);

for i=1:q
    for j=1:r
        bigimg(x+i-1, y+j-1,:) = img(i,j,:); %bump the index so the first pixel is still at correct loc in the larger pic!
    end
end

%Split it up and make the mask!
redChan = bigimg(:,:,1);
greenChan = bigimg(:,:,2);
blueChan = bigimg(:,:,3);

%Here's a mask that = 1 wherever it's close to the target color
mymask = (redChan > mycolor(1)-tolerance) &(redChan < mycolor(1)+tolerance)...
    & (greenChan > mycolor(2)-tolerance) &(greenChan < mycolor(2)+tolerance)...
    & (blueChan > mycolor(3)-tolerance) &(blueChan < mycolor(3)+tolerance);


%In each channel, collect the correct pixels and sum!
newimg = zeros(size(backimg));
for i=1:3
    pix1 = backimg(:,:,i).*(mymask);
    pix2 = bigimg(:,:,i).*(1-mymask);
    newimg(:,:,i) = (pix1 + pix2);
end

newimg = uint8(newimg);

%newimg = uint8(mymask*255);


% for i=1:q
%     for j=1:r
%         pix = impixel(img, j, i); %Get that pixel in the img
%         %check if it's the  GREEN (we'll allow for variance!)
%         if pdist([pix; 0 255 0], 'Euclidean') < tolerance
%             newImg(x+i-1, y+j-1,:) = pix; %bump the index so the first pixel is still at correct loc in the larger pic!
%             
%         end
%     end
% end


end