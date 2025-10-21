%   Sources: 71
%       Sources  1-11: birds
%       Sources 12-29: rain
%       Sources 30-53: thunder
%       Sources 54-71: rain

clc;
pos='';

scriptDir = fileparts(mfilename('fullpath')); % get file location, for output
filePath = fullfile(scriptDir, 'pos.txt');

fid = fopen(filePath, 'w');       % open for write (clear existing content)

for ii=1:11 % create random positions for label tracks: birds
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*115-25,0); % ele range: -25-90

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*115-25,0); % ele range: -25-90

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end

for ii=12:29 % create random positions for label tracks: rain
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 =  round(rand*45+20,0); % ele range: 20-65

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*45+25,0); % ele range: 25-70

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end

for ii=30:53 % create random positions for label tracks: thunder
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*115-25,0); % ele range: -25-90

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*115-25,0); % ele range: -25-90

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end

for ii=54:71 % create random positions for label tracks: rain
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*45+35,0); % ele range: 35-80

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 =  round(rand*45+20,0); % ele range: 20-65

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end

fclose(fid);