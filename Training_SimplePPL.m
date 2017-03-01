%%本文件内容为对
%%-<RAISR 中 First Steps: Global Filter Learning>-
%%部分的实现尝试
%%代码部分来源于github.com/???
%%暂时不考虑后面的内容,仅计算一个Global Filter
%%后面的内容将以此文件为基础添加进来
%%
clear;
clc;

%%初始参数 与 路径
R=2; %%倍数 UpscaleFactor
patchSize=11; %%extendL和extendH内要求patchSize是奇数
trainPath= ('train');
testPath= ('test');
savePath= ('Recover_1');
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

%%开始训练
Q=zeros(patchSize*patchSize,patchSize*patchSize);
V=zeros(patchSize*patchSize,1);
for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);
    imL=extendL(im,patchSize,R);
    imH=extendH(im,patchSize);
    
    GridRows=floor(H/patchSize);
    GridCols=floor(W/patchSize);
    Ab_RowCount=0;
    A=zeros(GridRows*GridCols*Dim,patchSize*patchSize);
    b=zeros(GridRows*GridCols*Dim,1);
    for row=1:GridRows
        for col=1:GridCols
            for dim=1:Dim
                patchL=imL(...
                    (row-1)*patchSize+1:row*patchSize , ...
                    (col-1)*patchSize+1:col*patchSize , ...
                    dim);
                Ab_RowCount=Ab_RowCount+1;
                A(Ab_RowCount,:)=patchL(:)';
                b(Ab_RowCount)=im(row*patchSize-(patchSize-1)/2,col*patchSize-(patchSize-1)/2,dim);
            end
        end
    end
    Q=Q+A'*A;
    V=V+A'*b;
end
h=Q\V;
save([savePath,'\h.mat'],'h','patchSize','R');
disp(['Solve Complete. ']);


%%图像恢复测试

for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);
    [imL,extend]=extendL(im,patchSize,R,1);
    imH=extendH(im,patchSize,1);
    imH_Recover=zeros(size(imH));
    tic
    parfor row=extend+1:extend+H
        for col=extend+1:extend+W
            for dim=1:Dim
                patchL=imL(...
                    row-extend:row+extend, ...
                    col-extend:col+extend, ...
                    dim);
                imH_Recover(row,col,dim)=patchL(:)'*h;
            end
        end
    end
    toc
    range=320:720;
    subplot(311);
    imshow(imH(range,range,:));
    subplot(312);
    imshow(imL(range,range,:));
    subplot(313);
    imshow(imH_Recover(range,range,:));
    imwrite(imH_Recover,fullfile(savePath,filelist(k).name));
    pause(3);
end