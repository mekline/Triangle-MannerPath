lens = 120; %Number of (motion) frames, here set to 4 sec for all movies.
currentFolder = pwd;

[x, y] = getPath('underup', lens); %x and y are the midpoints of the object, so imrotate can work correctly...
[x, y] = smoothPath(x,y); %Ensures that points are equidistant along that piecewise path...
 
[x, y, rotations] = applyManner('rock', x,y);


 mode = 'movie';
 %mode = 'pilot';




for obj = 1:1
    img = imread([currentFolder '/img/' num2str(obj) '.jpg'],'JPEG'); %read in object
    [m n p] = size(img); %how big is it? (h, w, layers)
    
    backimg = imread([currentFolder '/img/bg_refgrid.jpg'],'JPEG'); %read in bg
    [q r s] = size(backimg);
    

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
        newimg = moveImg(img, backimg, x(1)-50, y(1)-50); 
        for j=1:30
            m(j) = getframe;
            image(newimg);
            axis off;
            drawnow;
        end
        
        %Draw the animation
        for i = 1:lens
            img_rot = imrotate(img, rotations(i)); 
            %how big is the img right now? Find this out so we can set the lh
            %corner correctly!
            [t u v] = size(img_rot);
            newimg = moveImg(img_rot, backimg, x(i) - round(t/2),y(i)-round(u/2));
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
        movie2avi(m,[num2str(obj) '.avi'],'FPS',30);
        
    elseif strcmp(mode,'pilot')
  
        %And here's something else for debugging - instead of redrawing the
        %triangle, trace its path 
        newimg = backimg;
        for i = 1:lens
            newimg = traceImg(img_rot, newimg, x(i),y(i));
        end
        image(newimg);
        axis off;
        drawnow;
    end
  
 

 
end