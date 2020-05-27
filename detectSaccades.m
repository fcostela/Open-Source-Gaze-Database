function [etxy_new sacind]=detectSaccades(etxy,eltime)
% [etxy_new sacind]=detectSaccades(data)
% Detects saccades using an acceleration threshold.
% Replaces saccades with last eye position prior
% to saccade and returns vector index -
% (=1 when saccade is in progress, 0 otherwise).
% etxy = Nx2 matrix of [hor vert] coords
% eltime = time elapsed since beginning of clip
%          for each recorded eye position

% NOTE: try adding velocity criterion, changing thold and winsze

%% get magnitude of position change
etnow=etxy(1:end-1,:);
etnext=etxy(2:end,:);
pos=sqrt(sum((etnext-etnow).^2,2));

%% smooth position
n = 50;
Wn = 0.01;
b = fir1(n,Wn);
posfil=filter(b,1,pos);
eltime = double(eltime);

%% fit position, get 2nd deriv
pp=spline(eltime,posfil);
accfn=ppdiff(pp,2);

%% get saccades
acc=ppval(accfn,eltime);
thold=.01;
accind=abs(acc)>thold;

wnsz=3;
i=wnsz-1;
sacstart=0;
sacind=zeros(length(accind),1);
while 1
    if i<length(accind)
        i=i+1;
    else
        break
    end
    if sacstart
        if all(~accind(i-(wnsz-1):i))
            sacstart=0;
            endind=i-(wnsz-1);
            sacind(startind:endind)=1;            
            startind=[];
            continue
        else
            continue
        end
    elseif all(accind(i-(wnsz-1):i))
        sacstart=1;
        startind=i-(wnsz-1);
        endind=[];
        continue
    else
        continue
    end
end

%% replace saccades
etx=etxy(:,1);
etx(logical(sacind))=0;
etxx=replaceZeros(etx);
ety=etxy(:,2);
ety(logical(sacind))=0;
etyy=replaceZeros(ety);
etxy_new=[etxx etyy];

