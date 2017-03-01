function [imL,extend]=GetL(im,patchSize,R,AddGap)
[H,W,Dim]=size(im);
H=floor(H/R);
W=floor(W/R);
if exist('AddGap','var') && AddGap
    extend=floor(patchSize/2);
else
    extend=0;
end
imL=zeros(H+extend*2,W+extend*2,Dim);
% imLL = imresize(imfilter(im,fspecial('gaussian'),'same','replicate'),1/R,'bicubic');%有必要高斯吗,
imLL = imresize(im,1/R,'bicubic');
imL((extend+1):(H+extend),(extend+1):(W+extend),:)=imLL;
end