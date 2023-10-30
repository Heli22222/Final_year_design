function environment = envir
    environment.create_DataBase = @create_DataBase;
    environment.Load_SBS = @Load_SBS;
    environment.Load_MBS = @Load_MBS;
    environment.Load_UD = @Load_UD;
    environment.Load_test_UD = @Load_test_UD;
    environment.int_connection_assignment = @int_connection_assignment;
    environment.invert_List = @invert_List;
end

function create_DataBase()
global SBS MBS UDs M_MEC test_UDs mSBS;
SBS = struct('SBS_Id', 'loc_x', 'loc_y', 'Channel_cap', 'capacity', {14}); % 'Max_trans_power', {30}
mSBS = struct('SBS_Id', 'loc_x', 'loc_y', 'Channel_cap', 'capacity', {14});
MBS = struct('MBS_Id', 'loc_x', 'loc_y', 'Channel_cap'); % 'Max_trans_power', {46}
UDs = struct('UD_Id', 'loc_x', 'loc_y', 'bits_in');
test_UDs = struct('test_UD_Id', 'test_loc_x', 'test_loc_y', 'bits_in');
M_MEC = struct('alpha',{0.2}, 'beta', {} ,'com_Cap', {3.6*10^8});
end

function  [SBS_Id, SBS_x, SBS_y, CHANNEL] = Load_SBS(numq)
SBS_Id = [];
SBS_x = [];
SBS_y = [];
CHANNEL = [];
for i = 1 : numq 
    SBS_Id = [SBS_Id, i];
    CHANNEL = [CHANNEL, 14]; %sub channel capacity fixed as 14 per basestation
end
    SBS_x = 500*rand(1, numq);
    SBS_y = 500*rand(1, numq);
end

function  [MBS_Id, MBS_x, MBS_y, CHANNEL] = Load_MBS(numz)
MBS_Id = [];
MBS_x = [];
MBS_y = [];
CHANNEL = [];
for i = 1 : numz
    MBS_Id = [MBS_Id, i];
    CHANNEL = [CHANNEL, 200]; %sub channel capacity fixed as 200 per basestation
end
    MBS_x = 500*rand(1, numz);
    MBS_y = 500*rand(1, numz);
end

function  [UD_Id, UD_x, UD_y, UD_bits] = Load_UD(nump)
UD_Id = [];
UD_x = [];
UD_y = [];
UD_bits = []; %UD_BITS fix 6*10^6.
for i = 1 : nump
    UD_Id = [UD_Id, i];
    UD_bits = [UD_bits, 6*10^6];
end
    UD_x = 500*rand(1, nump);
    UD_y = 500*rand(1, nump);
end

function  [t_UD_Id, t_UD_x, t_UD_y, t_UD_bits] = Load_test_UD(numz)
t_UD_Id = [];
t_UD_x = [];
t_UD_y = [];
t_UD_bits = []; %UD_BITS fix 6*10^6.
for i = 1 : numz
    t_UD_Id = [t_UD_Id, i];
    t_UD_bits = [t_UD_bits, 6*10^6];
end
    t_UD_x = 500*rand(1, numz);
    t_UD_y = 500*rand(1, numz);
end

function [UDs_on_SBS] = invert_List(channel_cap_List)
global SBS;
UDs_on_SBS = [];
    for i = 1: length(channel_cap_List)
        UDs_on_SBS = [UDs_on_SBS, (SBS.capacity - channel_cap_List(i))];
    end
end


