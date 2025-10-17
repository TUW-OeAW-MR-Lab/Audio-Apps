%   Sources: 53
%       Sources  1-11: birds
%       Sources 12-29: rain
%       Sources 30-53: thunder
%       Sources 54-71: rain

clc;
% for ii=1:11 % create random positions: birds
%     rng('shuffle');
%     azi1 = round(rand*720-360,0);
%     ele1 = round(rand*135-45,0);
% 
%     rng('shuffle');
%     azi2 = round(rand*720-360,0);
%     ele2 = round(rand*135-45,0);
% 
%     %     disp([num2str(azi) ', ' num2str(ele)]);
% 
%     % pretext=['<labeltrack name="Label Track' num2str(ii) '" numlabels="2" height="73" minimized="0" isSelected="0">'];
%     % row1=['<label t="0" t1="0" title="#' num2str(ii) ':' num2str(azi1) ',' num2str(ele1) '"/>'];
%     % row2=['<label t="44" t1="44" title="' num2str(azi2) ',' num2str(ele2) '"/>'];
% 
%     disp('	');
%         disp(['	'   num2str(ii)]);
%     disp (pretext)
%     disp (['	'   row1])
%     disp (['	'   row2])
%     disp ('</labeltrack>')
% end


for ii=1:11 % create random positions for label tracks: birds
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*115-25,0); % ele range: -25-90

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*115-25,0); % ele range: -25-90

    disp(['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]);
    disp(['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]); % if moving
    % 0.000000	0.000000	#1: 90,70
end

for ii=12:29 % create random positions for label tracks: rain
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 =  round(rand*45+20,0); % ele range: 20-65

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*45+25,0); % ele range: 25-70

    disp(['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]);
    disp(['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]); % if moving
    % 0.000000	0.000000	#1: 90,70
end

for ii=30:53 % create random positions for label tracks: thunder
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*115-25,0); % ele range: -25-90

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 = round(rand*115-25,0); % ele range: -25-90

    disp(['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]);
    disp(['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]); % if moving
    % 0.000000	0.000000	#1: 90,70
end

for ii=54:71 % create random positions for label tracks: rain
    rng('shuffle');
    azi1 = round(rand*720-360,0);
    ele1 = round(rand*45+35,0); % ele range: 35-80

    rng('shuffle');
    azi2 = round(rand*720-360,0);
    ele2 =  round(rand*45+20,0); % ele range: 20-65

    disp(['0.000000	0.000000	#' num2str(ii) ': ' num2str(azi1) ',' num2str(ele1)]);
    disp(['49.000000	49.000000	' num2str(azi2) ',' num2str(ele2)]); % if moving
    % 0.000000	0.000000	#1: 90,70
end