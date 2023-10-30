%main_user.m is the main workspace for algorthim intergated with other
%functons
%TINGYU BAO in 2023_1_31 did major modification and algorithm restructure
clc;
clear;
close all;

%% DEFINE inital data
int_SBS_num = 30;
int_mSBS_num = 10;
int_MBS_num = 5;
int_UD_num = 200;
max_test_UD_num = 200;
%lp = latency_per_device;

%% claim refer area
l = latency_funcs;
z = latency_per_device;
e = Load_environment_variable;
c = connection_algorithm;
cd = connection_algorithm2;
ce = connection_algorithm3;
p = plot_funcs;

%% claim Data Base global variables
global SBS MBS UDs M_MEC test_UDs mSBS;
e.create_DataBase();

%% pre_Data initalization: Load inital SBS_information
[int_SBS_Id, int_SBS_x, int_SBS_y, SBS_CHANNEL] = e.Load_SBS(int_SBS_num);
SBS.SBS_Id = int_SBS_Id;
SBS.loc_x = int_SBS_x;
SBS.loc_y = int_SBS_y;
SBS.Channel_cap = SBS_CHANNEL;

[int_mSBS_Id, int_mSBS_x, int_mSBS_y, mSBS_CHANNEL] = e.Load_SBS(int_mSBS_num);
mSBS.SBS_Id = int_mSBS_Id;
mSBS.loc_x = int_mSBS_x;
mSBS.loc_y = int_mSBS_y;
mSBS.Channel_cap = mSBS_CHANNEL;

[int_MBS_Id, int_MBS_x, int_MBS_y, MBS_CHANNEL] = e.Load_MBS(int_MBS_num);
MBS.MBS_Id = int_MBS_Id;
MBS.loc_x = int_MBS_x;
MBS.loc_y = int_MBS_y;
MBS.Channel_cap = MBS_CHANNEL;

[int_UD_Id, int_UD_x, int_UD_y, int_UD_bits] = e.Load_UD(int_UD_num);
UDs.UD_Id = int_UD_Id;
UDs.loc_x = int_UD_x;
UDs.loc_y = int_UD_y;
UDs.bits_in = int_UD_bits;

%% channel pre-assignment： SBS AND MBS
SBS.Channel_cap = c.int_connection_assignment(int_SBS_num, int_UD_num);
channel_cap_List = SBS.Channel_cap %show assgined channel capactiy map.
replica_cap_List = channel_cap_List;
replica_cap_List1 = channel_cap_List;
replica_cap_List2 = channel_cap_List;
replica_cap_List3 = channel_cap_List;

MBS_device_cap = c.int_MBS_assignment(int_MBS_num, int_UD_num/2);
replica_device_cap = MBS_device_cap;
replica_MBSdevice_cap1 = MBS_device_cap;
replica_MBSdevice_cap2 = MBS_device_cap;
replica_MBSdevice_cap3 = MBS_device_cap;
%% target SBS-UD latency caculation
result_latency_map = [];
SBS_ID_TARGET_TEST = [];
result_ul_map = [];
result_bh_map =[];
result_exe_map =[];
result_dl_map =[];
result_ul_runtime = [];
result_pa_ul_runtime = [];
result_dl_runtime = [];
result_pa_dl_runtime = [];

sum_lat_perCycle_n = []; %forced
sum_lat_perCycle_n1 = []; %dynamic
sum_lat_perCycle_n2 = []; %coupled
sum_lat_perCycle_n3 = []; %random
x = [];

lat_100times_n = [];
lat_100times_n1 = [];
lat_100times_n2 = [];
lat_100times_n3 = [];

for j = 20 : 5 : max_test_UD_num
    lp = latency_per_device;
    x = [x, j];
    temp_latinfo_n = [];
    temp_latinfo_n1 = [];
    temp_latinfo_n2 = [];
    temp_latinfo_n3 = [];

    for bb = 1:50
    [t_UD_Id, t_UD_x, t_UD_y, t_UD_bits] = e.Load_test_UD(j);
    test_UDs.test_UD_Id = t_UD_Id;
    test_UDs.test_loc_x = t_UD_x;
    test_UDs.test_loc_y = t_UD_y;
    test_UDs.bits_in = t_UD_bits;

%% UL-DL non-parrelle part
    tic;
    [result_SBS_List, cur_cap_perUD] = c.ul_connection_algorithm(channel_cap_List, ...
                                                                test_UDs.test_UD_Id, ...
                                                                SBS.SBS_Id);
    UDs_on_SBS = e.invert_List(cur_cap_perUD);
    ul_algotime = toc;
    result_ul_runtime = [result_ul_runtime, ul_algotime]; %time-ul

%%%%
    tic;
    [result_MBS_List, UDs_on_MBS] = c.dl_connection_algorithm(test_UDs.test_UD_Id, ...
                                                              MBS.MBS_Id, MBS_device_cap); 
    dl_algotime = toc;
    result_dl_runtime = [result_dl_runtime, dl_algotime]; %time-dl
%%%%    
    lat_info = [];
    for i = 1 : length(result_SBS_List)
        lat_info_perUD = z.cal_overall_latency(test_UDs.test_UD_Id(i), ...
                                               result_SBS_List(i), result_MBS_List(i), ...
                                               UDs_on_SBS(i), UDs_on_MBS(i));
        lat_info = [lat_info, lat_info_perUD(1)];
    end
    
    temp_latinfo_n = [temp_latinfo_n, sum(lat_info)]
    %sum_lat_perCycle_n = [sum_lat_perCycle_n, sum(lat_info)];

%% UL-DL non-parrelle 5G/4G switch part
[result_ulBS_List, ul_BS_sort, ul_device_perUD] = ce.forced_decoupled_in5G_ul(replica_cap_List1, test_UDs.test_UD_Id, SBS.SBS_Id, mSBS.SBS_Id)
    

[result_dlBS_List, dl_device_perUD] = ce.forced_decoupled_in5G_dl(test_UDs.test_UD_Id, MBS.MBS_Id, replica_MBSdevice_cap1); 

a1= length(result_dlBS_List)

a3= length(dl_device_perUD)
lat_info1 = [];
for b = 1:length(result_ulBS_List)
        lat_info_perUD1 = z.forced_5G_overall_latency(test_UDs.test_UD_Id(i), ...
                                               result_ulBS_List(i), ul_BS_sort(i), result_dlBS_List(i), ...
                                               ul_device_perUD(i), dl_device_perUD(i));
        lat_info1 = [lat_info1, lat_info_perUD1(1)];
end

temp_latinfo_n1 = [temp_latinfo_n1, sum(lat_info1)]
    
    end

    lat_100times_n =  [lat_100times_n, sum(temp_latinfo_n) / length(temp_latinfo_n)]
    lat_100times_n1 = [lat_100times_n1,sum(temp_latinfo_n1)/length(temp_latinfo_n1)]
end

p.draw_two_plot(x, lat_100times_n1,lat_100times_n, 2,2)
% y1 = length(result_ul_runtime);
% y2 = length(result_dl_runtime);
% x1 = length(x);
% p.draw_together_graph(x, lat_100times_n,lat_100times_n1,lat_100times_n2,lat_100times_n3,2,2)
% p.draw_together_plot(x, lat_100times_n,lat_100times_n1,lat_100times_n2,lat_100times_n3,3,3)
%p.draw_together_semiGraph(x, sum_lat_perCycle_n,sum_lat_perCycle_n2,sum_lat_perCycle_n3,sum_lat_perCycle_n3,1,1)
%p.draw_together_graph(x, sum_lat_perCycle_n,sum_lat_perCycle_n1,sum_lat_perCycle_n2,2,2)
%p.draw_single_graph(x, result_ul_runtime, 1);
%p.draw_single_graph(x, result_dl_runtime, 2);
%p.draw_shared_graph(x, result_ul_runtime, result_dl_runtime,3, 1);
% p.draw_compare_graph(x, result_pa_ul_runtime, result_ul_runtime, 4, 2);
% p.draw_compare_graph(x, result_pa_dl_runtime, result_dl_runtime, 5, 3);
%p.draw_shared_graph(x, aver_lat_perCycle_n3, aver_lat_perCycle_n, 6, 4);
% p.draw_compare_graph(x, sum_lat_perCycle_n, sum_lat_perCycle_n2, 7, 5);
% p.draw_together_graph(x, sum_lat_perCycle_n, sum_lat_perCycle_n2, sum_lat_perCycle_n3, 8, 6);

