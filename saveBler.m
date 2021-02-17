%% save bler with time 
function saveBler(res,snr,mcs,N_rru)
now=clock;
f=sprintf('Bler.%d%d%d%d%d%f.mat',now(1),now(2),now(3),now(4),now(5),now(6));
m = matfile(f);
m.res=res;
m.snr=snr;
m.mcs=mcs;
m.N_rru=N_rru;
end