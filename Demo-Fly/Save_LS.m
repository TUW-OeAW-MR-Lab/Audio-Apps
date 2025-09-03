function Save_LS(SPAT, LS_SIGNAL, fs, fn)
% Save 192 loudspeaker signals to 8 WAV files for MR Lab demos

% #Author: Piotr Majdak: adapted from F. Zagalas GUI (12.09.2017)
% #Author: Michael Mihocic: header documentation updated (28.10.2021)
% #Author: Michael Mihocic: adaptions for 192 channels (MR Lab) (08-09.2025)
% 
% Copyright (C) Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.2 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: https://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 

if ~exist('fn','var')
    [fn , dir_save] = uiputfile('*.wav');
    if isequal(fn,0) || isequal(dir_save,0)
        error('file won''t be saved. You must enter a correct filename and a directory.');
    end
    SPAT.filename1 = [dir_save fn];
    [pa,na,ext]=fileparts(SPAT.filename1);
else
    [pa,na]=fileparts(fn);
    ext='wav';
end
OutGain = 1/max(abs(LS_SIGNAL(:)));

na=['Data\' na]; % output folder
% readsf~ in Pd doesn't work for high-multi-channels .wav-files -> decompose to 8 .wav-files à 24 channels
disp(['Saving ' fullfile(pa,[na '_1.' ext])]);
audiowrite(fullfile(pa,[na '_1.' ext]) , OutGain.*LS_SIGNAL(:,1:24) , fs);
disp(['Saving ' fullfile(pa,[na '_2.' ext])]);
audiowrite(fullfile(pa,[na '_2.' ext]) , OutGain.*LS_SIGNAL(:,25:48) , fs);
disp(['Saving ' fullfile(pa,[na '_3.' ext])]);
audiowrite(fullfile(pa,[na '_3.' ext]) , OutGain.*LS_SIGNAL(:,49:72) , fs);
disp(['Saving ' fullfile(pa,[na '_4.' ext])]);
audiowrite(fullfile(pa,[na '_4.' ext]) , OutGain.*LS_SIGNAL(:,73:96) , fs);
disp(['Saving ' fullfile(pa,[na '_5.' ext])]);
audiowrite(fullfile(pa,[na '_5.' ext]) , OutGain.*LS_SIGNAL(:,97:120) , fs);
disp(['Saving ' fullfile(pa,[na '_6.' ext])]);
audiowrite(fullfile(pa,[na '_6.' ext]) , OutGain.*LS_SIGNAL(:,121:144) , fs);
disp(['Saving ' fullfile(pa,[na '_7.' ext])]);
audiowrite(fullfile(pa,[na '_7.' ext]) , OutGain.*LS_SIGNAL(:,145:168) , fs);
disp(['Saving ' fullfile(pa,[na '_8.' ext])]);
audiowrite(fullfile(pa,[na '_8.' ext]) , OutGain.*LS_SIGNAL(:,169:end) , fs);