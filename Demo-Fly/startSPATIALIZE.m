%% startSPATIALIZE
%
% This file is used to create a spatial simulation of a fly, buzzing around the listener. 
% The VBAP parameters are adapted to MR Lab.
%   Sources: 1
%   Directions: defined in Matlab script
%

% #Author: Michael Mihocic and Piotr Majdak (09.2017)
% #Author: Michael Mihocic: adapted to MR lab, new functions implemented/added (08.2025)
% 
% Copyright (C) Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.2 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: https://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 

%% Paths
tic
close all;
% addpath('..\Spatialization\');
% addpath('..\');
% addpath('..\..\Tools\');
% addpath('..\..\Experiments\OFFLINE_engine\');


%% Load LS positions of ARI grid
% load('ARI_LA_grid.mat','X'); % ARI LS grid
load SPAT_default; % load default spatialization parameters
% SPAT.LS = X; clear X;

%% data Source - there are two options:
% 1. load scene from GUI:
% load fly.mat; % signal and position of fly

% ... OR ...
%
% 2. create new scene:

%% load from wave and define parameters below
[SOURCE.sig, fs] = audioread('Data\fly.wav');

%% parameters
SPAT.Amb_decoder='AllRAD';
SPAT.engine='VBAP';
SPAT.buffer=64;
SPAT.Amb_N=3;
SPAT.Amb_AllRAD_N=1000;
SPAT.binaural=0;

%% positions and movement
le = length(SOURCE.sig);
azi_start = deg2rad(0); % start azi
ele_start = deg2rad(-30); % start ele
azi_rps = 0.04; % rotation speed azi
ele_rps = 0.024; % rotation speed ele
azi_mvt = linspace(azi_start , azi_start + azi_rps*2*pi*le/fs, le);
ele_mvt = linspace(ele_start , ele_start + ele_rps*2*pi*le/fs, le);
k_mvt = ones(1,le);
% wrapping
[x,y,z] = sph2cart(azi_mvt,ele_mvt,ones(size(azi_mvt)));  
[azi_mvt,ele_mvt,~] = cart2sph(x,y,z);
% all positions
SOURCE.pos = [azi_mvt; ele_mvt]';
SOURCE.pre_gain = k_mvt;

%% plot positions
% ax_mvt = axes('Parent',pan_source,'Visible','off',     'Position',[.5 .35 .5 .3],'Clipping','off');
close all; figure;
% Plot_pos(SOURCE);

if rad2deg(min(SOURCE.pos(:,2))) < -45
    disp(' ')
    disp('###########################################');
    disp('WARNING: Elevation below -45° deg detected!');   
    disp('###########################################');
    disp(' ')
end
disp([' Min. Ele: ' num2str(round(rad2deg(min(SOURCE.pos(:,2))),2)) '° deg (' num2str(round(min(SOURCE.pos(:,2)),2)) '° rad)']);

%% spatialize
% [LS_SIGNAL, BIN_SIGNAL] = SPATIALIZE( SPAT , SOURCE);
LS_SIGNAL = SPATIALIZE( SPAT , SOURCE, 0, 0); % spatialize

%% save 
% (comment the following row if you don't want to save output:)
Save_LS(SPAT, LS_SIGNAL, 48000, 'output');
