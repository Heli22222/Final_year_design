function latency = lat

    latency.uplink_latency = @uplink_latency;
    latency.downlink_latency = @downlink_latency;
    latency.backhaul_latency = @backhaul_latency;
    latency.exe_latency = @exe_latency;
    latency.exe_latency_sbs = @exe_latency_sbs;
    latency.distance = @distance;
    latency.cal_received_power = @cal_received_power;
    latency.uplink_latency_5G = @uplink_latency_5G;
end

%% distance
function d = distance(x1, y1, x2, y2)
    d = ((x1-x2)^2 + (y1-y2)^2)^0.5;
end

%% uplink latency
function latency_up = uplink_latency(d, bits_in, N)
%parameters
up_bandwidth = 5*10^6; %HZ, 5MHZ
Noise_density = -174; %dBm/Hz
pl_exponent = 3;
op_frequency = 2*10^9; %HZ, 2GHZ
received_power = -80; %dBm
ref_d = 50; %m -
c = 3*10^8; % light speed
shaowing = 4; %dB
w = rand(1,1); % compensation factor
Max_power = 23; %dBm
%channel_gain = 100; %dB
interference = 10; %db

PL = 20*log2((4*pi*ref_d*op_frequency)/c) + 10*pl_exponent*log2(d/ref_d)+ shaowing;

channel_gain = (-1)*PL; %db
coff = sum(normrnd(0,sqrt(0.5),1,2).^2);
channel_gain_fad = coff*channel_gain;
p = 10*log10(Max_power); %db
Noise = Noise_density + 10*log10(up_bandwidth/N); %db
SINR = (p*channel_gain_fad)/(interference + Noise); %db

uplink_Rate = (up_bandwidth/N)*log2(1 + SINR);
latency_up = bits_in/uplink_Rate;
end

%% backhaul latency
function latency_bh = backhaul_latency(d, bits_in )
%parameters
bh_capacity = 10*10^6; %bits/sec

latency_bh = bits_in / bh_capacity;
end

%% exe latency
function latency_exe = exe_latency(alpha, beta, bits_in, payload_devices);
%parameters
Fk = 36*10^9*100; %Hz, MBS

bits_out = alpha*bits_in;
task_cyc = beta*bits_in;
latency_exe = [task_cyc / (Fk/payload_devices), bits_out];
end

function latency_exe = exe_latency_sbs(alpha, beta, bits_in, payload_devices);
%parameters
Fk = 36*10^9*100; %Hz, SBS's Fk is 10 time less than MBS's

bits_out = alpha*bits_in;
task_cyc = beta*bits_in;
latency_exe = [task_cyc / (Fk/payload_devices), bits_out];
end

%% downlink latency
function latency_dl = downlink_latency(d, bits_in)
%parameters
dl_bandwidth = 5*10^6; %HZ, 5MHZ-200
Noise_density = -174; %dBm/Hz
pl_exponent = 3;
op_frequency = 2*10^9; %HZ, 2GHZ-60MHZ
ref_d = 50; %m -
c = 3*10^8; % light speed
shaowing = 4; %dB
w = rand(1,1); % compensation factor
%channel_gain = 100; %dB -
interference = 10; 
Max_power = 23; %dbm

PL = 20*log2((4*pi*ref_d*op_frequency)/c) + 10*pl_exponent*log2(d/ref_d)+ shaowing;

channel_gain = (-1)*PL; %db
coff = sum(normrnd(0,sqrt(0.5),1,2).^2);
channel_gain_fad = coff*channel_gain;
p = 10*log10(Max_power); %db
Noise = Noise_density + 10*log10(dl_bandwidth); %db
SINR = (p*channel_gain_fad)/(interference + Noise); %db

downlink_Rate = (dl_bandwidth)*log2(1 + SINR);

latency_dl = bits_in/downlink_Rate;
end

%% user divice received power
function p2 = cal_received_power(d)
%parameters
pl_exponent = 3;
op_frequency = 2*10^9; %HZ, 2GHZ
ref_d = 50; %m -
c = 3*10^8; % light speed
shaowing = 4; %dB
w = rand(1,1); % compensation factor
received_power = -80; %dbm

PL = 20*log2((4*pi*ref_d*op_frequency)/c) + 10*pl_exponent*log2(d/ref_d)+ shaowing;
p2 = abs(w*PL + received_power);
end

%% 5GmmWave BS ulpink latency 
function latency_up_5G = uplink_latency_5G(d, bits_in, N)
%parameters
up_bandwidth = 200*10^6; %HZ, 200MHZ
Noise_density = -174; %dBm/Hz
pl_exponent = 3;
op_frequency = 60*10^9; %HZ, 60GHZ
received_power = -80; %dBm
ref_d = 50; %m -
c = 3*10^8; % light speed
shaowing = 4; %dB
w = rand(1,1); % compensation factor
Max_power = 23; %dBm
%channel_gain = 100; %dB
interference = 10; %db

PL = 20*log2((4*pi*ref_d*op_frequency)/c) + 10*pl_exponent*log2(d/ref_d)+ shaowing;

channel_gain = (-1)*PL; %db
coff = sum(normrnd(0,sqrt(0.5),1,2).^2);
channel_gain_fad = coff*channel_gain;
p = 10*log10(Max_power); %db
Noise = Noise_density + 10*log10(up_bandwidth/N); %db
SINR = (p*channel_gain_fad)/(interference + Noise); %db

uplink_Rate = (up_bandwidth/N)*log2(1 + SINR);
latency_up_5G = bits_in/uplink_Rate;
end