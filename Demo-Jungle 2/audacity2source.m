function X=audacity2source(label, wave)

fid = fopen(label);
C = textscan(fid, '%f%f%s','Delimiter','\t');
fclose(fid);
[x,fs] = audioread(wave);
for ii=1:size(x,2)
    X(ii).sig=x(:,ii);
    X(ii).fs=fs;
    X(ii).pos=zeros(size(x,1),2);
    X(ii).pre_gain=ones(size(x,1),1);
end
for ii=1:size(X,2)
    c=regexp(C{3},['#' num2str(ii) ':']);
    cj=cellfun(@(c)isempty(c),c);
    be=find(cj==0);
    if isempty(be)
        error(['Label track for channel #' num2str(ii) ' not found.']);
    end
    s=cell2mat(C{3}(be,1));
    posA=deg2rad(str2num(s(strfind(s,':')+1:end))); % angles
    posT=0; % position (s)
    for jj=be+1:size(C{3},1)
        %if contains(cell2mat(C{3}(jj,1)),':'), break; end % changed by PM 25.07.2018
        if ~isempty(strfind(cell2mat(C{3}(jj,1)),':')), break; end % changed by PM 25.07.2018
        posA=[posA; deg2rad(str2num(cell2mat(C{3}(jj,1))))];
        if C{1}(jj,1)<posT(end,1)
            error('Correct label missing for the next track.');
        end
        posT=[posT; C{1}(jj,:)];
    end
    posA=[posA; posA(end,:)];
    posS=[round(posT*fs); size(x,1)];
    X(ii).pos=interp1(posS,posA,1:size(x,1));
end