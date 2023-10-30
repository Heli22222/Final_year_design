function connection_algorithm3 = con_alg3
    connection_algorithm3.forced_decoupled_in5G_ul = @forced_decoupled_in5G_ul;
    connection_algorithm3.forced_decoupled_in5G_dl = @forced_decoupled_in5G_dl;
end

%% UL-connection in 5G/4G
function [ul_BS_List, ul_BS_sort, ul_device_perUD] = forced_decoupled_in5G_ul(replica_SBScap_List, User_List, SBS_List, mSBS_List)

    la = latency_funcs;
    le = Load_environment_variable;
    global SBS mSBS test_UDs;
    range = 35; %m
    mSBS_num = length(mSBS_List);

    replica_SBSdevice_List = le.invert_List(replica_SBScap_List);
    replica_mSBSdevice_List  = zeros(1, mSBS_num);
    ul_BS_sort = [];%sort = 1 is SBS, =3 is mSBS
    ul_BS_List = [];
    ul_device_perUD = [];
    flag = 0;

received_Power_List = zeros(length(User_List), length(SBS_List));

for z = 1: length(User_List)
    for i = 1: length(SBS_List)
        distance = la.distance(test_UDs.test_loc_x(z), test_UDs.test_loc_y(z), SBS.loc_x(i), SBS.loc_y(i));
        rec_power = la.cal_received_power(distance);
        received_Power_List(z, i) =  rec_power;
    end
end
    
for j = 1: length(User_List)
    flag = 0;
    for i = 1: length(mSBS_List)
        %distance = 0;
        dm_distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), mSBS.loc_x(i), mSBS.loc_y(i));
        if(dm_distance < range)
            replica_mSBSdevice_List(i) = replica_mSBSdevice_List(i) + 1;
            ul_device_perUD = [ul_device_perUD, replica_mSBSdevice_List(i)];
            ul_BS_List = [ul_BS_List, mSBS_List(i)];
            ul_BS_sort = [ul_BS_sort, 3];
            flag = flag + 1;
            break;
        end
    end

if(flag == 0)
    while true  
        target_SBS = find_max_in_row(received_Power_List, j);
        if(replica_SBScap_List(target_SBS(2)) == 0)
            received_Power_List(j, target_SBS(2)) = 0;
        else
            break;
        end
    end

    replica_SBScap_List(target_SBS(2)) = replica_SBScap_List(target_SBS(2)) - 1;
    replica_SBSdevice_List(target_SBS(2)) = replica_SBSdevice_List(target_SBS(2)) + 1;
    ul_device_perUD = [ul_device_perUD, replica_SBSdevice_List(target_SBS(2))];
    ul_BS_List = [ul_BS_List, target_SBS(2)];
    ul_BS_sort = [ul_BS_sort, 1];
    if(replica_SBScap_List(target_SBS(2)) < 0)
        replica_SBScap_List(target_SBS(2)) = 0;
    end
end

end
end

%% DL connection in 5G/4G
function [target_MBS_List, dl_device_perUD] = forced_decoupled_in5G_dl(User_List, MBS_List, MBS_device_cap)

global test_UDs MBS;
lb = latency_funcs;
weighted = 0.7;
target_MBS_List = [];
dl_device_perUD = [];
received_Power_List2 = zeros(length(User_List), length(MBS_List));

for j = 1: length(User_List)
    for i = 1: length(MBS_List)
        distance = lb.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), MBS.loc_x(i), MBS.loc_y(i));
        rec_power = lb.cal_received_power(distance);
        received_Power_List2(j, i) =  rec_power;
    end
end

for z = 1: length(User_List)
    replica_recpower_List = received_Power_List2;
    optional_MBS_List = [];
    score_List = [];
    step = round(length(MBS_List)*(weighted));

    while step>0
        optional_MBS = find_max_in_row(replica_recpower_List, z); %[max_value, max_value_col]
        optional_MBS_List = [optional_MBS_List, optional_MBS(2)];
        replica_recpower_List(z, optional_MBS(2)) = 0;
        step = step - 1;
    end
    optional_MBS_List;
    for e = 1: length(optional_MBS_List)
        distance = lb.distance(test_UDs.test_loc_x(z), test_UDs.test_loc_y(z), ...
                                MBS.loc_x(optional_MBS_List(e)), MBS.loc_y(optional_MBS_List(e)));
        lat_exe = lb.exe_latency(0.2, 1900, test_UDs.bits_in(z), MBS_device_cap(optional_MBS_List(e))+1);
        lat_dl = lb.downlink_latency(distance, lat_exe(2));

        score = lat_dl*weighted + lat_exe(1)*(1 - weighted);
        score_List = [score_List, score];
    end

    target_MBS = find_min_in_row(score_List);
    MBS_device_cap(target_MBS(2)) = MBS_device_cap(target_MBS(2)) + 1;
    dl_device_perUD = [dl_device_perUD, MBS_device_cap(target_MBS(2))];
    target_MBS_List = [target_MBS_List, target_MBS(2)];
    
end
target_MBS_List;
end



