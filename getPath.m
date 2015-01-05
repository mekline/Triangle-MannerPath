function [x, y] = getPath(pathname,lens)

%Important points in the image (start, 'above', etc.); coded by top lh corner
points = [300 50;
    300, 200; 
    300 250; 
    300 450;
    300 650; 
    300 700; 
    0 450; 
    100 450; 
    250 450;
    300 600;
    150 550;];

switch pathname
    case 'basicOnto'
        %Let's get a (simple) straight line path to animate!
        startpos = points(1,:);
        endpos = points(8,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);%length = lens!
    case 'still'
        %Holds x and y in place, nice for testing rotation and such
        x = ones(lens,1)*200;
        y = ones(lens,1)*200;
        
    %
    %(OK, here's the real ones!)
    %
    case 'past'
        %straight path under bridge to other side
        startpos = points(1,:);
        endpos = points(6,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'above'
        %straight path to above bridge
        startpos = points(1,:);
        endpos = points(7,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'under'
        %straight path to under the bridge...
        startpos = points(1,:);
        endpos = points(4,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'to'
        %straight path to the edge of the bridge!
        startpos = points(1,:);
        endpos = points(3,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'tofar'
        %straight path to the far edge of the bridge
        startpos = points(1,:);
        endpos = points(10,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'along'
        %straight segments to and then along the bridge!
        startpos = points(1,:);
        endpos = points(11,:);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
        x = ones(lens,1)*300;
        for i=1:lens
            if (y(i) > 300) & (y(i) < 375)
                x(i) = -1.67*y(i)+800;
            elseif y(i) > 375
                x(i) = 175;
            end
        end

    case 'underup'
        %Curved path up to touch the bottom of the bridge
        startpos = points(1,:);
        endpos = points(9,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        %Ellipse equation
        a = 50;%radii
        b = 400;
        h = 250;%x center
        k = 50;%y center
        y = sqrt(b^2*(1-((x-h).^2/a^2)))+k;
    
end