% Steady-State 1D Heat Diffusion in a Rod using Finite Volume Method
% Half-Control Volume method at Boundaries

clear; clc; close all

% Given parameters
L = 0.5;            % Length of the rod (m)
A_c = 10e-3;        % Cross-sectional area (m^2)
k = 1000;           % Thermal conductivity (W/mK)
N = 50;             % Number of cells
T_A = 100;          % Boundary temperature at x=0 (deg C)
T_B = 500;          % Boundary temperature at x=L (deg C)

dx = L/N;           % Cell width (uniform grid)

% Base conductance
a_base = k*A_c/dx;      

% Set up system matrices
A = zeros(N,N);     % Coefficient matrix
b = zeros(N,1);     % Right-hand side vector

% Loop through all cells
for i = 1:N
    if i == 1
        % First internal node (near boundary at A)
        aW = 2 * a_base;  % doubled conductance at boundary
        aE = a_base;
        aP = aW + aE;
        
        A(i,i) = aP;
        A(i,i+1) = -aE;
        b(i) = aW * T_A;
        
    elseif i == N
        % Last internal node (near boundary at B)
        aW = a_base;
        aE = 2 * a_base;  % doubled conductance at boundary
        aP = aW + aE;
        
        A(i,i) = aP;
        A(i,i-1) = -aW;
        b(i) = aE * T_B;
        
    else
        % Internal nodes
        aW = a_base;
        aE = a_base;
        aP = aW + aE;
        
        A(i,i-1) = -aW;
        A(i,i)   = aP;
        A(i,i+1) = -aE;
    end
end

% Solve the linear system
T = A\b;

% Plotting the temperature distribution
x = linspace(0, L, N);
plot(x, T, 'r-o');
xlabel('Position along the rod (m)');
ylabel('Temperature (°C)');
title('Steady-State Temperature Distribution');
grid on;
