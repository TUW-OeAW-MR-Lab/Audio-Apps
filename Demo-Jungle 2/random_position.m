% random_position.m
% 
% Assign random positions to several audio channels.
% Output file: 'pos.txt'
% 
% Final mix saved as Data\merged_sources.wav with 126 channels.
% - channels 1-11 (11 channels): birds.wav
% - channels 12-29 (18 channels): rain.wav
% - channels 30-53 (24 channels): thunderstorm.wav
% - channels 54-71 (18 channels): rain2.wav
% - channels 72-98 (27 channels): frogs.wav
% - channels 99-126 (28 channels): crickets.wav
% Channel mapping written to Data\merged_sources.log
% 
% #Author: Michael Mihocic (07-10.2025)
% #Author: Michael Mihocic: creek removed (17.10.2025)
% 

% Copyright (C) Michael Mihocic, Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: https://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License.

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

for ii=72:98 % create random positions for label tracks: frogs
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*45-30,0); % ele range: -30 - +15

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 =  round(rand*45-30,0); % ele range: -30 - +15

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end


for ii=99:126 % create random positions for label tracks: crickets
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*45-30,0); % ele range: -30 - +15

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 =  round(rand*45-30,0); % ele range: -30 - +15

    newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file

    newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
    disp(newRow); % display in Matlab output window
    fprintf(fid, '%s\r\n', newRow); % save to output file
end

% for ii=127:141 % create random positions for label tracks: creek
%     rng('shuffle');
%     azi1 = round(rand*45,0);
%     ele1 = round(rand*45-30,0); % ele range: -30 - +15
% 
%     rng('shuffle');
%     azi2 = round(rand*45,0);
%     ele2 =  round(rand*45-30,0); % ele range: -30 - +15
% 
%     newRow=['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]; % get random start position
%     disp(newRow); % display in Matlab output window
%     fprintf(fid, '%s\r\n', newRow); % save to output file
% 
%     newRow=['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]; % if moving,  get random end  position
%     disp(newRow); % display in Matlab output window
%     fprintf(fid, '%s\r\n', newRow); % save to output file
% end

fclose(fid);