clear
clc
close all
format long
rocket.mass_init = 41.996; % initial mass
rocket.mass_final =30; % final mass
g = 9.81; % g
%at time 0
rocket_vel = 0; %RK4 Variable % extrapolating acceleration in orde to get v
rocket_isp = 180; % isp from wiki
rocket.alt = 0; % alt 0 at t=0
ti = 0; % initial time
step = 0.001; % time step
tf = 40; % final time
tSteps = ti:step:tf; % total run time in steps
h = 0.1; % runge kutta step (number of points for rk step)
% time = 0;
rocket_mass = rocket.mass_init; % mass
alt = []; % for plotting at end, initialisation
time = [];
vel = [];
mass = [];
res = [];
mach = [];
hybrid_burn_time = 15; % burn time
cd = 0.6;
sref = 0.0201;
rocket.mass_flow = 1000/(g*rocket_isp); % nasa eqn to get mass flow
%Takes thrust curves, returns variable holding total thrust over time
booster = readmatrix('K250Curve.csv'); % data from aerotech booster
hybrid = readmatrix('HybridCurve.csv'); % thurst curve provided
x = linspace(0,tf,tf/step); % remove 0 values
y = 2.*interp1(booster(:,1),booster(:,2),x);
y(isnan(y)== 1) = 0;
hybrid = interp1(hybrid(:,1),hybrid(:,2),x);
hybrid(isnan(hybrid)== 1) = 0;
rocket_thrust = (hybrid + y);
plot(rocket_thrust, time);
count = 0; % debug


for i = 1:length(tSteps)-1 % for full time range
    % disp(i);
    % call function to read thrust value and calculate as appropriate, mach
    % correction
    f = @(v,i,rho,a,idx) (rocket_thrust(idx)-(rocket_mass(idx)*g)-(0.5*rho*v^2*cd*sref)./(1-(v./a)^2))./rocket_mass(idx);
    [~,a,~,rho] = atmosisa(rocket.alt); % atmospheric values needed
    k1 = h*f(rocket_vel(i), tSteps(i),rho,a,i); % interpolate once to get first point
    k2 = h*f(rocket_vel(i) + k1/2, tSteps(i)+ h/2,rho,a,i); % interpolate using first point for k
    k3 = h*f(rocket_vel(i) + k2/2,tSteps(i)+ h/2,rho,a,i); % interpolate using 2 preceeding for k
    k4 = h*f(rocket_vel(i) + k3, tSteps(i)+ h,rho,a,i); % interpolate using 3 preceeding values for k
    rocket_vel(i+1) = rocket_vel(i) + k1/6 + k2/3 + k3/3 + k4/6; % gain next value of velocity (for next time step), log velocity in array
    rocket.alt = rocket.alt + rocket_vel(i)*step; % calculate alr=titude based on current velocity and time step
%     if rocket_mass(i) >= rocket.mass_final
%         rocket_mass(i+1) = rocket_mass(i) - rocket.mass_flow*step;
%     else
%         rocket_mass(i+1) = rocket_mass(i);
%     end
%     alt(end+1) = rocket.alt;
    vel(end+1) = rocket_vel(i); % write to next array index
    time(end+1) = i;
    mass(end+1) = rocket_mass(i);
    mach(end+1) = rocket_vel(i)/a;
    % disp(count+1);
end
subplot(2,2,1) % plot as appropriate
plot(time,alt)
xlabel('Time (s)')
ylabel('Altitude (m)')
%xlim([0 maxT])
title('Altitude vs Time')
grid
subplot(2,2,2)
plot(time,vel)
xlabel('Time (s)')
ylabel('Velocity (m s^-1)')
%xlim([0 maxT])
grid
title('Velocity vs Time')
subplot(2,2,3)
plot(time,res)
xlabel('Time (s)')
ylabel('Resultant acceleration (ms-2)')
%xlim([0 maxT])
grid
title('Resultant acceleration (ms-2)')
subplot(2,2,4)
plot(time,mach)
title('Mach number')
xlabel('Time (s)')
ylabel('Mach number')
grid
% figure
% plot(time,mass)
% title('Mass')
% xlabel('Time (s)')
% ylabel('Mass (kg)')
% grid