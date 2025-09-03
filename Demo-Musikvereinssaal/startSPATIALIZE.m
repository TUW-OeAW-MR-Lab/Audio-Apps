% Mozart Musikverein




Sall=[40 13 2; ... % Source #1 violin1+violin2
      41 9 3;  ... % Source #2 bassoon+clarinet+flute+horn1+horn2
      40 5 2];     % Source #3 cello+doublebass+viola
%   Sall=[40 2 2; ... % Source #1 violin1+violin2
%       42 9 3;  ... % Source #2 bassoon+clarinet+flute+horn1+horn2
%       40 15 2];     % Source #3 cello+doublebass+viola
% clear R;
R=[38 9 3];
% LWH=[48.8,19.1,17.75]; % Musikvereinssaal (m)

fs=48000;

lS=zeros(size(Sall,1),1);
lIR=zeros(size(Sall,1),1);
disp('Determine size:');
for ii=1:size(Sall,1)
    disp(['- Source #' num2str(ii)]);
    [in,fsx]=audioread(['source_' num2str(ii) '.wav']);
    if fsx~=fs, in=resample(in,fs,fsx); end
    lS(ii)=size(in,1);
    S=Sall(ii,:);
    if ~exist(['reverb_main ' num2str(S) '.mat'],'file'), reverb_main(S,R), end
    X=load(['reverb_main ' num2str(S) '.mat']);
    lIR(ii)=size(X.IRt,1);
end

len=max(lS)+max(lIR)-1;
out=zeros(len,size(X.IRt,2),'single');
disp('Filtering:');
for ii=1:size(Sall,1)
    disp(['- Source #' num2str(ii)]);
    S=Sall(ii,:);
    X=load(['reverb_main ' num2str(S) '.mat']);
    [in,fsx]=audioread(['source_' num2str(ii) '.wav']);
    if fsx~=fs, in=resample(in,fs,fsx); end
    inF=fft(in,len);
    tic;
    parfor jj=1:size(X.IRt,2)
        out(:,jj)=out(:,jj)+single(ifft(inF.*fft(X.IRt(:,jj),len)));
    end
    toc
end
out=out/max(max(abs(out)));
Save_LS([], out, fs, 'output');
