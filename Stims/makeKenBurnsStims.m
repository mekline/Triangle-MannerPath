function makeKenBurnsStims(manners, paths, objects, mode, doKenBurns, doMotionBar, watchit)
%Just like makeMPStims, but the whole movie also (optionally) moves on a black
%background.  Also adds an option to have multiple agents!
%
%The new watchit option lets you decide to watch the movie as it compiles,
%which is SUPER SLOW.  Don't do it unless you're developing that movie. 
%
%doKenBurns sets whether to place the movie on the moving black background,
%it's much faster if you don't!!!!!
%
%Full set of paths & manners:
%{'vibrate','rotate','halfrotate','rock','sine','bounce','loop','stopstart','squarewave','backforth','zip','wheelie'}
%{'past','above','under','to','behind','tofar','along','underup','over','circle','onto','underfar'}
%
%modes: 'pilot' just shows traces quickly, 'movie' exports videos to
%movies folder

if nargin < 5
    doKenBurns = 0;
end

if nargin < 6
    doMotionBar = 0;
end

if nargin < 7
    watchit = 0;
end


currentFolder = pwd;

for a=1:length(manners)
    for b=1:length(paths)  
        for c= 1:length(objects)
            %Get the imgs and make a movie!  
            obj = objects{c};
            
            %Report what movie this will be
            deets = [num2str(obj), ' ', manners{a},' ',paths{b}];
            disp(deets)
        
            %Calculate the x,y vectors of the manner+path composition!
            mymanner = manners{a};
            mypath = paths{b};
            [x, y, lens, bridgeFront] = getPath(mypath); %x and y are the top lh corner of the object

            x(1);
            y(1);
            %lens is number of (motion) frames, 30 = 1 sec
            %bridge front tells whether to draw the bridge in front of the
            %triangle at this timpoint.

            %for debugging
            %testlen = ['my lens is ', num2str(lens), 'but my x and y lens are', num2str(length(x)), ' ', num2str(length(y))];
            %disp(testlen)

            %Ensure that points are equidistant along that piecewise path...
            if (not (all(x == x(1)))) && (not (all(y == y(1))))
                [x, y] = smoothPath(x,y); 
            end


            [x, y, rotations] = applyManner(mymanner, x, y);

            %special case! lens may have gotten longer or shorter during smoothing, watch out:
            if (lens < length(x))
                bridgeFront = [bridgeFront; repmat(bridgeFront(end),length(x)-lens, 1)]; 
                lens = length(x);
            elseif (lens > length(x))
                lens=length(x);
            end

            %special case! Budge all the paths down a hair so that agents don't
            %float in the air.
            y = y+25;
        

            
            tic; %how long does this take?
            
            img = imread([currentFolder '/img/' num2str(obj) 'eye.jpg'],'JPEG'); %read in object
            [m n p] = size(img); %how big is it? (h, w, layers)

            backimg = imread([currentFolder '/img/bg.jpg'],'JPEG'); %read in bg
            [q r s] = size(backimg);

            bridgeimg = imread([currentFolder '/img/bridge.jpg'],'JPEG'); %read in bg

            %Now use the above calculated path to draw them to obj m_images
            clear m_images;
            
            %How big is my array going to be?  Preallocate it? This doesn't
            %actually seem to improve speed
            %m_images = ones(600, 800, 3, 180); %height, width, colors, length-in-frames

            if strcmp(mode,'movie')

                %Because of how imrotate works, the size of img (the agent) is not guaranteed!  
                %(it adds buffer cells if needed to fit the whole img). But
                %the midpoint is guaranteed to stay the midpoint!  So let's plot that
                %instead.
                
                x = x+50;
                y = y+50;

                %Draw one boring second of the triangle sitting in initial position!
                withbridge = placeImg(bridgeimg, backimg, 195, 295);
                newimg = placeImg(img, withbridge, x(1)-50, y(1)-50); 
                
                prefix = floor((180-lens)/3); %Standardized so that total movie comes out to 180frames
                postfix = floor(2*(180-lens)/3);
                
                for j=1:prefix
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,j) = newimg;
                end
                

                %Draw the animation
                for i = 1:lens
                    
                    if i==1
                        x(1);
                        y(1);
                    end
                    %rotate the triangle
                    img_rot = imrotate(img, rotations(i)); 
                    %how big is the img right now? Find this out so we can set the lh
                    %corner correctly!
                    [t, u, v] = size(img_rot);
                    %draw triangle & bridge on background, in the correct order!
                    if bridgeFront(i)
                        nobridge = placeImg(img_rot, backimg, x(i) - round(t/2),y(i)-round(u/2));
                        newimg = placeImg(bridgeimg, nobridge, 195, 295);
                    else
                        withbridge = placeImg(bridgeimg, backimg, 195, 295);
                        newimg = placeImg(img_rot, withbridge, x(i) - round(t/2),y(i)-round(u/2));
                    end
   
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,prefix+i) = newimg;
                end

                %Draw boring final position
                for k = 1:postfix
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,prefix+lens+k) = newimg;
                end
                
                %KEN BURNS TIME!
                %Calculate a (random) path for the movie to move around on
                %the larger background, then plot everything into the
                %bigger matrix.
                
                if doKenBurns
                
                    %how long is the movie? Check here in case of mistakes :p 
                    final_len = size(m_images,4);

                    kb_back = zeros(750, 1000, 3, final_len); %height, width, colors, length-in-frames
                    [kb_x, kb_y] = getKBPath(150, 200, final_len, 45); %30-fast motion 60-super slow motion 45 -just right!

                    %this returns a random bounce-around in the box (diff 
                    %between small & big frames)that takes the final # of
                    %frames to move 1 segment.

                    %Now plot my movie into the bigger (all black) movie!

                    clear final_images;

                    for i = 1:final_len
                        %draw movie on background! 
                        movToDraw = m_images(:,:,:,i);
                        [t, u, v] = size(movToDraw);
                        newimg = placeImg(movToDraw, kb_back(:,:,:,i), kb_x(i),kb_y(i));
                        
                        %As another fun option, we can get a still bar in
                        %front of the movie to provide some low-level
                        %motion in even the control movies.  Put this somewhere carefully so that
                        %it starts outside the movie box.
                        if doMotionBar 
                            startDrift = [kb_x(1), kb_y(1)];
                            
                            if isequal(startDrift, [0,0])||isequal(startDrift,[0,100])
                                mybar = imread([currentFolder '/img/horz.jpg'],'JPEG'); %read in object
                                my_x = 625;%top lcorner of where to put the shape!
                                my_y = 600;%Z
                            elseif isequal(startDrift,[0,200]) || isequal(startDrift, [75,200])
                                mybar = imread([currentFolder '/img/vert.jpg'],'JPEG'); %read in object
                                my_x = 350;%Z%top lcorner of where to put the shape!
                                my_y = 75;%Z
                            elseif isequal(startDrift, [150,200])|| isequal(startDrift,[150,100])
                                mybar = imread([currentFolder '/img/horz.jpg'],'JPEG'); %read in object
                                my_x = 75;%Z%top lcorner of where to put the shape!
                                my_y = 0;%Z
                            elseif isequal(startDrift,[75,0])|| isequal(startDrift,[150,0])
                                mybar = imread([currentFolder '/img/vert.jpg'],'JPEG'); %read in object
                                my_x = 0;%Z%top lcorner of where to put the shape!
                                my_y = 875;
                            end
                            
                        end
                        
                        newimg = placeImg(mybar, newimg, my_x, my_y);
                        
                        final_images(:,:,:,i) = newimg;
                    end
                else
                
                    final_images = m_images;
                end

                
   

                %Convert images to a movie!           
                w = VideoWriter(['movies/' mymanner '_' mypath '_' num2str(obj)],'MPEG-4');
                w.FrameRate = 30;
                open(w);
                writeVideo(w,final_images);
                close(w);
               

            elseif strcmp(mode,'pilot')

                %And here's something else for debugging - instead of redrawing the
                %triangle, trace its path. Good for making new paths!
                newimg = placeImg(bridgeimg,backimg,195, 275);
                for i = 1:lens
                    newimg = traceImg(img, newimg, x(i),y(i));
                end
                image(newimg);
                axis off;
                drawnow;
            end
            
            toc %how long did this movie take?
        end %End THIS MOVIE
    end
end

%hooray, all movies exported successfully!
load gong.mat;
sound(y);
