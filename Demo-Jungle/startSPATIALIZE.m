%% startSPATIALIZE
%
% This file is used to create a spatial simulation of birds, rain and thunder.
% The VBAP parameters are adapted to MR Lab.
%       Sources  1-11: birds
%       Sources 12-29: rain
%       Sources 30-53: thunder
%       Sources 54-71: rain
%       Sources 72-95: frogs & crickets

%   Directions: defined in pos.txt
%

% #Author: Michael Mihocic and Piotr Majdak (09.2017)
% #Author: Michael Mihocic: adapted to MR lab, new functions implemented/added (08.2025)
% #Author: Michael Mihocic: frogs & crickets added (07.2026)
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
SOURCE=audacity2source('pos.txt','Data\source.wav'); % convert audacity WAV and Label tracks

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


