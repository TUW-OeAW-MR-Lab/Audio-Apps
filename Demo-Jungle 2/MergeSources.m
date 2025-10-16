clear;

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
outfile = 'Data\merged_sources.wav';
audiowrite(outfile, mix, FS);

% --- Report channel counts with ranges ---
channels = [size(birds,2), size(rain,2), size(thunderstorm,2), ...
            size(rain2,2), size(frogs,2), size(crickets,2), size(creek,2)];
files    = {'birds.wav','rain.wav','thunderstorm.wav','rain2.wav', ...
            'frogs.wav','crickets.wav','creek.wav'};

disp(['Final mix saved as ' outfile ' with ' num2str(size(mix,2)) ' channels.']);

% --- Write log file ---
logfile = 'Data\merged_sources.log';
fid = fopen(logfile, 'w');
fprintf(fid, 'Final mix saved as %s with %d channels.\n\n', outfile, size(mix,2));

startIdx = 1;
for k = 1:numel(files)
    chCount = channels(k);
    endIdx = startIdx + chCount - 1;
    line = sprintf('- channels %d-%d (%d channels): %s\n', startIdx, endIdx, chCount, files{k});
    fprintf(fid, '%s', line);   % write to log file
    fprintf('%s', line);        % also print to console
    startIdx = endIdx + 1;
end
fclose(fid);

disp(['Channel mapping written to ' logfile]);
