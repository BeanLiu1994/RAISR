% clear all;
% clc;
% 
% R=2; %%±¶Êý
% patchSize=11;
% Qangle=24;
% Qstrenth=3;
% Qcoherence=3;
% trainPath= ('train');
% testPath= ('test');
% 
% filelist = readImages(trainPath);
% Q=zeros(patchSize*patchSize,patchSize*patchSize,R*R,Qangle*Qstrenth*Qcoherence);
% V=zeros(patchSize*patchSize,R*R,Qangle*Qstrenth*Qcoherence);
% mark=zeros(R*R,Qangle*Qstrenth*Qcoherence);
% for k=1:length(filelist)
%     fprintf('\nProcessing %s...\n',filelist(k).name);
%     im = imread(fullfile(trainPath,filelist(k).name));
%     im = im2double(im);
%     [H,W]=size(im);
%     imL=extendL(im,patchSize,R);
%     imH=im;
%     for i1=1:H
%         for j1=1:W
%             patchL=imL(i1:(i1+2*floor(patchSize/2)),j1:(j1+2*floor(patchSize/2)));
%             [theta,lamda,u]=hashTable(patchL,Qangle,Qstrenth,Qcoherence);
%             patchL=patchL(:)';
%             t=mod(i1,R)*R+mod(j1,R)+1;
%             j=(theta-1)*9+(lamda-1)*3+u;
%             A=patchL'*patchL;
%             Q(:,:,t,j)=Q(:,:,t,j)+A;
%             b=patchL'*imH(i1,j1);
%             V(:,t,j)=V(:,t,j)+b;
%             mark(t,j)=mark(t,j)+1;
%         end
%     end
% end

h=zeros(patchSize*patchSize,R*R,Qangle*Qstrenth*Qcoherence);
for t=1:R*R
    for j=1:(Qangle*Qstrenth*Qcoherence)
        erro=0;
        while(true)
            if(sum(sum(Q(:,:,t,j)))<100)
                break;
            end
            if(det(Q(:,:,t,j))<1)
                erro=erro+1
                Q(:,:,t,j)=Q(:,:,t,j)+eye(121)*sum(sum(Q(:,:,t,j)))*0.000000005;
            else
                 h(:,t,j)=Q(:,:,t,j)^-1*V(:,t,j);
                break;
            end
        end
    end
end
