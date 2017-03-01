%%���ļ�����Ϊ��
%%-<RAISR �� First Steps: Global Filter Learning>-
%%���ֵ�ʵ�ֳ���
%%���벿����Դ��github.com/???
%%��ʱ�����Ǻ��������,������һ��Global Filter
%%��������ݽ��Դ��ļ�Ϊ������ӽ���
%%
clear;
clc;

%%��ʼ���� �� ·��
R=2; %%���� UpscaleFactor
patchSize=11; %%extendL��extendH��Ҫ��patchSize������
trainPath= ('train');
testPath= ('test');
savePath= ('Recover_1');
filelist = readImages(trainPath);

%%�������
%1. patchSize Ϊ ����
if mod(patchSize,2)==0
    error('patchSizeӦ����Ϊ���� (����ͼ���С)');
end
%2. �ֽ׶ν�R����Ϊ����
if ceil(R)-R~=0
    error('RӦ����Ϊ���� (����ͼƬ�Ŵ���)');
end

%%��ʼѵ��
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


%%ͼ��ָ�����

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