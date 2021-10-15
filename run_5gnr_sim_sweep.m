%% simulation for nr pusch
close all;
clear;
%clc;
addpath('mex','estimation','fading','modulation','nr_codec','nr_common','nr_phy','utils','tools','OFDM_STOCFO');
%% set parameter
DebugLink=1;
N_rru=2;
N_rru_dly=[0,60,40,100,150,200,250,300,50];
N_rru_coe=[1,0.2,0.1,01,0.027,0.26,0.2,0.1];

SNR = 30.0;
MCS = 18;
sim_dur_slots = 1; %% total slot number for test, eg 20/100

%% NR RF&frequency parameter
FR = 1;
f_c = 3.5e9;
scs =  30e3;
band = 100; %[5 10 15 20 25 30 40 50 60 70 80 90 100] MHz
N_ant_eNB_RX = 2;
%%
hlp = nr_higher_layer_parameters_struct();
hlp.PUSCH_tp = 0; % 0 or 1 
hlp.MCS_Table_PUSCH = 1; % 1 (64QAM) or 2 (256QAM)
hlp.UL_DMRS_add_pos = 1; % 0 - 3

alg = nr_algorithms_struct();
alg.chan_est = 'MMSE'; % 'LS'
alg.sto_est = 'prony';%'dft'; % 'prony'
alg.cfo_est = 'prony';%'none'; % 'prony'
alg.equalizer = 'MMSE'; % 'ZF'
alg.chan_est_avg = [3,0];
alg.demodulation_method = 'Approx LLR';

channel = struct();
channel.MIMO_corr = [0, 0];
channel.F_cfo = 0;
channel.rayleigh_en = 0;
channel.method = 'zheng';
channel.pdp_resample_meth = 'simple';
channel.pdp_reduce_N = 10;
channel.normalize_response = true;

frame_cfg = nr_framing_constants(FR, scs, band);

UE = struct();

UE(1).f_doppler = 00; % 70
UE(1).mpprofile = 'TDLA30';
UE(1).I_mcs = MCS;
UE(1).N_ant_TX = N_ant_eNB_RX;
UE(1).N_layer = N_ant_eNB_RX;
if UE(1).N_ant_TX == 1
  UE(1).antenna_ports = [0];
else
  UE(1).antenna_ports = [0 2];
end
UE(1).PUSCH_sched_RB_offset = 0;
UE(1).PUSCH_sched_RB_num = frame_cfg.N_RB;
UE(1).PUSCH_symbol_start = 1;
UE(1).PUSCH_symbols_sched = 13;
UE(1).tx_filter = radio_filter(153, frame_cfg);
UE(1).higher_layer_parameters = hlp;
UE(1).algorithms = alg;
%% simulation for debug
rng(0);
fprintf("Test with %d RRU:\n",N_rru);
if DebugLink
  res=nr_sch_link_level_sim(frame_cfg, sim_dur_slots, UE, N_ant_eNB_RX, channel, SNR,N_rru,N_rru_dly,N_rru_coe)
  saveBler(res,SNR,MCS,N_rru);
else
  SNR = -10 : 2 : 25; %-10 : 1 : 25;
  MCS = [0, 5, 10, 15, 20];

  for j = 1 : length(MCS)
    for i = 1 : length(SNR)
      fprintf('Now simulate MCS=%d with SNR=%d,',MCS(j),SNR(i));
      UEl = UE(1);
      UEl.I_mcs = MCS(j);
      res(i,j) = nr_sch_link_level_sim(frame_cfg, sim_dur_slots, UEl, N_ant_eNB_RX, channel, SNR(i),N_rru,N_rru_dly,N_rru_coe);
      fprintf(' result Bler=%f\n',res(i,j).BLER);
    end
  end
  %% plot result
  saveBler(res,SNR,MCS,N_rru);
  figure; hold on;
  for j = 1 : length(MCS)
    plot(SNR, [res(:,j).BER_c], 'DisplayName', sprintf('MCS %d', MCS(j)));
  end
  hold off; grid on; xlabel('SNR'); ylabel('Coded BER'); legend show;
  
  figure; hold on;
  for j = 1 : length(MCS)
    plot(SNR, [res(:,j).BLER], 'DisplayName', sprintf('MCS %d', MCS(j)));
  end
  hold off; grid on; xlabel('SNR'); ylabel('BLER'); legend show;
end