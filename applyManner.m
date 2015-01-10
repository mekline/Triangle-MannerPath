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
    case 'sine' 
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
    case 'loop'
        %Nice little loop the loop
        %(enraging, hard to parametrize)
        rotations = zeros(lens,1);
        numSin = floor(lens/30);
        t = transpose(1:lens);
        xman = x + sin(-numSin*2*pi*(t)/(lens-1)+pi/4)*30-sin(-numSin*2*pi/(lens-1)+pi/4)*30;
        yman = y + cos(-numSin*2*pi*(t)/(lens-1)+pi/4)*30-cos(-numSin*2*pi/(lens-1)+pi/4)*30 ;
    case 'stopstart'
        %Takes the existing points, and execute them on another timescale
        rotations = zeros(lens,1);
        numPause = floor(lens/30)*3;
        final_x = [];
        final_y = [];
        t = 1;
        
        %Split up the (x,y) array into chunks
        for j = 1:numPause
            t2 = floor(j*lens/numPause);
            myset = [x(t:t2) y(t:t2)];
            new_x = [];
            new_y = [];
            lastpoint = myset(end, :);
            for k=1:length(myset)
                %For each chunk, throw out 1/3 of the points, and smooth
                %the rest
                if mod(k,3) ~= 0
                    new_x(end+1) = myset(k,1);
                    new_y(end+1) = myset(k,2);
                end
            end  
            [new_x, new_y] = smoothPath(new_x,new_y);
            %Then, just 'pause' at the last point
            lenLeft = (t2-t)-length(new_x);
            new_x = [new_x; ones(lenLeft,1)*lastpoint(1)];
            new_y = [new_y; ones(lenLeft,1)*lastpoint(2)];
            final_x = [final_x transpose(new_x)];
            final_y = [final_y transpose(new_y)];
            
            t = t2;
        end
        
        %Rather than fix my one-off error, just add it to the end :(
        final_x = [final_x lastpoint(1)];
        final_y = [final_y lastpoint(2)];
        
        xman = final_x;
        yman = final_y;
    case 'squarewave' 
        % Thresholds sineWave so it hops back and forth between 1 and -1,
        % otherwise identical!
        %No, actually just one cycle/sec, and cosine so we start/end in right
        %place!
        rotations = zeros(lens,1);
        numSin = floor(lens/30);
        t = 1:lens;
        for i=1:lens
            if cos(numSin*2*pi*t(i)/lens) > 0
                xman(i) = x(i);
            else
                xman(i) = x(i) - 20;
            end
        end
        
        yman = y;
    case 'backforth'
        %Spread out the points to include some backtracks in the path
        %(similar to stopstart)
        %Takes the existing points, and execute them on another timescale
        rotations = zeros(lens,1);
        numPause = floor(lens/30)*2;
        final_x = [];
        final_y = [];
        t = 1;
        
        %Split up the (x,y) array into chunks
        for j = 1:numPause
            t2 = floor(j*lens/numPause);
            myset = [x(t:t2) y(t:t2)];
            new_x = [];
            new_y = [];
            lastpoint = myset(end, :);
            for k=1:length(myset)
                %For each chunk, throw out 1/3 of the points, and smooth
                %the rest
                if mod(k,3) ~= 0
                    new_x(end+1) = myset(k,1);
                    new_y(end+1) = myset(k,2);
                end
            end  
            [new_x, new_y] = smoothPath(new_x,new_y);
            %Then, grab the last space of points and use it to run
            %backwards
            lenLeft = (t2-t)-length(new_x);
            halfway = floor(lenLeft/2);
            newer_x = new_x;
            newer_y = new_y;
            for k=1:(lenLeft)
                    newer_x = [newer_x; new_x(end-k)];
                    newer_y = [newer_y; new_y(end-k)];    
            end
            
            final_x = [final_x transpose(newer_x)];
            final_y = [final_y transpose(newer_y)];
            
            t = t2;
        end
        
        %Another one-off error, just add it to the end :(
        final_x = [final_x lastpoint(1)];
        final_y = [final_y lastpoint(2)];
        
        %And smooth the paths!
        
        [final_x, final_y] = smoothPath(final_x,final_y);
        xman = final_x;
        yman = final_y;
    
        
    
   
end



