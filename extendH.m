function [imH,extend]=extendH(im,patchSize,AddGap)
[H,W,Dim]=size(im);
if exist('AddGap','var') && AddGap
    extend=floor(patchSize/2);
else
    extend=0;
end
imH=zeros(H+extend*2,W+extend*2,Dim);
imH((extend+1):(H+extend),(extend+1):(W+extend),:)=im;
end