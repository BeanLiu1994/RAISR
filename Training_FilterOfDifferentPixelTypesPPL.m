%%本文件内容为对
%%-<RAISR 中 First Steps: Global Filter Learning>-
%%部分的实现尝试
%%代码部分来源于github.com/???
%%暂时不考虑后面的内容
%%当前仅计算Global Filter,数量与倍数有关 (R^2个)
%%后面的内容将以此文件为基础添加进来
%%
clear;
clc;
%%初始参数 与 路径
R=2; %%倍数 UpscaleFactor
patchSize=11; %%extendL和extendH内要求patchSize是奇数
trainPath= ('train');
testPath= ('test');
savePath= ('Recover_2');
thumbnailPath= ('thumbnail');
filelist = readImages(trainPath);

%%参数检查
%1. patchSize 为 奇数
if mod(patchSize,2)==0
    error('patchSize应设置为奇数 (代表图块大小)');
end
%2. 现阶段将R设置为整数
if ceil(R)-R~=0
    error('R应设置为整数 (代表图片放大倍数)');
end

%%开始训练 由于有R*R种点,所以需要设置R*R个Filters
Q=zeros(patchSize*patchSize,patchSize*patchSize,R*R);
V=zeros(patchSize*patchSize,1,R*R);
for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);    
    imLL=GetL(im,patchSize,R);
    [HL,WL,~]=size(imLL);    
    imH=extendH(im,patchSize);
    
    GridRows=floor(HL/patchSize);
    GridCols=floor(WL/patchSize);
    Ab_RowCount=zeros(R*R,1);
    A=zeros(GridRows*GridCols*Dim,patchSize*patchSize,R*R);
    b=zeros(GridRows*GridCols*Dim,1,R*R);
    for row=1:GridRows
        for col=1:GridCols
            for dim=1:Dim
                patchL=imLL(...
                    (row-1)*patchSize+1:row*patchSize , ...
                    (col-1)*patchSize+1:col*patchSize , ...
                    dim);
                for pType=1:R*R
                    Center=[-(patchSize-1)/2+row*patchSize,-(patchSize-1)/2+col*patchSize];
                    PosOnHRImg=[(Center(1)-1)*R+ceil(pType/R),(Center(2)-1)*R+mod(pType-1,R)+1];
                    Ab_RowCount(pType)=Ab_RowCount(pType)+1;
                    A(Ab_RowCount(pType),:,pType)=patchL(:)';
                    b(Ab_RowCount(pType),:,pType)=im(PosOnHRImg(1),PosOnHRImg(2),dim);
                end
            end
        end
    end
    for iter=1:R*R
        Q(:,:,iter)=Q(:,:,iter)+A(:,:,iter)'*A(:,:,iter);
        V(:,:,iter)=V(:,:,iter)+A(:,:,iter)'*b(:,:,iter);
    end
end
h=zeros(patchSize*patchSize,1,R*R);
for iter=1:R*R
    h(:,:,iter)=Q(:,:,iter)\V(:,:,iter);
end
save([savePath,'\h.mat'],'h','patchSize','R');
disp(['Solve Complete. ']);
for iter=1:R*R
    subplot(211);
    I=reshape(h(:,:,iter),[patchSize,patchSize]);
    surf(I,'EdgeColor',[0 0 0]);axis equal;colorbar;
    view([0,0,1]);
    subplot(212);
    K=abs(fftshift(fft2(I,70,70))/4);
    surf(K);axis equal;colorbar;
    view([0,0,1]);
    pause(4);
end


%%图像恢复测试

for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);
    [imLL,extend]=GetL(im,patchSize,R,1);
    [HL,WL,~]=size(imLL);    
    imH=extendH(im,patchSize,1);
    imH_Recover=zeros(size(imH));
    tic
    for row=extend+1:HL-extend
        for col=extend+1:WL-extend
            PixelType=mod(row-extend-1,R)*R+mod(col-extend-1,R)+1;
            for dim=1:Dim
                patchL=imLL(...
                    row-extend:row+extend, ...
                    col-extend:col+extend, ...
                    dim);
                for pType=1:R*R
                    pPos=[(row-1)*R+ceil(pType/R),(col-1)*R+mod(pType-1,R)+1];
                    imH_Recover(pPos(1),pPos(2),dim)=patchL(:)'*h(:,:,pType);
                end
            end
        end
    end
    toc
    range=320:720;
    subplot(311);
    imshow(imH(range,range,:));
    subplot(312);
    imLL_H=extendL(im,patchSize,R,1);
    imshow(imLL_H(range,range,:));
    subplot(313);
    imshow(imH_Recover(range,range,:));
    imwrite(imH_Recover,fullfile(savePath,filelist(k).name));
    imwrite(imresize(imfilter(im,fspecial('gaussian'),'same','replicate'),1/R,'bicubic'),fullfile(thumbnailPath,filelist(k).name));
    pause(3);
end