function EPim=plotEP2Frame(etdata,frame,destdims)
% Return a frame image with the pixels corresponding to the gazes in white
% with the shape of a cross

% make sure movie frame is the right size
for i=1:size(frame,3)
    framesc(:,:,i)=imresize(frame(:,:,i),[destdims(2) destdims(1)]);
end

% width and height of eye position cross
epXsz=20;
% one 'pixel' of the cross
epPix=250;%[250 250 250]';

for i=1:size(etdata,1)
    % indices of the cross for the EP
    epXh=[etdata(i,1)-epXsz:etdata(i,1)+epXsz];
    epXh=epXh(epXh>=1 & epXh<=destdims(1));
    epXh=[etdata(i,2)*ones(length(epXh),1) epXh'];
    epXv=[etdata(i,2)-epXsz:etdata(i,2)+epXsz];
    epXv=epXv(epXv>=1 & epXv<=destdims(2));
    epXv=[epXv' etdata(i,1)*ones(length(epXv),1)];
    % plot
    for j=1:3
        framesc(round(epXh(:,1)),round(epXh(:,2)),j)=epPix;
        framesc(round(epXv(:,1)),round(epXv(:,2)),j)=epPix;
    end
end

EPim=framesc;

