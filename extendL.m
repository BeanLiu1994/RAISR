function imL=extendL(im,patchSize,R)
[H,W]=size(im);
imL=zeros(H+patchSize-1,W+patchSize-1);
imLL = imresize(imfilter(im,fspecial('gaussian'),'same','replicate'),1/R,'bicubic');
imLL = imresize(imLL,R,'bicubic');
imL((floor(patchSize/2)+1):(H+floor(patchSize/2)),(floor(patchSize/2)+1):(W+floor(patchSize/2)))=imLL;
end