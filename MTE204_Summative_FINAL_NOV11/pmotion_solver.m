 %{
PARTICLE (PLANET / POINT MASS) MOTION SOLVER USING EULERS METHOD 

this function is to calculate the motion of the planets based on their 
initial velocity
solarsystemdata.mat includes all the initial values of the primary orbiting bodies pulled from https://ssd.jpl.nasa.gov/

comment out 'clear;' if having issues with code not running when excecuted
clear is used to make sure we start the simulation with a clean workspace
and rescan any data files

NOTE (October 30th,2017):
Initially this code was attempting to solve a general 10-body problem but
is being pivoted specifically to a solar system model. Incase of confusion
in variable naming please keep this in mind. (i.e. total_bodies basically
means total_planets.)
%}

clear;
cf = 3.318;
%INITIALIZATION BLOCK ------------------------------------------------
%INITIALIZE AFTER THIS LINE TO AVOID ISSUES WITH CLEAR COMMAND 

load solarsystemdata.mat;   %load data from solarsystemdata.mat file (inital values for solver)

G = 6.67e-11; %forceitational Consant

%Execution time params. runtime_days (days to simulate) dt (step size sec)
numyears = 50;
runtime_days =  365.25 * cf*numyears;
dt = 10000;

%reset_sec is a counter to write data to file or array (implementation
%flexible). Make number smaller to write more data.
reset_sec = 75;

spd = 60*60*24; %seconds per day as a constant
total_runtime = (runtime_days * spd) /dt; %runtime of simulation in seconds


AU=149597870691;    %might use to convert to meters and AU used to scale large distances
KM = 1000;
%---------------------------------------------------------------------

%Setup 10 Bodies (Planets) using database from JPL (ephemeride data), also
%correct for AU data into KM
%find size of data set and create storage for data and corrected values
[total_bodies,range] = size(planets_scaled);
for col =1:total_bodies;
    planets(col,1) = planets_scaled(col,1)* KM;
    planets(col,2) = planets_scaled(col,2)* KM;
    planets(col,3) = planets_scaled(col,3)* KM;

    planets(col,4) = planets_scaled(col,4)* KM;
    planets(col,5) = planets_scaled(col,5)* KM;
    planets(col,6) = planets_scaled(col,6)* KM;
    planets(col,7) = planets_scaled(col,7);
end

%{ 
October 31st, 2017
attempted to track palentary values with arrays but 
it was too slow at long runtimes
position = randn(10,2);
F = zeros(10,2);
m = randn(10,1);
V = randn(10,2);
SWITCHED TO WRITING DATA TO BINARY FILE INSTEAD OF GROWING AN ARRAY(MUCH
FASTER R/W) AND CONVINENT FOR DRAWING PLOT 
%}

buffer_data = fopen('test.bin','w');

for timer = 1:total_runtime;
    for i = 1 : total_bodies ;
        mass_a = planets(i,7);
        velocity_i = [planets(i,4),planets(i,5),planets(i,6)];
        position_i = [planets(i,1),planets(i,2),planets(i,3)];

        net_force_i = [0,0,0]; %initialize operational vector
 
        %only necessary to calculate the force vector from a->b. 
        %b-> a is given by newtons third law. - (a->b) = (b->a)
        for j = (i+1):total_bodies
            
            %initialize position/mass body b
            mass_b = planets(j,7);
            pos_b = [planets(j,1),planets(j,2),planets(j,3)];
            
            %direction vector & unit vector solved
            dir_vec =  pos_b -position_i; 
            pos_vector.mag = sqrt((dir_vec(1)^2) + (dir_vec(2)^2) + (dir_vec(3)^2));
            unit_vec = dir_vec * (1 / pos_vector.mag);
            
            %calculate force (forceity for solar system model) vector
            pos_vector.force = ((mass_a * mass_b * G) / (pos_vector.mag^2));
            force = unit_vec * pos_vector.force;

            %newtons third law shows fij = -fji allowing a reduction of the #
            %of force calulations using a split loop over the top upper/lower
            %matrix
            force_vector.x(i,j) = force(1)* -1;
            force_vector.y(i,j) = force(2)* -1;
            force_vector.z(i,j) = force(3)* -1;
            force_vector.x(j,i) = force(1);
            force_vector.y(j,i) = force(2);
            force_vector.z(j,i) = force(3);
        end
        
        %calculate net force on body (planet) (x,y,z)
        net_force_i(1) = sum(force_vector.x(:,i));
        net_force_i(2) = sum(force_vector.y(:,i));
        net_force_i(3) = sum(force_vector.z(:,i));

        %Apply Eulers Method and Update planet data
        net_force_i = (net_force_i * dt) / mass_a;
        new_velocity_i = velocity_i + net_force_i;
        new_position_i = position_i + (new_velocity_i * dt);
        
        %update data postition and velocity
        planets(i,1:3) = new_position_i;
        planets(i,4:6) = new_velocity_i;
    end

    %once reset_sec satisfies remainder 0 against the timer sample data and
    %writie to file (this keeps looping to update our file as frequently as
    %you want depending on reset_sec value. 
    if rem(timer,reset_sec) == 0
        disp((timer /total_runtime)*100);
        for i = 1:total_bodies
            planet_out(((3*i) - 2)) = planets(i,1); %x position values
            planet_out(((3*i) - 1)) = planets(i,2); %y position values
            planet_out((3*i)) = planets(i,3);       %z position values
        end
       fwrite(buffer_data,planet_out(:),'*double');  
    end
end

planet_list = ["Sun","Mercury","Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune","Moon"];
%outpot final positions for all planets
for p = 1:total_bodies
    planet_list(p)
    planets(i,1)
    planets(i,2)
    planets(i,3)
end

fclose(buffer_data);    %close binary file to allow animators access 