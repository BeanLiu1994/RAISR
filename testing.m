filelist = readImages(testPath);
for k=1:length(filelist)
    fprintf('\nProcessing %s...\n',filelist(k).name);
    im = imread(fullfile(trainPath,filelist(k).name));
    im = im2double(im);
    [H,W]=size(im);
    imH=extendH(im,patchSize,R);
    imR=zeros(R*H,R*W);
    for i1=1:2*H
        for j1=1:2*W
            patchH=imH(i1:(i1+2*floor(patchSize/2)),j1:(j1+2*floor(patchSize/2)));
            [theta,lamda,u]=hashTable(patchH,Qangle,Qstrenth,Qcoherence);
            patchH=patchH(:)';
            t=mod(i1,R)*R+mod(j1,R)+1;
            j=(theta-1)*9+(lamda-1)*3+u;
            imR(i1,j1)=patchH*h(:,t,j);
        end
    end
end