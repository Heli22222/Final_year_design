function connection_Algorithm = con_alg
    connection_Algorithm.int_connection_assignment = @int_connection_assignment;
    connection_Algorithm.int_MBS_assignment = @int_MBS_assignment;
    connection_Algorithm.ul_connection_algorithm = @ul_connection_algorithm;
    connection_Algorithm.dl_connection_algorithm = @dl_connection_algorithm;
    connection_Algorithm.pa_ul_connection_algorithm = @pa_ul_connection_algorithm;
    connection_Algorithm.pa_dl_connection_algorithm = @pa_dl_connection_algorithm;
end

function [assigned_MBS_mapper] = int_MBS_assignment(int_MBS_num, int_UD_num)
count = 0;
seed = 50;
assigned_MBS_mapper = zeros(1, int_MBS_num);
    for i = 1:int_MBS_num
        assign = round(1 + (seed-1)*rand(1,1));
        assigned_MBS_mapper(i) = assign;
        count = count + assign;
        if(count > int_UD_num || count == int_UD_num)
            break;
        end
    end
end

function [assigned_channel_mapper] = int_connection_assignment(int_SBS_num, int_UD_num)
global SBS;
i = 1; 
count = 0;
seed = 40;
channel_cap = SBS.capacity;

while(i <= int_SBS_num && count < int_UD_num + 1)
    
    assigned = round(1 + (seed-1)*rand(1,1));
    %assigned = assigned(1);
    assigned;
    if((assigned == channel_cap) || (assigned < channel_cap))
    SBS.Channel_cap(i) = SBS.Channel_cap(i) - assigned;
    count = count + assigned;
    assigned = [];
    else
    SBS.Channel_cap(i) = SBS.Channel_cap(i) - channel_cap;
    count = count + channel_cap;
    assigned = [];
    end
    i = i + 1;
end
    assigned_channel_mapper = SBS.Channel_cap;
end

%% user divice to SBS in uplink
function [target_SBS_List, current_capacity_perUD] = ul_connection_algorithm(Channel_List, ...
                                                                             User_List, ...
                                                                             SBS_List)

global SBS test_UDs;
la = latency_funcs;
target_SBS_List = [];
current_capacity_perUD = [];

received_Power_List = zeros(length(User_List), length(SBS_List));

for j = 1: length(User_List)
    for i = 1: length(SBS_List)
        distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), SBS.loc_x(i), SBS.loc_y(i));
        rec_power = la.cal_received_power(distance);
        received_Power_List(j, i) =  rec_power;
    end
end

for z = 1: length(User_List)

while true  
    target_SBS = find_max_in_row(received_Power_List, z);
    if(Channel_List(target_SBS(2)) == 0)
        received_Power_List(z, target_SBS(2)) = 0;
    else
        break;
    end
end

Channel_List(target_SBS(2)) = Channel_List(target_SBS(2)) - 1;
current_capacity_perUD = [current_capacity_perUD, Channel_List(target_SBS(2))];
if(Channel_List(target_SBS(2)) < 0)
    Channel_List(target_SBS(2)) = 0;
end

target_SBS_List = [target_SBS_List, target_SBS(2)];
end
end 

%% user divice to MBS in downlink
function [target_MBS_List, current_device_perMBS] = dl_connection_algorithm(User_List, MBS_List, MBS_device_cap)

global test_UDs MBS;
lb = latency_funcs;
weighted = 0.7;
target_MBS_List = [];
current_device_perMBS = [];
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
    current_device_perMBS = [current_device_perMBS, MBS_device_cap(target_MBS(2))];
    target_MBS_List = [target_MBS_List, target_MBS(2)];
    
end
target_MBS_List;
end

%% pa user divice to SBS in uplink()
function [target_SBS_List] = pa_ul_connection_algorithm(Channel_List, ...
                                                        User_List, SBS_List, ...
                                                        User_locx, User_locy, ...
                                                        SBS_locx, SBS_locy)

%global SBS test_UDs;
la = latency_funcs;
target_SBS_List = [];
SBS_num = length(SBS_List);
received_Power_List = zeros(length(User_List), length(SBS_List));

parfor j = 1: length(User_List)
    for i = 1: SBS_num
        distance = la.distance(User_locx(j), User_locy(j), SBS_locx(i), SBS_locy(i));
        rec_power = la.cal_received_power(distance);
        received_Power_List(j, i) =  rec_power;
    end
end

for z = 1: length(User_List)

while true  
    target_SBS = find_max_in_row(received_Power_List, z);
    if(Channel_List(target_SBS(2)) == 0)
        received_Power_List(z, target_SBS(2)) = 0;
    else
        break;
    end
end

Channel_List(target_SBS(2)) = Channel_List(target_SBS(2)) - 1;
if(Channel_List(target_SBS(2)) < 0)
    Channel_List(target_SBS(2)) = 0;
end

target_SBS_List = [target_SBS_List, target_SBS(2)];
end
end 

%% pa user divice to MBS in downlink
function [target_MBS_List, current_device_perMBS] = pa_dl_connection_algorithm(User_List, MBS_List, ...
                                                        User_locx, User_locy, User_bitsin, ...
                                                        MBS_locx, MBS_locy, MBS_device_cap)

global test_UDs MBS;
lb = latency_funcs;
weighted = 0.7;
target_MBS_List = [];
MBS_num = length(MBS_List);
current_device_perMBS = [];
received_Power_List2 = zeros(length(User_List), length(MBS_List));

parfor j = 1: length(User_List)
    for i = 1: MBS_num
        distance = lb.distance(User_locx(j), User_locy(j), MBS_locx(i), MBS_locy(i));
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
        distance = lb.distance(User_locx(z), User_locy(z), ...
                                MBS_locx(optional_MBS_List(e)), MBS_locy(optional_MBS_List(e)));
        lat_exe = lb.exe_latency(0.2, 1900, User_bitsin(z), MBS_device_cap(optional_MBS_List(e))+1);
        lat_dl = lb.downlink_latency(distance, lat_exe(2));

        score = lat_dl*weighted + lat_exe(1)*(1 - weighted);
        score_List = [score_List, score];
    end

    target_MBS = find_min_in_row(score_List);
    MBS_device_cap(target_MBS(2)) = MBS_device_cap(target_MBS(2)) + 1;
    current_device_perMBS = [current_device_perMBS, MBS_device_cap(target_MBS(2))];
    target_MBS_List = [target_MBS_List, target_MBS(2)];
end
target_MBS_List;
end


% function [target_SBS_Id, new_Channel_List] = dl_connection_algorithm(Channel_List, received_Power_List,...
%                                                        x, y, MBS_num, flag)
% global MBS;
% la = latency_funcs;
% loc_x = x;
% loc_y = y;
% 
% if(flag == 0)
%     %local_received_Power_List = zeros(1, MBS_num);
%     for i = 1:MBS_num %parallel imple
%         distance = la.distance(loc_x, loc_y, SBS.loc_x(i), SBS.loc_y(i));
%         rec_power = la.cal_received_power(distance);
%         %local_received_Power_List(i) = rec_power;
%         received_Power_List = [received_Power_List, rec_power]; % data dependency
%     end
%     %received_Power_List = sum(local_received_Power_List, 2);
% end
% 
%     target_SBS = findMax(received_Power_List)
%     if(Channel_List(target_SBS(2)) == 0)
%         received_Power_List(target_SBS(2)) = [];
%         Channel_List(target_SBS(2)) = [];
%         %reclursive part
%         Lookup_connection_algorithm(Channel_List, received_Power_List, x, y, SBS_num-1, 1);
%     end
%     Channel_List(target_SBS(2)) = Channel_List(target_SBS(2)) - 1;
%     new_Channel_List = Channel_List;
%     target_SBS_Id = target_SBS(2);
% 
% end 
