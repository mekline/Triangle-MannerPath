function makeKenBurnsControl(objects, mode, watchit)
%Just like makeKBStims, but the agent just sits in a location while
%background moves behind it.  Automatically chooses to make videos in 
%the 8 possible background locations.
%
%The new watchit option lets you decide to watch the movie as it compiles,
%which is SUPER SLOW
%
%modes: 'pilot' just shows traces quickly, 'movie' exports videos to
%movies folder

if nargin < 3
    watchit = 0;
end


currentFolder = pwd;

for a=1:1
    for b=1:1
        
        %Get the imgs and make a movie!    
        for c= 1:length(objects)
            
            obj = objects{c};
            
            loc = [300,400];
            
            %Report what movie this will be
            deets = [num2str(obj), ' ', num2str(loc(1)), ' ',num2str(loc(2))];
            disp(deets)
            
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

            
            %Here we just draw the bridge on the background for the length
            %of the movie!!
            if strcmp(mode,'movie')

                %Draw 6 boring seconds of the triangle sitting in initial position!
                withbridge = placeImg(bridgeimg, backimg, 195, 295);
                
                for j=1:180
                    if watchit
                        image(withbridge);
                    end
                    m_images(:,:,:,j) = withbridge;
                end
                
                
                %KEN BURNS TIME!
                %Calculate a (random) path for the movie to move around on
                %the larger background, then plot everything into the
                %bigger matrix.
                
                %how long is the movie? Check here in case of mistakes :p 
                final_len = size(m_images,4);
                
                kb_back = zeros(750, 1000, 3, final_len); %height, width, colors, length-in-frames
                [kb_x, kb_y] = getKBPath(150, 200, final_len, 60); %30-fast 60-slow
                
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
                    
                    %And the new thing for the control! Add the agent just
                    %sitting there in the location!
                    contimg = placeImg(img, newimg, loc(1), loc(2));
                    final_images(:,:,:,i) = contimg;
                end
                
                %final_images = m_images;

                
   

                %Convert images to a movie!           
                w = VideoWriter(['movies/' num2str(obj) '_control_' num2str(loc(1)) num2str(loc(2))],'MPEG-4');
                w.FrameRate = 30;
                open(w);
                writeVideo(w,final_images);
                close(w);
               

            elseif strcmp(mode,'pilot')

                %And here's something else for debugging - instead of redrawing the
                %triangle, trace its path 
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
