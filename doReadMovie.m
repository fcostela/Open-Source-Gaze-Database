function [movmat movobj]=doReadMovie(file)

% creat movie object
movobj=VideoReader(file);

% video specs
nFrames=movobj.NumberOfFrames;
vidHeight=movobj.Height;
vidWidth=movobj.Width;

% Preallocate movie structure.
%mov(1:nFrames)= struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);

% Read one frame at a time.
parfor k=1:nFrames
    
    movmat(k).cdata=read(movobj,k);
end


