xmin = 0;
xmax = 0.2;                    % Length of rod
N = 10;                        % Number of nodes
dx = (xmax - xmin) / (N - 1);  % Grid size
x = xmin:dx:xmax;

dt = 1e-3;                     % Time step size
tmax = 0.5;                    % Maximum simulation time
t = 0:dt:tmax;

alpha = 0.05;                  % Diffusion coefficient

% Initial and boundary conditions
Tcurrent = ones(1, N) * 20;    % Initial temperature
Tb = 200;                      % Boundary condition at base
Ttip = 20;                     % Boundary condition at tip

% Solution parameter
d = alpha * dt / dx^2;

% Storage for visualization
T_all = zeros(length(t), N);
T_all(1, :) = Tcurrent;

for j = 2:length(t)            % Loop over time
    T = Tcurrent;
    for i = 1:N                % Loop over space
        if i == 1
            T(i) = Tb;
        elseif i == N
            T(i) = Ttip;
        else
            T(i) = Tcurrent(i) + d * (Tcurrent(i+1) - 2*Tcurrent(i) + Tcurrent(i-1));
        end
    end
    Tcurrent = T;
    T_all(j, :) = Tcurrent;    % Store for later use
end

% Plot final temperature distribution
plot(x, Tcurrent, '-o');
xlabel('Position (m)');
ylabel('Temperature (°C)');
title('1D Unsteady Heat Conduction at Final Time');
grid on;
