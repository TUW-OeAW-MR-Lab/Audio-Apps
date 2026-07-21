% #Author: Michael Mihocic

clear;

% 1. Read both WAV files
[y1, fs1] = audioread('Data\source channels 1-71.wav');
[y2, fs2] = audioread('Data\source channels 72-95.wav');

% 2. Match sample rates if they differ
if fs1 ~= fs2
    y2 = resample(y2, fs1, fs2);
end

% 3. Match track length (pad shorter file with zeros)
len1 = size(y1, 1);
len2 = size(y2, 1);

if len1 < len2
    y1(len1+1:len2, :) = 0; % Pad y1 to match len2
elseif len2 < len1
    y2(len2+1:len1, :) = 0; % Pad y2 to match len1
end

% 4. Combine channels side-by-side (e.g. 8 + 16 = 24 channels)
y_merged = [y1, y2];

% 5. Save the output file
audiowrite('Data\source.wav', y_merged, fs1);
disp(['Files combined to ', num2str(size(y_merged, 2)), ' channels and saved successfully.']);

return;


%% OLD CODE

% [b, FS]=audioread('Data\birds.wav');
% [r1]=audioread('Data\rain.wav');
% [t]=audioread('Data\thunderstorm.wav');
% 
% [r2]=audioread('Data\rain2.wav'); 
% 
% % Y=Y1;
% 
% Y=zeros (size( b,1),size(b,2)+size(r1,2)+size(r2,2), size (r1,3)); % prepare output
% 
% Y(:,1:size(b,2),:)=b(:,:,:); % add birds
% Y(:,(size(b,2)+1):(size(b,2)+size(r1,2)),:)=r1(:,:,:); % add rain
% Y(:,(size(b,2)+size(r1,2)+1):(size(b,2)+size(r1,2)+size(t,2)),:)=t(:,:,:); % add thunderstorm
% 
% audiowrite('Data\source3.wav',Y,FS);
% disp('completed');




% Load audio files
[birds, FS]    = audioread('Data\birds.wav');
[rain]         = audioread('Data\rain.wav');
[thunderstorm] = audioread('Data\thunderstorm.wav');
[rain2]        = audioread('Data\rain2.wav');

% --- Find maximum length ---
maxlen = max([size(birds,1), size(rain,1), size(thunderstorm,1), size(rain2,1)]);

% --- Pad with zeros to same length ---
birds        = [birds;       zeros(maxlen - size(birds,1),       size(birds,2))];
rain         = [rain;        zeros(maxlen - size(rain,1),        size(rain,2))];
thunderstorm = [thunderstorm;zeros(maxlen - size(thunderstorm,1),size(thunderstorm,2))];
rain2        = [rain2;       zeros(maxlen - size(rain2,1),       size(rain2,2))];

% --- Concatenate channels side by side ---
mix = [birds rain thunderstorm rain2];

% --- Optional: normalize ---
if max(abs(mix(:))) > 0
    mix = mix ./ max(abs(mix(:)));
end

% --- Save multichannel WAV ---
audiowrite('Data\nature_multichannel.wav', mix, FS);

disp(['Final mix saved with ' num2str(size(mix,2)) ' channels.']);






% Load audio files
[birds, FS]        = audioread('Data\birds.wav');
[rain]             = audioread('Data\rain.wav');
[thunderstorm]     = audioread('Data\thunderstorm.wav');
[rain2]            = audioread('Data\rain2.wav');
[frogs]            = audioread('Data\frogs.wav');
[crickets]         = audioread('Data\crickets.wav');
[creek]            = audioread('Data\creek.wav');

% --- Find maximum length across all files ---
maxlen = max([ ...
    size(birds,1), size(rain,1), size(thunderstorm,1), ...
    size(rain2,1), size(frogs,1), size(crickets,1), size(creek,1) ]);

% --- Pad each file with zeros to same length ---
birds        = [birds;       zeros(maxlen - size(birds,1),       size(birds,2))];
rain         = [rain;        zeros(maxlen - size(rain,1),        size(rain,2))];
thunderstorm = [thunderstorm;zeros(maxlen - size(thunderstorm,1),size(thunderstorm,2))];
rain2        = [rain2;       zeros(maxlen - size(rain2,1),       size(rain2,2))];
frogs        = [frogs;       zeros(maxlen - size(frogs,1),       size(frogs,2))];
crickets     = [crickets;    zeros(maxlen - size(crickets,1),    size(crickets,2))];
creek        = [creek;       zeros(maxlen - size(creek,1),       size(creek,2))];

% --- Concatenate all channels side by side ---
mix = [birds rain thunderstorm rain2 frogs crickets creek];

% --- Optional: normalize (to avoid clipping) ---
if max(abs(mix(:))) > 0
    mix = mix ./ max(abs(mix(:)));
end

% --- Save multichannel WAV ---
audiowrite('Data\nature_multichannel.wav', mix, FS);

disp(['Final mix saved as Data\nature_multichannel.wav with ' num2str(size(mix,2)) ' channels.']);
