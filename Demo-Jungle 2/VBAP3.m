function GAIN = VBAP3( X, TR , sig, azi , ele , R, varargin)
%calculates the feeding signal for each loudspeaker (GAIN) for virtual
%source position of unit spherical coordinates (azi, ele) and mono signal
%sig, for given loudspeaker position X.
%
% MANDATORY PARAMETERS:
% X         coordinates of the looudspeakers (cartesian)
% sig       vector containing the mono signal
% azi,ele   position of the virtual source in radian (vectors) the length
%           should fit to the length of sig
%
% OPTIONAL PARAMETERS:
%   'silentSouthPole'   includes a silent loudspeaker at southpole to
%                       optimize auralization of virtual sources near south
%   'buffer',lebuffer   same position of all samples in same buffer 
%                       e.g. VBAP3(X,sig,-pi/4,pi/3,'buffer',64)
%
% please feel free to implement the algo, could be way more efficient, sorry have no time ;)
%
%   (c) Franck ZAGALA - franckzagala@gmail.com - 02.05.2017


if any(strcmp(varargin,'silentSouthPole'))
    [~,~,avrgR] = cart2sph(X(:,1),X(:,2),X(:,3));
    X = [X ; [0 0 -mean(avrgR)]]; % add silent south pole for energy conservation
end

% DT = delaunayTriangulation(X);
% TR = freeBoundary(DT); % set of triangular facets

GAIN = zeros(size(X,1) , length(azi)); % init output signal

[x,y,z] = sph2cart(azi,ele,R*ones(size(azi))); 
p = [x,y,z]'; % cartesian coord. of source
plot3(x,y,z, ...
      'ok','MarkerSize',10,'MarkerFaceColor',[1 0 0]);

for ii = 1:size(TR,1) % Oisition matrix of 3 LS for each facet
   L(:,:,ii) =  [X(TR(ii,1),:) ; X(TR(ii,2),:) ; X(TR(ii,3),:)];
end

if any(strcmp(varargin,'buffer')) % if buffer
    lebuffer = varargin{find(strcmp(varargin,'buffer'))+1}; % length buffer in sample
    if abs(round(lebuffer)) ~= lebuffer;
        lebuffer = 1;
        warning(['wrong value for buffer ->must be positive integer and'... 
            'positioned just after argument ''buffer''. Bufferlength'... 
            ' set to 1'])
    end
else 
    lebuffer = 1;
end

lastii = 1;
for t = 1:lebuffer:length(azi)
    FACET = [];
    G = [];
    for ii = [lastii [1:size(TR,1)]] % check first the facet of last sample
        g = p(:,t)'*inv(squeeze(L(:,:,ii))); % p is col -> p' is row
        if isempty(find(g<0)) % select facet, when no gain negative
            FACET = TR(ii,:);
            G = g./sqrt(sum(g.^2));
            lastii = ii;
            break 
        end
    end
    
    GG = zeros(size(X,1),1);
    if t <= length(sig)-(lebuffer-1) 
        for tt = t:t+lebuffer-1 % for all sample of buffer
            GG(FACET) = G.*sig(tt);
            GAIN(:,tt) = GG;
        end
    else
        for tt = t:length(sig) % for all samples of last buffer if not full
            GG(FACET) = G.*sig(tt);
            GAIN(:,tt) = GG;
        end
    end

end
end

