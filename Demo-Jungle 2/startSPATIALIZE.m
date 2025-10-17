%% startSPATIALIZE
%
% This file is used to create a spatial simulation of birds, rain and thunder.
% The VBAP parameters are adapted to MR Lab.
% - channels 1-11 (11 channels): birds.wav
% - channels 12-29 (18 channels): rain.wav
% - channels 30-53 (24 channels): thunderstorm.wav
% - channels 54-71 (18 channels): rain2.wav
% - channels 72-98 (27 channels): frogs.wav
% - channels 99-126 (28 channels): crickets.wav
% 
% Directions: defined in pos.txt
% Output: 8 wav files '\Data\output_1.wav' to '\Data\output_8.wav', to be played by the pd demo file.
%
% #Author: Michael Mihocic and Piotr Majdak (09.2017)
% #Author: Michael Mihocic: adapted to MR lab, new functions implemented/added (08.2025)
% #Author: Michael Mihocic: updated t0 141 virtual sound sources (frogs, crickets, creek) (10.2025)
% #Author: Michael Mihocic: creek removed (17.10.2025)

% 
% Copyright (C) Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.2 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: https://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 

tic
%% clean up
clc;
close all;

%% prepare
% addpath('..\Spatialization\');
load SPAT_default; % load default spatialization parameters
SOURCE=audacity2source('pos.txt','Data\merged_sources.wav'); % convert audacity WAV and Label tracks

%% check elevations
minval = zeros(1, numel(SOURCE));
for i = 1:numel(SOURCE)
    minval(i) = min(SOURCE(i).pos(:,2));
end

disp([' Min. Ele: ' num2str(round(rad2deg(min(minval)),2)) '° deg (' num2str(round(min(minval),2)) '° rad)']);
for ee = 1:length(SOURCE)
    if rad2deg(min(SOURCE(ee).pos(:,2))) < -45
        disp('###########################################');
        disp([' !!! WARNING: Elevation below -45° deg detected:']);
        disp([' !!! Min. Ele of channel ' num2str(ee) ': ' num2str(round(rad2deg(min(SOURCE(ee).pos(:,2))),2)) '° deg (' num2str(round(min(SOURCE(ee).pos(:,2)),2)) '° rad)']);
        disp('###########################################');
    end
end

%% spatialize
LS_SIGNAL = SPATIALIZE( SPAT , SOURCE, 0, 0); % spatialize
% LS_SIGNAL = SPATIALIZE( SPAT , SOURCE, 0, 1); % simulate (plot only)

if isnan(LS_SIGNAL)
    return
end

%% save 
Save_LS(SPAT, LS_SIGNAL, SOURCE(1).fs, ['output']);

toc


