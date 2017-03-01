%%���ļ�����Ϊ��
%%-<RAISR �� First Steps: Global Filter Learning>-
%%���ֵ�ʵ�ֳ���
%%���벿����Դ��github.com/???
%%��ʱ�����Ǻ��������
%%��ǰ������Global Filter,�����뱶���й� (R^2��)
%%��������ݽ��Դ��ļ�Ϊ������ӽ���
%%
clear;
clc;
%%��ʼ���� �� ·��
R=2; %%���� UpscaleFactor
patchSize=11; %%extendL��extendH��Ҫ��patchSize������
trainPath= ('train');
testPath= ('test');
savePath= ('Recover_2');
thumbnailPath= ('thumbnail');
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

%%��ʼѵ�� ������R*R�ֵ�,������Ҫ����R*R��Filters
Q=zeros(patchSize*patchSize,patchSize*patchSize,R*R);
V=zeros(patchSize*patchSize,1,R*R);
for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);    
    imLL=extendL(im,patchSize,R);
    imH=extendH(im,patchSize);
    
    GridRows=floor(H/patchSize);
    GridCols=floor(W/patchSize);
    Ab_RowCount=zeros(R*R,1);
    A=zeros(GridRows*GridCols*Dim,patchSize*patchSize,R*R);
    b=zeros(GridRows*GridCols*Dim,1,R*R);
    for row=R:GridRows-1
        for col=R:GridCols-1
            Center=[-(patchSize-1)/2+row*patchSize,-(patchSize-1)/2+col*patchSize];
            pType=GetType(Center,R);
            PosOnHRImg=Center;
            for dim=1:Dim
                patchL=imLL(...
                    PosOnHRImg(1)-(patchSize-1)/2*R:R:PosOnHRImg(1)+(patchSize-1)/2*R , ...
                    PosOnHRImg(2)-(patchSize-1)/2*R:R:PosOnHRImg(2)+(patchSize-1)/2*R , ...
                    dim);
                Ab_RowCount(pType)=Ab_RowCount(pType)+1;
                A(Ab_RowCount(pType),:,pType)=patchL(:)';
                b(Ab_RowCount(pType),:,pType)=im(PosOnHRImg(1),PosOnHRImg(2),dim);
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
    subplot(2,R*R,iter);
    I=reshape(h(:,:,iter),[patchSize,patchSize]);
    imagesc(I);axis equal;colorbar;
    subplot(2,R*R,iter+R*R);
%     K=abs(fftshift(fft2(I,70,70))/4);
    K=(abs(fftshift(fft2(I)))+1);
    imagesc(K);axis equal;colorbar;
end


%%ͼ��ָ�����

for k=1:length(filelist)
    disp(['Processing ',filelist(k).name,'...']);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W,Dim]=size(im);
    [imLL,extend]=extendL(im,patchSize*R,R,1);
    [HL,WL,~]=size(imLL);    
    imH=extendH(im,patchSize*R,1);
    imH_Recover=zeros(size(imH));
    tic
    for row=extend+1:HL-extend
        for col=extend+1:WL-extend
            Center=[row,col];
            pType=GetType(Center-[extend,extend],R);
            PosOnHRImg=Center;
            for dim=1:Dim
                patchL=imLL(...
                    PosOnHRImg(1)-(patchSize-1)/2*R:R:PosOnHRImg(1)+(patchSize-1)/2*R , ...
                    PosOnHRImg(2)-(patchSize-1)/2*R:R:PosOnHRImg(2)+(patchSize-1)/2*R , ...
                    dim);
                imH_Recover(Center(1),Center(2),dim)=patchL(:)'*h(:,:,pType);
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