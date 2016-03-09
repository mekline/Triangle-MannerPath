function [x, y] = getKBPath(box_x, box_y, lens, lenpath)

%Based on getPath! This takes in a box size and length of time, and
%generates a random bounce-around.  If you give it a multiple of 30 frames
%(seconds) it will finish its path at the end of the movie, otherwise it
%stays at the final position for the remainder.
%All transitions from 1 edge to another take 1 sec, so there will be speed
%variation.  If you don't want that, use smoothPath afterwards. 

%Possible places the point can go (upper left corner) - should be the 
%difference between your movie/img and the ken burns box.
%Right now it has all the corners and all the midpoints of the edges -
%movie seems to 'bounce' off the walls.
points = [0 box_y;
    box_x floor(box_y/2);
    box_x box_y;
    box_x 0;
    0 0;
    0 floor(box_y/2);
    floor(box_x/2) 0;
    floor(box_x/2) box_y];
 
%How many paths to go on?
segs = floor(lens/lenpath);

%Where to go? Samples without replacement, so don't have more than 8!

where = datasample(points, segs+2 , 'Replace',false);
%where = points; %debug!

x = [];
y = [];

%Make the paths!
for s=1:segs
    
    %choose the next segment
    startpos = where(s,:);
    endpos = where(s + 1,:);
    
    
    %make points along the path! Denominator means there will be 30 (lenpaths) frames
    %Have to deal with a special case: vertical or horizontal movement will
    %break the below!
    if (startpos(1) == endpos(1))
        x_i = ones(lenpath,1)*startpos(1);
    else
        x_i = startpos(1):(endpos(1)-startpos(1))/(lenpath-1):endpos(1);
    end
    if(startpos(2) == endpos(2))
        y_i = ones(lenpath,1)*startpos(2);
    else
        y_i = startpos(2):(endpos(2)-startpos(2))/(lenpath-1):endpos(2);
    end
    
    %make sure x and y are oriented the right way!
    if size(x_i,1) == 1
        x_i = transpose(x_i);
    end
    if size(y_i,1) == 1
        y_i = transpose(y_i);
    end
    
    %append
    x = [x; x_i];
    y = [y; y_i];
    

    end

end

