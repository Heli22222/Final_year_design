%main_user.m is the main workspace for algorthim intergated with other
%functons
%TINGYU BAO in 2023_1_31 did major modification and algorithm restructure
clc;
clear;
close all;

%% DEFINE inital data
int_SBS_num = 30;
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
p = plot_funcs;

%% claim Data Base global variables
global SBS MBS UDs M_MEC test_UDs;
e.create_DataBase();

%% pre_Data initalization: Load inital SBS_information
[int_SBS_Id, int_SBS_x, int_SBS_y, SBS_CHANNEL] = e.Load_SBS(int_SBS_num);
SBS.SBS_Id = int_SBS_Id;
SBS.loc_x = int_SBS_x;
SBS.loc_y = int_SBS_y;
SBS.Channel_cap = SBS_CHANNEL;

% xlswrite ('Enviro_Var_List.xlsx', SBS.SBS_Id, 2, 'B1');
% xlswrite ('Enviro_Var_List.xlsx', SBS.loc_x, 2, 'B2');
% xlswrite ('Enviro_Var_List.xlsx', SBS.loc_y, 2, 'B3');
% xlswrite ('Enviro_Var_List.xlsx', SBS.Channel_cap, 2, 'B4');

[int_MBS_Id, int_MBS_x, int_MBS_y, MBS_CHANNEL] = e.Load_MBS(int_MBS_num);
MBS.MBS_Id = int_MBS_Id;
MBS.loc_x = int_MBS_x;
MBS.loc_y = int_MBS_y;
MBS.Channel_cap = MBS_CHANNEL;

% xlswrite ('Enviro_Var_List.xlsx', MBS.MBS_Id, 4, 'B1');
% xlswrite ('Enviro_Var_List.xlsx', MBS.loc_x, 4, 'B2');
% xlswrite ('Enviro_Var_List.xlsx', MBS.loc_y, 4, 'B3');
% xlswrite ('Enviro_Var_List.xlsx', MBS.Channel_cap, 4, 'B4');

[int_UD_Id, int_UD_x, int_UD_y, int_UD_bits] = e.Load_UD(int_UD_num);
UDs.UD_Id = int_UD_Id;
UDs.loc_x = int_UD_x;
UDs.loc_y = int_UD_y;
UDs.bits_in = int_UD_bits;
% xlswrite ('Enviro_Var_List.xlsx', UDs.UD_Id, 1, 'B1');
% xlswrite ('Enviro_Var_List.xlsx', UDs.loc_x, 1, 'B2');
% xlswrite ('Enviro_Var_List.xlsx', UDs.loc_y, 1, 'B3');
% xlswrite ('Enviro_Var_List.xlsx', UDs.bits_in, 1, 'B4');

% [t_UD_Id, t_UD_x, t_UD_y, t_UD_bits] = e.Load_test_UD(test_UD_num);
% test_UDs.test_UD_Id = t_UD_Id;
% test_UDs.test_loc_x = t_UD_x;
% test_UDs.test_loc_y = t_UD_y;
% test_UDs.bits_in = t_UD_bits;
% xlswrite ('Enviro_Var_List.xlsx', test_UDs.test_UD_Id, 3, 'B1');
% xlswrite ('Enviro_Var_List.xlsx', test_UDs.test_loc_x, 3, 'B2');
% xlswrite ('Enviro_Var_List.xlsx', test_UDs.test_loc_y, 3, 'B3');
% xlswrite ('Enviro_Var_List.xlsx', test_UDs.bits_in, 3, 'B4');

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

for j = 20 : 5 : max_test_UD_num
    lp = latency_per_device;
    x = [x, j];

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
    sumLOL = sum(UDs_on_MBS);
    sumLOL2 = sum(UDs_on_SBS);
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
    sum_lat_perCycle_n = [sum_lat_perCycle_n, sum(lat_info)];

%% UL-DL parrelle part
    tic
    result_SBS_List2 =  c.pa_ul_connection_algorithm(replica_cap_List, ...
                                                     test_UDs.test_UD_Id, ...
                                                     SBS.SBS_Id, ...
                                                     test_UDs.test_loc_x,test_UDs.test_loc_y, ...
                                                     SBS.loc_x, SBS.loc_y);
    ul_algotime2 = toc;
    result_pa_ul_runtime = [result_pa_ul_runtime, ul_algotime2]; %ul-time

    tic;
    result_MBS_List2 = c.pa_dl_connection_algorithm(test_UDs.test_UD_Id, MBS.MBS_Id, ...
                                                    test_UDs.test_loc_x,test_UDs.test_loc_y,  ...
                                                    test_UDs.bits_in, ...
                                                    MBS.loc_x, MBS.loc_y, replica_device_cap);                              
    dl_algotime2 = toc;
    result_pa_dl_runtime = [result_pa_dl_runtime, dl_algotime2];%dl-time

%% UL-DL dynamic assign algorithim comparsion parts
   [result_dyulBS_List, dyul_BS_sort, dyul_device_perUD] = cd.ul_dyn_assign_algorithm(replica_cap_List3,test_UDs.test_UD_Id, ...
                                                                                SBS.SBS_Id, MBS.MBS_Id)
   [result_dydlBS_List, dydl_BS_sort, dydl_device_perUD] = cd.dl_dyn_assign_algorithm(replica_cap_List3, replica_MBSdevice_cap3, test_UDs.test_UD_Id, ...
                                                                                SBS.SBS_Id, MBS.MBS_Id)
   
   lat_info1 = [];
   for i = 1 : length(result_dyulBS_List)
       if(result_dyulBS_List(i) == result_dydlBS_List(i)) %when it is coupled access
            lat_info_perUD1 = z.coupled_cal_overall_latency(dyul_BS_sort(i), test_UDs.test_UD_Id(i), result_dyulBS_List(i), ...
                                                            dyul_device_perUD(i));
        else
            lat_info_perUD1 = z.nocouple_cal_overall_latency(dyul_BS_sort(i), dydl_BS_sort(i), test_UDs.test_UD_Id(i), ...
                                                             result_dyulBS_List(i), result_dydlBS_List(i), ...
                                                             dyul_device_perUD(i), dydl_device_perUD(i));
        end
        lat_info1 = [lat_info1, lat_info_perUD1(1)];
   end
   sum_lat_perCycle_n1 = [sum_lat_perCycle_n1, sum(lat_info1)]
%% UL-DL coupled assign algorithim comparsion parts
   [bs_sort, result_couplBS_List, coupl_device_perUD] = cd.coupled_connection_algorithm(replica_cap_List1, ...
                                                                                        replica_MBSdevice_cap1, ...
                                                                                        test_UDs.test_UD_Id, ...
                                                                                        SBS.SBS_Id, MBS.MBS_Id);
   lat_info2 = []; 
   result_couplBS_List;
   bs_sort;
   for i = 1: length(result_couplBS_List)
        lat_info_perUD2 = z.coupled_cal_overall_latency(bs_sort(i), test_UDs.test_UD_Id(i), result_couplBS_List(i), coupl_device_perUD(i));
        lat_info2 = [lat_info2, lat_info_perUD2(1)];
   end

   sum_lat_perCycle_n2 = [sum_lat_perCycle_n2, sum(lat_info2)]; %overall latnecy list
%% UL-DL randomly assign algorithim comparsion parts
    [ul_bs_sort, dl_bs_sort, result_ulBS_List, result_dlBS_List, ul_device_perUD, dl_device_perUD] = cd.rand_assign_algorithm(replica_cap_List2, ...
                                                                                                                            replica_MBSdevice_cap2, ...
                                                                                                                            test_UDs.test_UD_Id, ...
                                                                                                                            SBS.SBS_Id, MBS.MBS_Id);
    lat_info3 = [];
    for i = 1 : length(result_ulBS_List)
        if(result_ulBS_List(i) == result_dlBS_List(i)) %when it is coupled access
            lat_info_perUD3 = z.coupled_cal_overall_latency(ul_bs_sort(i), test_UDs.test_UD_Id(i), result_ulBS_List(i), ...
                                                            ul_device_perUD(i));
        else
            lat_info_perUD3 = z.nocouple_cal_overall_latency(ul_bs_sort(i), dl_bs_sort(i), test_UDs.test_UD_Id(i), ...
                                                             result_ulBS_List(i), result_dlBS_List(i), ...
                                                             ul_device_perUD(i), dl_device_perUD(i));
        end
        lat_info3 = [lat_info3, lat_info_perUD3(1)];
    end
    sum_lat_perCycle_n3 = [sum_lat_perCycle_n3, sum(lat_info3)]; %overall latnecy list

end

y1 = length(result_ul_runtime);
y2 = length(result_dl_runtime);
x1 = length(x);
%p.draw_together_semiGraph(x, sum_lat_perCycle_n,sum_lat_perCycle_n2,sum_lat_perCycle_n3,sum_lat_perCycle_n3,1,1)
%p.draw_together_graph(x, sum_lat_perCycle_n,sum_lat_perCycle_n1, sum_lat_perCycle_n2,sum_lat_perCycle_n3,2,2)
%p.draw_single_graph(x, result_ul_runtime, 1);
%p.draw_single_graph(x, result_dl_runtime, 2);
%p.draw_compare_graph(x, result_ul_runtime, result_dl_runtime,2, 2);
p.draw_compare_graph(x, result_pa_ul_runtime, result_ul_runtime, 4, 2);
p.draw_compare_graph(x, result_pa_dl_runtime, result_dl_runtime, 5, 3);
%p.draw_shared_graph(x, aver_lat_perCycle_n3, aver_lat_perCycle_n, 6, 4);
% p.draw_compare_graph(x, sum_lat_perCycle_n, sum_lat_perCycle_n2, 7, 5);
% p.draw_together_graph(x, sum_lat_perCycle_n, sum_lat_perCycle_n2, sum_lat_perCycle_n3, 8, 6);
% xlswrite ('Enviro_Var_List.xlsx', result_latency_map, 3, 'B5');
% xlswrite ('Enviro_Var_List.xlsx', SBS_ID_TARGET_TEST, 3, 'B6');
% xlswrite ('Enviro_Var_List.xlsx', result_ul_map, 3, 'B7');
% xlswrite ('Enviro_Var_List.xlsx', result_bh_map, 3, 'B8');
% xlswrite ('Enviro_Var_List.xlsx', result_exe_map, 3, 'B9');
% xlswrite ('Enviro_Var_List.xlsx', result_dl_map, 3, 'B10');
% xlswrite ('Enviro_Var_List.xlsx', result_ul_runtime, 3, 'B11');
% xlswrite ('Enviro_Var_List.xlsx', result_dl_runtime, 3, 'B12');
