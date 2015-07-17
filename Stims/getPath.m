function [x, y, lens, bridgeFront] = getPath(pathname)

%Important points in the image (start, 'above', etc.); coded by top lh corner
points = [300 50; %starting position
    300 200; 
    300 250; %'to' final pos
    300 450; %under
    300 650; %'past' final pos
    300 700; 
    50 450; 
    100 450; %'onto' final pos
    250 450;
    300 600;
    150 550;
    300 300;
    450 600; %'underfar' final pos
    450 400; %Bottom, centered-ish under bridge
    450 50; %Below starting pos
    375 500]; %slightly less down, past centered under bridge; 
switch pathname
    case 'basicOnto'
        %Let's get a (simple) straight line path to animate!
        lens = 120;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(8,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);%length = lens!
    case 'still'
        lens = 120;
        bridgeFront = zeros(lens, 1);
        %Holds x and y in place, nice for testing rotation and such
        x = ones(lens,1)*200;
        y = ones(lens,1)*200;
        
    %
    % Control (still!) paths in different locations
    %
    
    case 'control1' %In starting position
        lens = 120;
        x = ones(lens,1)*points(1,1);
        y = ones(lens,1)*points(1,2);
        bridgeFront = zeros(lens, 1);
        
    case 'control2' %In 'underfar' final pos
        lens = 120;
        x = ones(lens,1)*points(13,1);
        y = ones(lens,1)*points(13,2);
        bridgeFront = zeros(lens, 1);
        
    case 'control3' %In 'past' final pos
        lens = 120;
        x = ones(lens,1)*points(5,1);
        y = ones(lens,1)*points(5,2);
        bridgeFront = zeros(lens, 1);
        
    case 'control4' %In a newly created final pos
        lens = 120;
        x = ones(lens,1)*points(14,1);
        y = ones(lens,1)*points(14,2);
        bridgeFront = zeros(lens, 1);
        
    case 'control5' %In 'to' final pos
        lens = 120;
        x = ones(lens,1)*points(3,1);
        y = ones(lens,1)*points(3,2);
        bridgeFront = zeros(lens, 1);
    case 'control6' %In 'under' final pos
        lens = 120;
        x = ones(lens,1)*points(4,1);
        y = ones(lens,1)*points(4,2);
        bridgeFront = zeros(lens, 1);
    case 'control7' %Below starting position
        lens = 120;
        x = ones(lens,1)*points(15,1);
        y = ones(lens,1)*points(15,2);
        bridgeFront = zeros(lens, 1);
        
    case 'control8' %Very low, under bridge
        lens = 120;
        x = ones(lens,1)*points(16,1);
        y = ones(lens,1)*points(16,2);
        bridgeFront = zeros(lens, 1);
                    
        
    %
    %(OK, here's the real ones!)
    %
    case 'past'
        lens = 150;
        bridgeFront = zeros(lens, 1);
        %straight path under bridge to other side
        startpos = points(1,:);
        endpos = points(6,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'above'
        %straight path to above bridge (hovering)
        lens = 120;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(7,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'under'
        %straight path to under the bridge...
        lens = 90;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(4,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'to'
        %straight path to the edge of the bridge!
        lens = 60;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(3,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'behind'
        %like 'to', a bit farther and behind bridge
        lens = 60;
        bridgeFront = ones(lens, 1);
        startpos = points(1,:);
        endpos = points(12,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'tofar'
        %straight path to the far edge of the bridge
        lens = 135;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(10,:);
        x = ones(lens,1)*startpos(1); %stays constant!)
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    case 'along'
        %straight segments to and then along the bridge!
        lens = 120;
        bridgeFront = zeros(lens, 1);
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
        lens = 90;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(9,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        %Ellipse equation
        a = 50;%radii
        b = 400;
        h = 250;%x center
        k = 50;%y center
        y = sqrt(b^2*(1-((x-h).^2/a^2)))+k;
    case 'over'
        %Curved path over the top of the bridge to other side
        lens = 180;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(6,:);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
        %Straight segment then Parabola!
        for i=1:lens
            if y(i) < 150
                x(i) = 300;
            else
                x(i) = 0.0033*(y(i)-425).^2+50;
            end
        end
    case 'circle'
        %curved path in front then behind the leg of the bridge
        lens = 120;
        bridgeFront = [zeros(75,1); ones(45,1)];
        startpos = points(1,:);
        midpos = [300 400];
        circpos = [300 150];
        %straight section
        straight_x = ones(1,30)*300;
        straight_y =  startpos(2):(circpos(2)-startpos(2))/(30-1):circpos(2);
        %Downward ellipse
        down_y = circpos(2):(midpos(2)-circpos(2))/(45-1):midpos(2);
        a = 25;%radii
        b = 125;
        h = 300;%x center
        k = 275;%y center
        down_x = sqrt( a^2*(1-((down_y-k).^2/b^2)) )+h;
        %Upward ellipse
        back_y = midpos(2):(circpos(2)-midpos(2))/(45-1):circpos(2);
        a = 25;%radii
        b = 125;
        h = 300;%x center
        k = 275;%y center
        %back_x = -sqrt( a^2*(1-((down_y-k).^2/b^2)) )+h;
        back_x = ones(1,45)*300;
        
        %put them together
        x = [straight_x down_x back_x];
        y = [straight_y down_y back_y];
    case 'onto'
        %Curved from starting point to top!
        lens = 135;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(8,:);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);%length = lens!
        x = 0.0029*(y).^2-1.929*y+389.29;
    case 'underfar'
        %Straight path ending like 'tofar' but in front of the bridge
        lens = 150;
        bridgeFront = zeros(lens, 1);
        startpos = points(1,:);
        endpos = points(13,:);
        x = startpos(1):(endpos(1)-startpos(1))/(lens-1):endpos(1);
        y = startpos(2):(endpos(2)-startpos(2))/(lens-1):endpos(2);
    
end

%make sure x and y are oriented the right way!
if size(x,1) == 1
    x = transpose(x);
end
if size(y,1) == 1
    y = transpose(y);
end