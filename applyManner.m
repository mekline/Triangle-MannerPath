function [xman, yman, rotations] = applyManner(mannername, x,y)

lens = length(x);

switch mannername
    case 'none'
        rotations = zeros(lens, 1); %no changes!
        xman = x;
        yman = y;
    case 'sillySine'
        rotations = zeros(lens, 1);
        xman = x + sin(x/5)*12;
        yman = y;
    case 'sillyBounce'
        rotations = zeros(lens, 1);
        x = x + abs(sin(x/5))*12;
        yman = y;
        
    %OK, here's the real ones
    case 'vibrate' %just a very fast and small-amplitude sine...no need to adjust for path length
        rotations = zeros(lens,1);
        t = 1:lens;
        xman = x + sin(40*2*pi*(t-250)/(450))*4;
        yman = y;
    case 'rotate'
        %rotations? ~ 1 per second, rounded down
        rots = floor(lens/30);
        rotations = 0:(-360*rots/(lens-1)):(-360*rots); %Four complete rotations
        xman = x;
        yman = y;
   case 'halfrotate' %rotate ~180 deg, start & end up vertical
        t = 1:lens;
        %~ 1 bops per second
        mult = floor(lens/30);
        rotations = 100*sawtooth((mult)*pi*(t-t(1))/(t(end)-t(1))+pi/2, 0.5);
        xman = x;
        yman = y;
    case 'rock' %rotate over the 90 deg. around upright, start & end up vertical
        t = 1:lens;
        %~ 6 bops per second
        mult = floor(lens/30)*6;
        rotations = 30*sawtooth((mult)*pi*(t-t(1))/(t(end)-t(1))+pi/2, 0.5);
        xman = x;
        yman = y; 
    case 'sineWave' 
        % 3 complete sines per ~second
        rotations = zeros(lens,1);
        numSin = floor(lens/30)*3;
        t = 1:lens;
        xman = x + transpose(sin(numSin*2*pi*t/lens)*20);
        yman = y;
    case 'bounce' 
        %Abs the above, 2 bounce per second
        rotations = zeros(lens,1);
        numSin = floor(lens/30);
        t = 1:lens;
        xman = x - abs(transpose(sin(numSin*2*pi*t/lens)*20));
        yman = y;
    case 'stopstart'
        %Takes the existing points, and execute them on another timescale
        %Split the arrays into that many sets. In each set, eliminate every 4th point (speeds up) then hold at
        %the end
        rotations = zeros(lens,1);
        numPause = floor(lens/30)*2;
        final_x = [];
        final_y = [];
        t = 1;
        
        for j = 1:numPause
            t2 = floor(j*lens/numPause);
            myset = [x(t:t2) y(t:t2)];
            new_x = [];
            new_y = [];
            lastpoint = myset(end, :);
            for k=1:length(myset)
                if mod(k,3) ~= 0
                    new_x(end+1) = myset(k,1);
                    new_y(end+1) = myset(k,2);
                end
            end  
            [new_x, new_y] = smoothPath(new_x,new_y);
            lenLeft = (t2-t)-length(new_x);
            new_x = [new_x; ones(lenLeft,1)*lastpoint(1)];
            new_y = [new_y; ones(lenLeft,1)*lastpoint(2)];
            final_x = [final_x transpose(new_x)];
            final_y = [final_y transpose(new_y)];
            
            t = t2;
        end
        
        xman = final_x;
        yman = final_y;

    
    case 'backandforth'
        rotations = zeros(lens,1);
        xman = x + sin(5*2*pi*(y-y(1))/(y(end)-y(1)));
        yman = y + (sin(5*2*pi*(y-y(1))/(y(end)-y(1)))*50);
end



