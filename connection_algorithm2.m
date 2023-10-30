function connection_algorithm2 = con_alg2
    connection_algorithm2.ul_dyn_assign_algorithm = @ul_dyn_assign_algorithm;
    connection_algorithm2.dl_dyn_assign_algorithm = @dl_dyn_assign_algorithm;
    connection_algorithm2.coupled_connection_algorithm = @coupled_connection_algorithm;
    connection_algorithm2.rand_assign_algorithm = @rand_assign_algorithm;
end

function [ul_BS_List, ul_BS_sort, ul_device_perUD] = ul_dyn_assign_algorithm(Channel_List,User_List, SBS_List, MBS_List)

global SBS test_UDs;
la = latency_funcs;
le = Load_environment_variable;
ul_BS_List = [];
ul_BS_sort = [];
ul_device_perUD = [];
%current_capacity_perUD = [];
replica_SBSdevice_List = le.invert_List(Channel_List);
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
replica_SBSdevice_List(target_SBS(2)) = replica_SBSdevice_List(target_SBS(2)) + 1;
ul_BS_sort = [ul_BS_sort, 1]; 
%current_capacity_perUD = [current_capacity_perUD, Channel_List(target_SBS(2))];
if(Channel_List(target_SBS(2)) < 0)
    Channel_List(target_SBS(2)) = 0;
end
ul_BS_List = [ul_BS_List, target_SBS(2)];
ul_device_perUD = [ul_device_perUD, replica_SBSdevice_List(target_SBS(2))];
end
end

function [dl_BS_List, dl_BS_sort, dl_device_perUD] = dl_dyn_assign_algorithm(replica_SBScap_List, replica_MBSdevice_List, User_List, SBS_List, MBS_List)
    la = latency_funcs;
    le = Load_environment_variable;
    global SBS MBS test_UDs;
    SBS_num = length(SBS_List);
    MBS_num = length(MBS_List);
    replica_SBSdevice_List = le.invert_List(replica_SBScap_List);
    BS_device_List = [replica_SBSdevice_List, replica_MBSdevice_List];
    BS_List = [SBS_List, MBS_List];
    dl_BS_sort = [];
    dl_BS_List = [];
    dl_device_perUD = [];
    MBS_received_Power_List = zeros(length(User_List), length(MBS_List));
    SBS_received_Power_List = zeros(length(User_List), length(SBS_List));
    
for j = 1: length(User_List)
    for i = 1: length(BS_List)
        if(i <= SBS_num)
            distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), SBS.loc_x(BS_List(i)), SBS.loc_y(BS_List(i)));
        elseif(i > SBS_num)
            distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), MBS.loc_x(BS_List(i)), MBS.loc_y(BS_List(i)));
        end
        rec_power = la.cal_received_power(distance);
        received_Power_List(j, i) =  rec_power;
    end
end

for j = 1: length(User_List)
    for i = 1: length(MBS_List)
        distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), MBS.loc_x(MBS_List(i)), MBS.loc_y(MBS_List(i)));
        rec_power = la.cal_received_power(distance);
        MBS_received_Power_List(j, i) =  rec_power;
    end
end

for z = 1: length(User_List)
sort = 0;  
target_BS = find_max_in_row(received_Power_List, z); %find the max receive power bs in downlink
if(target_BS(2) <= SBS_num && sum(replica_SBScap_List) > 0)
    if(replica_SBScap_List(target_BS(2)) == 0)  
        target_BS = find_max_in_row(MBS_received_Power_List, z);
        sort = sort + 2; 
    else
        replica_SBScap_List(target_BS(2)) = replica_SBScap_List(target_BS(2)) - 1;
        sort = sort + 1;
    end
elseif(target_BS(2) <= SBS_num && sum(replica_SBScap_List) <= 0)%while SBS's capacity<=0, assign UD to MBS
        target_BS = find_max_in_row(MBS_received_Power_List, z);
        sort = sort + 2;    
elseif(target_BS(2) > SBS_num)
        sort = sort + 2;     
end
BS_device_List(target_BS(2)) = BS_device_List(target_BS(2)) + 1;
dl_device_perUD = [dl_device_perUD, BS_device_List(target_BS(2))];
dl_BS_sort= [dl_BS_sort, sort];
dl_BS_List = [dl_BS_List, BS_List(target_BS(2))];
end
end


function [BS_sort, coupl_BS_List, device_perUD] = coupled_connection_algorithm(replica_SBScap_List, replica_MBSdevice_List, ...
                                                                                User_List, SBS_List, MBS_List)
la = latency_funcs;
le = Load_environment_variable;
replica_SBSdevice_List = le.invert_List(replica_SBScap_List);
global SBS MBS test_UDs;
SBS_num = length(SBS_List);
MBS_num = length(MBS_List);
BS_List = [SBS_List, MBS_List];
BS_device_List = [replica_SBSdevice_List, replica_MBSdevice_List];
received_Power_List = zeros(length(User_List), length(BS_List));
MBS_received_Power_List = zeros(length(User_List), length(MBS_List));
SBS_received_Power_List = zeros(length(User_List), length(SBS_List));
BS_sort = [];
device_perUD = [];
coupl_BS_List = [];

for j = 1: length(User_List)
    for i = 1: length(BS_List)
        if(i <= SBS_num)
            distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), SBS.loc_x(BS_List(i)), SBS.loc_y(BS_List(i)));
        elseif(i > SBS_num)
            distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), MBS.loc_x(BS_List(i)), MBS.loc_y(BS_List(i)));
        end
        rec_power = la.cal_received_power(distance);
        received_Power_List(j, i) =  rec_power;
    end
end

for j = 1: length(User_List)
    for i = 1: length(MBS_List)
        distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), MBS.loc_x(MBS_List(i)), MBS.loc_y(MBS_List(i)));
        rec_power = la.cal_received_power(distance);
        MBS_received_Power_List(j, i) =  rec_power;
    end
end

% for j = 1: length(User_List)
%     for i = 1: length(SBS_List)
%         distance = la.distance(test_UDs.test_loc_x(j), test_UDs.test_loc_y(j), SBS.loc_x(SBS_List(i)), SBS.loc_y(SBS_List(i)));
%         rec_power = la.cal_received_power(distance);
%         SBS_received_Power_List(j, i) =  rec_power;
%     end
% end

for z = 1: length(User_List)
sort = 0;  
target_BS = find_max_in_row(received_Power_List, z); %find the max receive power bs in downlink
if(target_BS(2) <= SBS_num && sum(replica_SBScap_List) > 0)
    if(replica_SBScap_List(target_BS(2)) == 0)
%         while true
%             received_Power_List(z, target_BS(2)) = 0;
%             target_BS = find_max_in_row(received_Power_List, z);
%             if(replica_SBScap_List(target_BS(2)) > 0 && target_BS(2) <= SBS_num)
%                 replica_SBScap_List(target_BS(2)) = replica_SBScap_List(target_BS(2)) - 1;
%                 break;
%             elseif(target_BS(2) > SBS_num)
%                 sort = sort + 2;
%                 break;
%             end
%         end
%         
        target_BS = find_max_in_row(MBS_received_Power_List, z);
        sort = sort + 2; 
    else
        replica_SBScap_List(target_BS(2)) = replica_SBScap_List(target_BS(2)) - 1;
        sort = sort + 1;
    end
elseif(target_BS(2) <= SBS_num && sum(replica_SBScap_List) <= 0)%while SBS's capacity<=0, assign UD to MBS
        target_BS = find_max_in_row(MBS_received_Power_List, z);
        sort = sort + 2;    
elseif(target_BS(2) > SBS_num)
        sort = sort + 2;     
end
BS_device_List(target_BS(2)) = BS_device_List(target_BS(2)) + 1;
device_perUD = [device_perUD, BS_device_List(target_BS(2))];
BS_sort= [BS_sort, sort];
coupl_BS_List = [coupl_BS_List, BS_List(target_BS(2))];
end
end   


%% user divice decoupled random assigned algorithm for comparsion
function [ul_BS_sort, dl_BS_sort, ul_BS_List, dl_BS_List, ul_device_perUD, dl_device_perUD] = rand_assign_algorithm(replica_SBScap_List, ...
                                                                                                                    replica_MBSdevice_List, ...
                                                                                                                    User_List, SBS_List, MBS_List)
le = Load_environment_variable;
replica_SBSdevice_List = le.invert_List(replica_SBScap_List);
global SBS MBS test_UDs;
SBS_num = length(SBS_List);
MBS_num = length(MBS_List);
BS_List = [SBS_List, MBS_List];
BS_device_List = [replica_SBSdevice_List, replica_MBSdevice_List];
ul_BS_sort = [];
dl_BS_sort = [];
ul_BS_List = [];
dl_BS_List = [];
ul_device_perUD = [];
dl_device_perUD = [];

for j = 1: length(User_List)
 
    ul_rand = randi([1,SBS_num+MBS_num]);
    dl_rand = randi([1,SBS_num+MBS_num]);
    for i = 1:2
        bs_sort = 0;
        if(i==1) rand = ul_rand; end
        if(i==2) rand = dl_rand; end
        if (rand <= SBS_num && sum(replica_SBScap_List) > 0) %when we choose SBS
            if(replica_SBScap_List(rand) == 0)
                while true
                    rand = randi([1,SBS_num]);
                    if((replica_SBScap_List(rand) > 0))
                        break;
                    end
                end
            end
            replica_SBScap_List(rand) = replica_SBScap_List(rand) - 1;
            bs_sort = bs_sort + 1; %bs_sort=1 means SBS
        elseif(rand > SBS_num) % when we choose MBS
            bs_sort = bs_sort + 2; %bs_sort=2 means MBS
        elseif(rand <= SBS_num && sum(replica_SBScap_List) <= 0)%while SBS's capacity<=0, assign UD to MBS
            rand = randi([SBS_num+1,SBS_num+MBS_num]);
            %BS_device_List(rand) = BS_device_List(rand) + 1;
            bs_sort = bs_sort + 2; %bs_sort=2 means MBS
        end
        
        BS_device_List(rand) = BS_device_List(rand) + 1;
        if(i == 1)
        ul_BS_List = [ul_BS_List, BS_List(rand)];
        ul_BS_sort = [ul_BS_sort, bs_sort];
        ul_device_perUD = [ul_device_perUD, BS_device_List(rand)];
        end
        if(i == 2)
        dl_BS_List = [dl_BS_List, BS_List(rand)];
        dl_BS_sort = [dl_BS_sort, bs_sort];
        dl_device_perUD = [dl_device_perUD, BS_device_List(rand)];
        end
    end
end
end

