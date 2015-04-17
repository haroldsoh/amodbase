%%  genStarNetworkData.m
%   Author: Harold Soh, 2015
%   generates sample data to test the amod base system

%% Parameters
clear();
rand(10); %setup rng
num_vehs = 500;
num_custs = 2000;

% probability of working at the central location
prob_work_at_central = 0.9;

% probability of taking amod during the different time sessions
prob_amod_morn = 0.9;
prob_amod_aftn = 0.6;
prob_amod_even = 0.5;

%% Generate the locations and stations

% generate center position
locs = [5000, 5000];

% generate satellite centers (stations)
locs = [locs; genSatellitePositions(locs(1,:), [4000 4000], 4)];
stations = locs;
nstations = size(locs,1);

% generate extra locations surrounding each station
nlocs = length(locs);
for i=1:nlocs
    start_pos = [-1000, 0];
    locs = [locs; genSatellitePositions(locs(i,:), start_pos, 4)];
end

nlocs = length(locs);
central_nodes = [1, 6:9];
ncentral = length(central_nodes);
surrounding_nodes = setdiff( 1:nlocs, central_nodes);
nsurrounding = length(surrounding_nodes);
% plot locs
subplot(1,2,1); hold on;
scatter(locs(:,1), locs(:,2));

%% generate vehicles
veh_pos = zeros(num_vehs, 2);
for i=1:num_vehs
   st_id = mod(i, nstations) + 1;
   veh_pos(i,:) = locs(st_id, :) + (rand(1,2)*2 - 1)*300;
end

scatter(veh_pos(:,1), veh_pos(:,2), '+');

%% generate customers
% customers are initially mostly located in the satellite areas
% split customers evenly among the locations surrounding each station

cust_home_pos = zeros(num_custs, 2);
cust_work_pos = zeros(num_custs, 2);

for i=1:num_custs
    % get home location
    home_loc_id = mod(i, nlocs-nstations) + nstations + 1;
    cust_home_pos(i,:) = locs(home_loc_id, :) + (rand(1,2)*2 - 1)*100;
    
    % get work location
    if (rand() < prob_work_at_central) 
        work_loc_id = central_nodes(randi([1,ncentral]));
    else
        work_loc_id = surrounding_nodes(randi([1,nsurrounding]));
    end
    
    cust_work_pos(i,:) = locs(work_loc_id, :) + (rand(1,2)*2 - 1)*100;
    
end

scatter(cust_home_pos(:,1), cust_home_pos(:,2), '*'); hold on;
scatter(cust_work_pos(:,1), cust_work_pos(:,2), '.');
%% generate bookings
% we split the bookings into three time periods

% morning
% travel to work from home
% 0 time is 6:00am. peak is 8:00am (7200s), end morning session is 10:00am
% (14400). Using a truncated gaussian
morn_travel_times = normrnd(7200, 0.8*60*60, num_custs, 1);
morn_travel_times = max(0, morn_travel_times);
morn_travel_times = min(morn_travel_times, 14400);

morn_bookings = [morn_travel_times(:) [1:num_custs]' cust_work_pos];
morn_travel_modes = rand(num_custs,1) < prob_amod_morn;

% afternoon
% random local travel among the stations near to work
% 3-6 hours after initial travel (peak at 4 hours)
% 6 hours max
aftn_travel_times = morn_bookings(:,1) + min(...
    max(0, normrnd( 16200, 6000, num_custs, 1 )) , 21600);
aftn_travel_modes = rand(num_custs,1) < prob_amod_aftn;

% night 
% travel back to home
% 4-8 hours after initial travel (peak at 6 hours)
% 8 hours max
even_travel_times = aftn_travel_times(:,1) + min(...
    max(0, normrnd( 6*60*60, 3*60*60, num_custs, 1 )) , 8*60*60);

even_travel_modes = rand(num_custs,1) < prob_amod_even;


all_travel_times = [morn_travel_times; aftn_travel_times; even_travel_times];
all_travel_modes = [morn_travel_modes; aftn_travel_modes; even_travel_modes];


bookings = [all_travel_times repmat([1:num_custs]', 3, 1) all_travel_modes];


% plot histogram of travel
subplot(1,2,2);
hist(21600 + all_travel_times(all_travel_modes), 50);

ticks = [21600:3600:(68400 + 21600)];
tick_labels = cell(length(ticks),1);
for i=1:length(ticks)
    tick_labels{i} = datestr(ticks(i)/86400, 'HH');
end
    
ax = gca;
set(ax, 'xtick',ticks);
set(ax, 'xticklabel', tick_labels);

%% 
subplot(1,2,1);
scatter(locs(central_nodes, 1), locs(central_nodes, 2));
hold off

%% save data to disk

% save locations
dlmwrite('starnetwork_locs.txt', locs, ' ');

% save stations
dlmwrite('starnetwork_stns.txt', stations, ' ');

% save vehicles
dlmwrite('starnetwork_vehs.txt', veh_pos, ' ');

% save customers
dlmwrite('starnetwork_custs.txt', cust_home_pos, ' ');

% save bookings
dlmwrite('starnetwork_books.txt', bookings, ' ');

% done!