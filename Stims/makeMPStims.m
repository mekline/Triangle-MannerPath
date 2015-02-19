function makeMPStims(manners, paths,mode)
%Full set of paths & manners:
%{'vibrate','rotate','halfrotate','rock','sine','bounce','loop','stopstart','squarewave','backforth','zip','wheelie'}
%{'past','above','under','to','behind','tofar','along','underup','over','circle','onto','underfar'}
%
%modes: 'pilot' just shows traces quickly, 'movies' exports videos to
%movies folder

currentFolder = pwd;

for a=1:length(manners)
    for b=1:length(paths)
        
        %Calculate the x,y vectors of the manner+path composition!
        mymanner = manners{a};
        mypath = paths{b};
        [x, y, lens, bridgeFront] = getPath(mypath); %x and y are the top lh corner of the object
        %lens is number of (motion) frames, 30 = 1 sec
        %bridge front tells whether to draw the bridge in front of the triangle.
        
        [x, y] = smoothPath(x,y); %Ensures that points are equidistant along that piecewise path...
        [x, y, rotations] = applyManner(mymanner, x,y);

        %special case! lens may have gotten longer, watch out:
        if (lens < length(x))
            bridgeFront = [bridgeFront; repmat(bridgeFront(end),length(x)-lens, 1)]; 
            lens = length(x);
        elseif (lens > length(x))
            lens=length(x);
        end
        
        %Get the imgs and make a movie!    
        for obj = 1:1
            img = imread([currentFolder '/img/' num2str(obj) '.jpg'],'JPEG'); %read in object
            [m n p] = size(img); %how big is it? (h, w, layers)

            backimg = imread([currentFolder '/img/bg.jpg'],'JPEG'); %read in bg
            [q r s] = size(backimg);

            bridgeimg = imread([currentFolder '/img/bridge.jpg'],'JPEG'); %read in bg

            %Draw them to obj m
            clear m;

            if strcmp(mode,'movie')

                %Because of how imrotate works, the size of img is not guaranteed!  
                %(it adds buffer cells if needed to fit the whole img). But
                %the midpoint is guaranteed to stay the midpoint!  So let's plot that
                %instead.
                % 
                x = x+50;
                y = y+50;

                %Draw one boring second of the triangle sitting in initial position!
                withbridge = drawOnBackground(bridgeimg, backimg, 195, 295);
                newimg = moveImg(img, withbridge, x(1)-50, y(1)-50); 

                for j=1:30
                    image(newimg);
                    axis off;
                    m(j) = getframe;
                    drawnow;
                end

                %Draw the animation
                for i = 1:lens
                    %rotate the triangle
                    img_rot = imrotate(img, rotations(i)); 
                    %how big is the img right now? Find this out so we can set the lh
                    %corner correctly!
                    [t u v] = size(img_rot);
                    %draw triangle & bridge on background, in the correct order!
                    if bridgeFront(i)
                        nobridge = moveImg(img_rot, backimg, x(i) - round(t/2),y(i)-round(u/2));
                        newimg = drawOnBackground(bridgeimg, nobridge, 195, 295);
                    else
                        withbridge = drawOnBackground(bridgeimg, backimg, 195, 295);
                        newimg = moveImg(img_rot, withbridge, x(i) - round(t/2),y(i)-round(u/2));
                        end
                    m(i+30) = getframe;
                    image(newimg);
                    axis off;
                    drawnow;
                end

                %Draw two boring seconds of the final position
                for k = 1:60
                    m(k+lens+30) = getframe;
                    image(newimg);
                    axis off;
                    drawnow;
                end

                %Convert m to a movie :)
                %movie2avi(m,[num2str(obj) '.avi'],'FPS',30);
                w = VideoWriter(['movies/' num2str(obj) '_' mymanner '_' mypath],'MPEG-4');
                w.FrameRate = 30;
                open(w);
                writeVideo(w,m);
                close(w);

            elseif strcmp(mode,'pilot')

                %And here's something else for debugging - instead of redrawing the
                %triangle, trace its path 
                newimg = drawOnBackground(bridgeimg,backimg,195, 275);
                for i = 1:lens
                    newimg = traceImg(img, newimg, x(i),y(i));
                end
                image(newimg);
                axis off;
                drawnow;
            end
        end
    end
end