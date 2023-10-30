function latency_per_device = lpd
    latency_per_device.cal_overall_latency = @cal_overall_latency;
    latency_per_device.coupled_cal_overall_latency = @coupled_cal_overall_latency;
    latency_per_device.nocouple_cal_overall_latency = @nocouple_cal_overall_latency;
    latency_per_device.forced_5G_overall_latency = @forced_5G_overall_latency;
end

%t_UD_Id/ SBS_Id is single float number here
%% Overall latency calculation for forced-decoupled access
function Latency_info_perUD = cal_overall_latency(t_UD_Id, SBS_Id, MBS_Id, N, MBS_N)
global SBS MBS test_UDs;
l = latency_funcs;
%beta_array = [330960, 1900];

   UD_SBS_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                SBS.loc_x(SBS_Id), SBS.loc_y(SBS_Id));

   lat_ul = l.uplink_latency(UD_SBS_dis, test_UDs.bits_in(t_UD_Id), N); %UDs.UD_Id(target_UD_ID)

   SBS_MBS_dis = l.distance(SBS.loc_x(SBS_Id), SBS.loc_y(SBS_Id), ...
                            MBS.loc_x(MBS_Id), MBS.loc_y(MBS_Id));

   lat_bh = l.backhaul_latency(SBS_MBS_dis, test_UDs.bits_in(t_UD_Id));

   lat_exe= l.exe_latency(0.2, 1900, test_UDs.bits_in(t_UD_Id), MBS_N);
   
   MBS_UD_dis = l.distance(MBS.loc_x(MBS_Id), MBS.loc_y(MBS_Id), ...
                           test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id));
   
   lat_dl = l.downlink_latency(MBS_UD_dis, lat_exe(2))
   
   Latency = lat_ul + lat_bh + lat_exe(1) + lat_dl;
   Latency_info_perUD = [Latency, lat_ul, lat_bh, lat_exe(1), lat_dl];
   %min_mapper = findMin(Result_List)
end

%% Overall latency calculation for dynamic/random access
function Latency_info_perUD = nocouple_cal_overall_latency(ul_BS_sort, dl_BS_sort, ...
                                                      t_UD_Id, ul_BS_Id, dl_BS_Id, ...
                                                      ul_device_BS, dl_device_BS)
global SBS MBS test_UDs;
l = latency_funcs; %sort=1 means SBS and sort = 2 means MBS

if(ul_BS_sort == 1) %if uplink bs is SBS
    UD_ulBS_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                             SBS.loc_x(ul_BS_Id), SBS.loc_y(ul_BS_Id));
    lat_ul = l.uplink_latency(UD_ulBS_dis, test_UDs.bits_in(t_UD_Id), ul_device_BS); %UDs.UD_Id(target_UD_ID)
end

if(ul_BS_sort == 2) %if uplink bs is MBS
    UD_ulBS_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                             MBS.loc_x(ul_BS_Id), MBS.loc_y(ul_BS_Id));
    %using downlink function in uplink latency caculation
    lat_ul = l.downlink_latency(UD_ulBS_dis, test_UDs.bits_in(t_UD_Id)); %UDs.UD_Id(target_UD_ID)
end

lat_bh = l.backhaul_latency(1, test_UDs.bits_in(t_UD_Id));

if(dl_BS_sort == 1) %if dplink bs is SBS
    lat_exe = l.exe_latency_sbs(0.2, 1900, test_UDs.bits_in(t_UD_Id), dl_device_BS);
    dlBS_UD_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                             SBS.loc_x(dl_BS_Id), SBS.loc_y(dl_BS_Id));
    %using uplink function in downlink latency caculation
    lat_dl = l.uplink_latency(dlBS_UD_dis, lat_exe(2), dl_device_BS); %UDs.UD_Id(target_UD_ID)
end

if(dl_BS_sort == 2) %if dplink bs is MBS
    lat_exe = l.exe_latency(0.2, 1900, test_UDs.bits_in(t_UD_Id), dl_device_BS);
    dlBS_UD_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                             MBS.loc_x(dl_BS_Id), MBS.loc_y(dl_BS_Id));
    %using downlink function in uplink latency caculation
    lat_dl = l.downlink_latency(dlBS_UD_dis, lat_exe(2)); %UDs.UD_Id(target_UD_ID)
end

Latency = lat_ul + lat_bh + lat_exe(1) + lat_dl;
Latency_info_perUD = [Latency, lat_ul, lat_bh, lat_exe(1), lat_dl];
end

%% Overall latency calculation for coupled access
function Latency_info_perUD = coupled_cal_overall_latency(BS_sort, ...
                                                         t_UD_Id, BS_Id, ...
                                                         device_BS)
global SBS MBS test_UDs;
l = latency_funcs;
lat_bh = 0;
if(BS_sort == 1)
    distance = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                          SBS.loc_x(BS_Id), SBS.loc_y(BS_Id));
    lat_ul = l.uplink_latency(distance, test_UDs.bits_in(t_UD_Id), device_BS);
    lat_exe = l.exe_latency_sbs(0.2, 1900, test_UDs.bits_in(t_UD_Id), device_BS);
    lat_dl = l.uplink_latency(distance, lat_exe(2), device_BS);
elseif(BS_sort == 2)
    distance = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                          MBS.loc_x(BS_Id), MBS.loc_y(BS_Id));
    lat_ul = l.downlink_latency(distance, test_UDs.bits_in(t_UD_Id));
    lat_exe = l.exe_latency(0.2, 1900, test_UDs.bits_in(t_UD_Id), device_BS);
    lat_dl = l.downlink_latency(distance, lat_exe(2));
end

Latency = lat_ul + lat_bh + lat_exe(1) + lat_dl;
Latency_info_perUD = [Latency, lat_ul, lat_bh, lat_exe(1), lat_dl];
end

%% Overall latency calculation for forced decoupled under 5G
function Latency_info_perUD = forced_5G_overall_latency(t_UD_Id, SBS_Id, SBS_sort, MBS_Id, N, MBS_N)

global SBS mSBS MBS test_UDs;
l = latency_funcs;
lat_ul = 0;
lat_bh = 0;
if(SBS_sort == 1)
   UD_SBS_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                SBS.loc_x(SBS_Id), SBS.loc_y(SBS_Id));

   lat_ul = l.uplink_latency(UD_SBS_dis, test_UDs.bits_in(t_UD_Id), N); %UDs.UD_Id(target_UD_ID)

   SBS_MBS_dis = l.distance(SBS.loc_x(SBS_Id), SBS.loc_y(SBS_Id), ...
                            MBS.loc_x(MBS_Id), MBS.loc_y(MBS_Id));
   lat_bh = l.backhaul_latency(SBS_MBS_dis, test_UDs.bits_in(t_UD_Id));

elseif(SBS_sort == 3)
   UD_SBS_dis = l.distance(test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id), ...
                mSBS.loc_x(SBS_Id), mSBS.loc_y(SBS_Id));

   lat_ul = l.uplink_latency_5G(UD_SBS_dis, test_UDs.bits_in(t_UD_Id), N); %UDs.UD_Id(target_UD_ID)

   SBS_MBS_dis = l.distance(mSBS.loc_x(SBS_Id), mSBS.loc_y(SBS_Id), ...
                            MBS.loc_x(MBS_Id), MBS.loc_y(MBS_Id));
   lat_bh = l.backhaul_latency(SBS_MBS_dis, test_UDs.bits_in(t_UD_Id));
end
   
   
   lat_exe= l.exe_latency(0.2, 1900, test_UDs.bits_in(t_UD_Id), MBS_N);
   
   MBS_UD_dis = l.distance(MBS.loc_x(MBS_Id), MBS.loc_y(MBS_Id), ...
                           test_UDs.test_loc_x(t_UD_Id), test_UDs.test_loc_x(t_UD_Id));
   
   lat_dl = l.downlink_latency(MBS_UD_dis, lat_exe(2));
   
   Latency = lat_ul + lat_bh + lat_exe(1) + lat_dl;
   Latency_info_perUD = [Latency, lat_ul, lat_bh, lat_exe(1), lat_dl];

end