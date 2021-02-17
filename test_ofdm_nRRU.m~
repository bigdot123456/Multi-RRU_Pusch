%% test OFDM signal
N=4096;
M=3276;
N_cp=288;
N_guard=(N-M)/2;
y=1:M;
z=y+1i*y;

x_gb = [zeros(1,N_guard), z, zeros(1,N_guard)];
x_ifft= ifft(ifftshift(x_gb)) * sqrt(N);
x_ofdma=zeros(1,N_cp+N);
x_ofdma(1:N_cp)=x_ifft(end-N_cp+1:end);
x_ofdma(N_cp+1:end)=x_ifft;
    
%% multi path


%% demodulate
x_ofdm