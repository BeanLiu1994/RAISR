function imH=extendH(im,patchSize,R)
im=imresize(im,R,'bicubic');
[H,W]=size(im);
imH=zeros(H+patchSize-1,W+patchSize-1);
imH((floor(patchSize/2)+1):(H+floor(patchSize/2)),(floor(patchSize/2)+1):(W+floor(patchSize/2)))=im;
end