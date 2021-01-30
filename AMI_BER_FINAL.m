%%
%   Ενσωματωμένα Επικοινωνιακά Συστήματα


close all;
clear all;
clc;

%%      Parameters
    Nbits = 1000;            % Number of bits generated
    Rbits = 1000;            % bps
    Ts = 1/Rbits;

    
 % SNR
 
    SNR = [5 6 7 8 9 10 11 12 ]; 
    lenSNR = length(SNR);
    Nthres = 100;

     
%  RRC filter
    rr = 0.35;                   %  RRC roll-off factor
    Nup = 4;                     %  Upsampling rate
    rgd = 4;                     %  RRC group delay
    Rsam = Nup*Rbits;
    Nb2d = 1;                    %  sample to start down-sampling
                                 %  valid values:   1:Nup

    Npre = 2*rgd*Nup;            % Length of preamble bits
    pre_pat = zeros(1,Npre);     %  create the preamble pattern
    pre_pat(1:2:Npre) = 1;
    pre_pat(Npre) = 1;

%  DAC
    Bdac = 8;
    DRdac = 2;               %  DAC dynamic range,  in Volts

%   Arrays initialization

    errors = zeros(1, lenSNR);
    Ber = zeros(1,lenSNR);
    
    Sym = zeros(Nbits,1);
    Sam_dac = zeros(Nbits*Nup,1);

%   Calculate RRC coefficients
    disp('SRRC filter - Channel output');
    rcosSpec = fdesign.pulseshaping(Nup, 'Square Root Raised Cosine', 'Nsym,beta', 2*rgd, rr);
    rcosFlt = design(rcosSpec); 
    rcosFltcoefs = rcosFlt.Numerator/max(rcosFlt.Numerator);
        


%%       Modulator Model
disp('AMI Modulator ....');
disp(' ');

for m=1:lenSNR
    cnt = 0;
    fprintf('\nSNR = %3.2f dB', SNR(m)); 
    
    while errors(m) < Nthres
        
        cnt=cnt+1;
                
        Sym = zeros(Nbits,1);
        Sam_dac = zeros(Nbits*Nup,1);
    

        for ns = 1:(Nbits+Npre)
            if ns <= Npre
                Bits(ns) = pre_pat(ns);
            else
                Bits(ns) =  randi([0, 1]);              % New bit
            end
            
            %  ΑΜΙ modulation
            
            flag=0;
            
            for i=1:length(Bits)
                if Bits(i)==0
                    Sym(i)=0;
                else
                    if flag==0
                        Sym(i)=1;
                        flag=1;
                    else
                        Sym(i)=-1;
                        flag=0;
                    end
                end
            end
            
            %RRC
            
            SNup(2*Nup*rgd+(ns-1)*Nup+1:2*Nup*rgd+ns*Nup) = [Sym(ns) zeros(1, Nup-1)];         %  Insert  (Nup-1) zeros
            for mn=1:Nup                                                                                                                         %  Pulse shape  (Direct FIR)
                len = 2*Nup*rgd+ns*Nup;
                tmp = SNup(len+mn-Nup-2*Nup*rgd:len+mn-Nup);
                Sam_dac((ns-1)*Nup+mn) = sum(tmp.*rcosFltcoefs);
            end
            
        end
        Sam_dac = Sam_dac';
        
        %%   Channel
        
        Ps = sum(Sam_dac.^2)/length(Sam_dac);
        
        
        Pn = Ps/(10^(SNR(m)/10));
        
        ch_noise = sqrt(Pn)*(sqrt(2*log(1./(1-rand(1,length(Sam_dac)))))).*cos(2*pi*rand(1,length(Sam_dac)));
        
        %     fprintf('\nAWGN noise added. SNR = %3.1f dB', 10*log10(Ps/Pn));
        
        Sam_adc = Sam_dac + ch_noise;
        
        
        
        %%    Rx
        Sam_rrc = filter(rcosFltcoefs, 1, Sam_adc);
        
        
        %% Inverse AMI
        
        sym_rx = Sam_rrc(Nb2d:Nup:end);
               
        sym_rx2=sym_rx;
        
        
        for ns=1:length( sym_rx2);
            abs1=abs( sym_rx2(ns)+1);
            abs2=abs( sym_rx2(ns));
            abs3=abs( sym_rx2(ns)-1);
            y=min([abs1 abs2 abs3]);
            if y==abs1
                sym_rx2(ns)=-1;
                
            elseif y==abs2
                sym_rx2(ns)=0;
            else
                sym_rx2(ns)=1;
            end
        end
        
        
        for j=1:length( sym_rx2)
            if  sym_rx2(j)==0
                bits_rx(j)=0;
            else
                bits_rx(j)=1;
            end
        end
      %%  
        %Συσχέτιση
        
        
        t1 = (0:length(Bits)-1)/Rbits;
        t2 = (0:length(bits_rx)-1)/Rbits;
        
        
        [acor,lag] = xcorr(Bits,bits_rx);
        
        [~,I] = max(abs(acor));
        
        lagDiff = lag(I);
        
        timeDiff = lagDiff/Rbits;
        
        BitsExcor = bits_rx(abs(lagDiff)+1:end);
    %%    
        sum2=0;
        
        for ns=1:length(BitsExcor)
            sum2=sum2+bitxor(BitsExcor(ns),Bits(ns));
        end
        
        errors(m) = errors(m) + sum2;

    end
        %Ber
        
     Ber(m) = errors(m)/(cnt*Nbits);
     
    fprintf('   BER = %3.2e', Ber(m));
    fprintf('   No of Bits = %d     Errors = %d\n', cnt*Nbits, errors(m));
      

end   
        %%  Display
        % %   Scope
        %
        % %  fprintf('\nSNR = %3.1d dB',SNR);
        %
        %
        % scrsz = get(0,'ScreenSize');
        % figure('Position', [50 50 scrsz(3)-100  scrsz(4)-200]);
        % set(gcf, 'color', 'white');
        % FontSize = 11;
        % set(gcf,'DefaultLineLineWidth',1);
        % set(gcf,'DefaultTextFontSize', FontSize, 'DefaultAxesFontSize', FontSize, 'DefaultLineMarkerSize', FontSize);
        %
        %
        %
        % ax(1) = subplot(6,1,1);
        % stem((0:length(Sym)-1)*Ts, Bits);
        % ylabel('Bits');
        % title(['SNR = ',num2str(SNR)]);
        %
        % grid on
        %
        % ax(2) = subplot(6,1,2);
        % stem((0:length(Sym)-1)*Ts, Sym);
        % ylabel('Sym');
        % grid on
        %
        % ax(3) = subplot(6,1,3);
        % plot((0:length(Sam_dac)-1)*Ts/Nup, Sam_dac);
        % hold on;
        % plot((0:length(Sam_adc)-1)*Ts/Nup, Sam_adc, '-r');
        %
        % legend('Sam dac','Sam adc');
        %
        % grid on
        %
        % ax(4) = subplot(6,1,4);
        % plot((0:length(Sam_rrc)-1)*Ts/Nup, Sam_rrc, '-o', 'MarkerSize', 4);
        % ylabel('Sam rrc');
        %
        % grid on
        %
        % ax(5) = subplot(6,1,5);
        % stem((0:length(sym_rx)-1)*Ts, sym_rx2);
        % ylabel('Sym rx');
        %
        % grid on
        %
        % ax(6) = subplot(6,1,6);
        % stem((0:length(BitsExcor)-1)*Ts, BitsExcor);
        % ylabel('BitsExcor');
        % grid on
        %
        %
        %
        % linkaxes(ax,'x');
        
    
%%


%   Scope

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(4)/20 scrsz(4)/8 scrsz(3)/2  6*scrsz(4)/8]);
set(gcf, 'color', 'white');
FontSize = 13;
set(gcf,'DefaultLineLineWidth',2);
set(gcf,'DefaultTextFontSize', FontSize, 'DefaultAxesFontSize', FontSize, 'DefaultLineMarkerSize', FontSize);

semilogy(SNR, Ber, '.-');
grid on;
axis([min(SNR)-1 max(SNR)+1 1e-6 1]);
xlabel('SNR [dB]');
ylabel('BER');
text(4.2, 0.014, 'AMI', 'Color', 'b')







