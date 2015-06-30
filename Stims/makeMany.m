function makeMany()

%Just for compiling lots of videos!
%Note that the exact Ken Burns path of each video is NOT guaranteed
%to repeat for a given (manner, path, agent) triplet.

%6/29/15, for the first MannerPath  fMRI experiment

makeKenBurnsStims({'rotate','rock','sine','wheelie'},...
    {'to','tofar','circle','onto'},...
    {2,1,3,8},'movie')

makeKenBurnsStims({'halfrotate','bounce','vibrate','stopstart'},...
    {'past','under','behind','underfar'},...
    {5,4,7,6},'movie')