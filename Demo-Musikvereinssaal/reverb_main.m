%% reverb_main
%
% This file is used to calculate reverb parameters for Musikvereinssaal
%   Directions: defined in label track channel
%

% #Author: Piotr Majdak and Michael Mihocic (2017-2020)
% #Author: Michael Mihocic: adapted to MR lab, new functions implemented/added (08.2025)
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
addpath('..\Spatialization\');
load SPAT_default; % load default spatialization parameters

%% parameters Musikvereinssaal
if ~exist('S','var'), S=[41 9 3]; end % position of the source
if ~exist('R','var'), R=[38 9.5 3.2]; end % position of the receiver
LWH=[48.8,19.1,17.75]; % Musikvereinssaal (m)
T=0.5; % skew from the shoebox (m), front wider and rear lower by T
Omax=9; % maximum reflection order to calculate
flags='plot';
% from Beranek (1996) "Concert Halls and Opera Houses"
% f =    125  250  500  1.00 2.00 4.00
% RT60 = 2.25 2.18 2.04 1.96 1.80 1.62
RT60=2100; % reverberation time (ms)

tmix=408;       % mixing time (ms) of early reflections (mirror sources) and diffuse reverb (FDN)
tmixregion=50;  % the region within the mix happens (ms) after tmix


% loudspeaker array and signal parameters
X=SPAT.LS; % loudspeaker grid X(x,y,z)
% X=load('grid_latest.mat'); % loudspeaker grid X(x,y,z)
fs=48000; % sampling rate (Hz)
c=340; % speed of sound (m/s)


% Corners of the room
C(1,:)=[0 0 0];
C(2,:)=[LWH(1) 0 0];
C(3,:)=[LWH(1) LWH(2)-T 0];
C(4,:)=[0+T LWH(2) 0];
C(5,:)=[0 0+T LWH(3)];
C(6,:)=[LWH(1)+T 0 LWH(3)-T];
C(7,:)=[LWH(1) LWH(2) LWH(3)];
C(8,:)=[0 LWH(2)-T LWH(3)];
W=[2 1 5 6; 3 2 6 7; 4 3 7 8; 1 4 8 5; 1 2 3 4; 5 8 7 6]'; % define walls by indicies to corners


% acoustic calculations
V=prod(LWH); % approx volume of the room
Ar=2*LWH*circshift(LWH',[-1,0]); % approx surface of the room
% RT60=0.1611*V/S/(1-mean(RF))*1000; % reverberation time (ms) estimated from RFs
rH=0.057*sqrt(V/RT60*1000); % Hallradius (m)
RFall=1-0.1611*V/Ar/RT60*1000;
RF=ones(1,8)*RFall; % reflection factors of each wall


%% calculate mirror sources
if Omax>4, msflag='noplot'; else msflag='plot'; end;
Y=reverb_mirrorsources(Omax,C,W,S,R,RF,msflag); % Y=[Sx Sy Sz o s w RFcum flag]
if strcmp(msflag,'plot'), plot3(R(:,1),R(:,2),R(:,3),'d'); end
disp([num2str(size(Y,1)) ' reflections calculated.']);
%% calculate SRIRs based on mirror sources only

[~,~,avrgR] = cart2sph(X.X(:,1),X.X(:,2),X.X(:,3));
LS=[X.X; [0 0 -mean(avrgR)]]; % add a silent south pole
disp('Projecting to spatial impulse responses...');
IRm=reverb_SRIR(Y,R,c,fs,LS); % IR(ch1,ch2,chN) with N louspeakers
IRm=IRm(:,1:size(IRm,2)-1); % remove the silent loudspeaker
if strcmp(flags,'plot'),
   
  figure;
  plot(0:1000/fs:(size(IRm,1)-1)/fs*1000,etc(IRm));
  title('Mirror-source IRs');
  xlabel('Time (ms)'); ylabel('ETC (dB)');
  
  figure;
  plot(0:1000/fs:(size(IRm,1)-1)/fs*1000,etc(sum(IRm,2)));
  title('Summed mirror-source IR');
  xlabel('Time (ms)'); ylabel('ETC (dB)');

  
end
%% add diffuse tail
N=size(IRm,2); % number of channels

rng(0); % init random generator
Di=repmat(LWH,1,ceil(N/3))/c*1000;
Ds=Di(1:N)+rand(1,N)*20;
Ds=rand(1,N)*(max(LWH)-min(LWH))+min(LWH);


G=exp(-3*log(10)/(RT60/min(Ds))); % estimate decay
T=randn(N,N);
[Au,~,~]=svd(T);
A=G*Au;


disp('Calculating diffuse field responses...');
IRd=reverb_fdn([1,zeros(1,N-1)],A,Ds,RT60*1.5,fs);
%% plot the diffuse IR
if strcmp(flags,'plot'),
    figure;
    plot(0:1000/fs:(size(IRd,1)-1)/fs*1000,etc(sum(IRd,2)));
    title('Summed diffuse IR');
    xlabel('Time (ms)'); ylabel('ETC (dB)');
    
    figure;
    plot(0:1000/fs:(size(IRd,1)-1)/fs*1000,etc(IRd));
    title('Diffuse IRs');
    xlabel('Time (ms)'); ylabel('ETC (dB)');

end
%% compare the spatial distributions to estimate the mixing region
if strcmp(flags,'plot'),
    y=resample(IRm,fs/10,fs);
    figure;
    pcolor(0:10000/fs:(size(y,1)-1)/fs*10000,1:N,etc(y(1:size(y,1),:))')
    shading interp
    xlabel('Time (ms)');
    ylabel('Loudspeaker index');
    title('Mirror sources only');
    figure;
    yd=resample(IRd,fs/10,fs);
    pcolor(0:10000/fs:(size(yd,1)-1)/fs*10000,1:N,etc(yd(1:size(yd,1),:))');
    shading interp
    xlabel('Time (ms)');
    ylabel('Loudspeaker index');
    title('FDN only');

    figure; hold on;
    plot(0:10000/fs:(size(y,1)-1)/fs*10000,std(etc(y./repmat(sum(y.*y,2),1,N))'))
    plot(0:10000/fs:(size(yd,1)-1)/fs*10000,std(etc(yd./repmat(sum(yd.*yd,2),1,N))'),'r')
    legend('Mirror only','FDN based on mirror');
    title('Normalized STD across loudspeakers');
end
%% mix mirror sources (IRm) with FDN (IRd) beginning from tmix
% tmix=20*V/Ar+12; % mixing time (ms), see Lindau A. Lindau,“Perceptual evaluation of physical predictors of the mixing time in binaural room impulse responses,” Proc. AES 128th Conv., London, UK, 2010.
disp('Mixing...');

Nmix=round(tmix/1000*fs); % tmix in samples
Nmixregion=round(tmixregion/1000*fs); % Nmixregion in samples
% IRmo = fade(IRm(1:Nmix+Nmixregion,:), size(IRd,1), 0, Nmix);
IRmo = fade(IRm(1:Nmix+Nmixregion,:), size(IRd,1), 0, 0);
% IRdo = fade(IRd(Nmix+1:end,:), 0, Nmixregion, 0, -Nmix);
IRdo = fade(IRd(Nmix+1-Nmixregion:end,:), 0, Nmixregion, 0, -Nmix+Nmixregion);
IRt=IRmo+IRdo;
%% Plot mixes
if strcmp(flags,'plot'),
  
    figure;
    plot(0:1000/fs:(size(IRdo,1)-1)/fs*1000,etc(IRdo));
    title('Diffuse IRs faded'); ylim([-80 5]);
    xlabel('Time (ms)'); ylabel('ETC (dB)');

    figure;
    plot(0:1000/fs:(size(IRmo,1)-1)/fs*1000,etc(IRmo));
    title('Mirror-sources IRs faded'); ylim([-80 5]);
    xlabel('Time (ms)'); ylabel('ETC (dB)');
    
    yo=resample(IRmo,fs/10,fs);
    figure;
    pcolor(0:10000/fs:(size(y,1)-1)/fs*10000,1:N,etc(yo(1:size(y,1),:))')
    shading interp
    xlabel('Time (ms)');
    ylabel('Loudspeaker index');
    title('Mirror sources only');

    ydo=resample(IRdo,fs/10,fs);
    figure;
    pcolor(0:10000/fs:(size(y,1)-1)/fs*10000,1:N,etc(ydo(1:size(y,1),:))')
    shading interp
    xlabel('Time (ms)');
    ylabel('Loudspeaker index');
    title('FDN only');

    yto=resample(IRt,fs/10,fs);
    figure;
    pcolor(0:10000/fs:(size(y,1)-1)/fs*10000,1:N,etc(yto(1:size(y,1),:))')
    shading interp
    xlabel('Time (ms)');
    ylabel('Loudspeaker index');
    title('Total mix');

    figure;
    plot(0:1000/fs:(size(IRt,1)-1)/fs*1000,etc(IRt));
    title('Final IRs'); ylim([-80 5]);
    xlabel('Time (ms)'); ylabel('ETC (dB)');
    
    figure;
    plot(0:1000/fs:(size(IRt,1)-1)/fs*1000,etc(sum(IRt,2)));
    title('Final summed IR'); ylim([-80 5]);
    xlabel('Time (ms)'); ylabel('ETC (dB)');    
end
%% Saving
% disp('Saving...');
% save([mfilename ' ' num2str(RT60) ' ' strrep(datestr(now),':','-')],'Y','W','T','S','RT60','R','Omax','LWH','C','IRm','IRd','IRt','-v7.3');
clear y* IRdo IRmo
% save([mfilename ' ' num2str(S) '.mat'],'-v7.3');

toc;
disp('Done.');