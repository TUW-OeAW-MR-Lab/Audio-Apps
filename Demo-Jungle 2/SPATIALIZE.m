function [LS_SIGNAL, BIN_SIGNAL] = SPATIALIZE( SPAT , SOURCE, Obj, simulate )
% Creates and plays 3D-rendered-audio scene described by audio-objects
% SOURCE(idx), using the engine described by SPAT.
% If binaural rendering, Obj is a SOFA-object detaining the HRTFs.
%
% SPAT - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   SPAT.engine                     type of engine: 'Ambisonics','VBAP','nearest neighbour',...
%   SPAT.buffer                     buffer length for common position in samples (low=precision but slow vs. high=quick encoding but artefacts)
%   SPAT.Amb_decoder                Ambisonics decoder: 'AllRAD','Direct' (only make sense when SPAT.engine = 'Ambisonics')
%   SPAT.Amb_N                      Ambisonics max-order: int (only make sense when SPAT.engine = 'Ambisonics')
%   SPAT.Amb_AllRAD_N               number of virtual loudspeaker for AllRAD decoding
%   SPAT.LS                         Position of loudspeakers Lx3-matrix (cartesian coordinates)
%   SPAT.binaural                   wether the Loudspeaker signals should be binaural rendered or not (true / false)
%   SPAT.save                       wether the output signals have to be saved
%   SPAT.filename1                  filename for saving LS signal
%   SPAT.filename2                  filename for saving binaural signal
% Obj - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   Obj                             SOFA object, optional (see 'http://www.sofacoustics.org')
% SOURCE(idx) - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   SOURCE(idx).sig                 mono signal vector
%   SOURCE(idx).fs                  sampling frequency
%   SOURCE(idx).pos                 length(sig)x2 Position matrix (azimuth,elevation) along the signal
%   SOURCE(idx).pre_gain            pre gain along the signal (vector)
%
% Dependencies:
%   -sh_matrix_real.m                 for Spherical Harmonics Transform
%   -VBAP3.m                        for Vector Based Amplitude Panning
%   -Load_LS_HRIR.m                 to get HRIR at loudpseaker Position
%
%   Please feel free to implement the algo, calculation not very efficient
%   yet :/, sorry, no time !
%
% (c) Franck Zagala - franckzagala@gmail.com - 06.2017
%  12.9.2017 Piotr Majdak - SOFA Obj optional


%%% Display SPAT mode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp **********************************;
disp(SPAT)
disp **********************************;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Auralization of the source(s) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Length of output signal
lengthsources = [];
for s = 1:length(SOURCE)
    lengthsources = [lengthsources,size(SOURCE(s).sig,1)];
end
max_length = max(lengthsources); clear lengthsources s;


switch SPAT.engine
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % AMBISONICS  % % % % % % % % % % % % % % % % % % % %
    case 'Ambisonics' % % % % % % % % % % % % % % % % % % % % % % % % % % %

        % Encoding
        disp(' ')
        disp('...encoding...')
        AMB_SIG = zeros((SPAT.Amb_N+1)^2,max_length);
        for snbr = 1:length(SOURCE)
            sig = SOURCE(snbr).sig;
            azi_mvt = SOURCE(snbr).pos(:,1);
            ele_mvt = SOURCE(snbr).pos(:,2);
            k_mvt = SOURCE(snbr).pre_gain;

            Amb_sig = zeros((SPAT.Amb_N+1)^2 , length(sig));
            % grouping neighboring samples at same position
            for t = 1:SPAT.buffer:length(sig)
                % encoding-vector for current buffer:
                YY = sh_matrix_real(SPAT.Amb_N,azi_mvt(t),pi/2-ele_mvt(t))';
                if t <= length(sig)-(SPAT.buffer-1) % if current buffer complete
                    for tt = t:t+(SPAT.buffer-1) % use same encoding vector for whole buffer
                        Amb_sig(1:(SPAT.Amb_N+1)^2,tt) = k_mvt(tt)*sig(tt)*YY;
                    end
                else
                    for tt = t:length(sig) % last buffer may be shorter
                        Amb_sig(1:(SPAT.Amb_N+1)^2,tt) = k_mvt(tt)*sig(tt)*YY;
                    end
                end
            end
            AMB_SIG = AMB_SIG + [Amb_sig , zeros((SPAT.Amb_N+1)^2,max_length-size(Amb_sig,2))];
            clear Am_sig t tt
        end
        disp('AMBISONICS SIGNAL GENERATED')

        %Decoding
        disp(' ')
        disp('...generating Decoding Matrix...')
        switch SPAT.Amb_decoder
            case 'Direct'
                D = Amb_Decoder( SPAT.LS , SPAT.Amb_N );
            case 'AllRAD'
                D = Amb_Decoder( SPAT.LS , SPAT.Amb_N , 'AllRAD' , SPAT.Amb_AllRAD_N);
        end
        disp('DECODING MATRIX GENERATED')
        disp(' ')
        disp('...decoding ambisonics signal...')
        G = D*AMB_SIG;
        disp('LOUDSPEAKER''S FEEDING SIGNALS ARE READY!')
        disp(' ')


        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        % % % % % % % % % % VBAP  % % % % % % % % % % % % % % % % % % % % % % %
    case 'VBAP' % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        disp('...Spatializing using VBAP...')

        % add silent pole
        [~,~,avrgR] = cart2sph(SPAT.LS(:,1),SPAT.LS(:,2),SPAT.LS(:,3));
        SPAT.LS = [SPAT.LS ; [0 0 -mean(avrgR)]]; % add silent south pole for energy conservation
        X=SPAT.LS;
        DT = delaunayTriangulation(X);
        TR = freeBoundary(DT); % set of triangular facets

        % if plotSpeakers==1 % plot
            % plot
            idx=1:size(X,1);
            Xi=X(idx,:);
            trisurf(TR, X(:,1), X(:,2), X(:,3), 'FaceColor', 'w','EdgeColor','b', 'FaceAlpha',0.5);
            axis equal
            view(0,0); hold on;
            for ii=1:length(idx)
                plot3(Xi(ii,1),Xi(ii,2),Xi(ii,3), ...
                    'ok','MarkerSize',10,'MarkerFaceColor',[0 0 0]);
                hold on;
            end
        % end

        if simulate~=1 % simulate not
            G = zeros(size(SPAT.LS,1), max_length);

            for snbr = 1:length(SOURCE)
                g = VBAP3(SPAT.LS, TR, SOURCE(snbr).sig, SOURCE(snbr).pos(:,1) , ...
                    SOURCE(snbr).pos(:,2), 5, 'buffer',SPAT.buffer);
                % g = VBAP3(SPAT.LS, SOURCE(snbr).sig, SOURCE(snbr).pos(:,1) , ...
                %     SOURCE(snbr).pos(:,2) ,'silentSouthPole','buffer',SPAT.buffer);
                G = G + [g(1:size(SPAT.LS,1),:) , zeros(size(SPAT.LS,1), max_length-size(g,2))];
            end
        end

        disp('LOUDSPEAKER''S FEEDING SIGNALS ARE READY!')
        disp(' ')


        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        % % % % % % % % % % NEAREST NEIGHBOR  % % % % % % % % % % % % % % % % %
    case 'Nearest Neighbour'  % % % % % % % % % % % % % % % % % % % % % % %

        disp('Nearest Neighbour not implemented yet!')

        G = zeros(size(SPAT.LS,1), length(sig));
        disp(' ')
end

if simulate~=1 % simulate not
    LS_SIGNAL = G';
else
    LS_SIGNAL = nan;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BINAURAL RENDERING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get HRIR of Loudspeakers Position
if SPAT.binaural == true && exists('Obj','var')
    disp('...binaural rendering...')
    for snbr = 1:length(SOURCE)
        if SOURCE(snbr).fs ~= Obj.Data.SamplingRate
            warning(['At least one signal does not have the same samplig'...
                'rate than HRTF !!'])
            break;
        end
    end
    HRIR = Load_LS_HRIR( Obj , SPAT.LS );
    HRIR_L = squeeze(HRIR(:,1,:));
    HRIR_R = squeeze(HRIR(:,2,:));
    clear HRIR

    % Filtering
    nges = size(G,2) + size(HRIR_L,2);

    L_sig = zeros(nges,1);
    R_sig = L_sig;
    for ls = 1:size(SPAT.LS,1)
        L_sig = L_sig + real(ifft(fft(G(ls,:),nges).*fft(HRIR_L(ls,:)...
            ,nges)))';
        R_sig = R_sig + real(ifft(fft(G(ls,:),nges).*fft(HRIR_R(ls,:)...
            ,nges)))';
    end
    Bin_sig = [L_sig,R_sig];
    Bin_sig = Bin_sig./max(Bin_sig(:));
    clear L_sig R_sig ls nges

    disp('BINAURAL SIGNAL READY')

    sound(Bin_sig, Obj.Data.SamplingRate);
    BIN_SIGNAL = Bin_sig;

else
    BIN_SIGNAL = [];
end




end

