clear all
close all
clc

% Defining the problem domain
n_points = 51; % Number of points
dom_length = 1;
h = dom_length/(n_points-1);
x = 0:h:dom_length;
y = 0:h:dom_length;
Re = 100; % Reynolds number
nu = 1/Re;

% Under-relaxation factors
alpha = 0.8;
alpha_p = 0.8;

% Initializing the variables
u_final(n_points,n_points) = 0;
v_final(n_points,n_points) = 0;
p_final(n_points,n_points) = 1;
u_final(1,:) = 1;

u(n_points+1,n_points) = 0;
u_star(n_points+1,n_points) = 0;
d_e(n_points+1,n_points) = 0;
v(n_points,n_points+1) = 0;
v_star(n_points,n_points+1) = 0;
d_n(n_points,n_points+1) = 0;
p(n_points+1,n_points+1) = 1;
p_star(n_points+1,n_points+1) = 1;
pc(n_points+1,n_points+1) = 0;
b(n_points+1,n_points+1) = 0;
u(1,:) = 2;

u_new(n_points+1,n_points) = 0;
v_new(n_points,n_points+1) = 0;
p_new(n_points+1,n_points+1) = 1;
u_new(1,:) = 2;

% Solving the governing equations
error = 1;
iterations = 0;
error_req = 1e-7; % Required residual error

while error > error_req
    % x-momentum equation - Interior
    for i = 2:n_points
        for j = 2:n_points-1
            u_E = 0.5*(u(i,j) + u(i,j+1));
            u_W = 0.5*(u(i,j) + u(i,j-1));
            v_N = 0.5*(v(i-1,j) + v(i-1,j+1));
            v_S = 0.5*(v(i,j) + v(i,j+1));

            a_E = -0.5*u_E*h + nu;
            a_W = 0.5*u_W*h + nu;
            a_N = -0.5*v_N*h + nu;
            a_S = 0.5*v_S*h + nu;

            a_e = 0.5*u_E*h - 0.5*u_W*h + 0.5*v_N*h - 0.5*v_S*h + 4*nu;

            A_e = -h;
            d_e(i,j) = A_e/a_e;

            u_star(i,j) = (a_E*u(i,j+1) + a_W*u(i,j-1) + a_N*u(i-1,j) + a_S*u(i+1,j))/a_e + d_e(i,j)*(p(i,j+1) - p(i,j));
        end
    end

    % x-momentum equation - Boundary
    u_star(1,:) = 2 - u_star(2,:);
    u_star(n_points+1,:) = -u_star(n_points,:);
    u_star(2:n_points,1) = 0;
    u_star(2:n_points,n_points) = 0;

    % y-momentum equation - Interior
    for i = 2:n_points-1
        for j = 2:n_points
            u_E = 0.5*(u(i,j) + u(i+1,j));
            u_W = 0.5*(u(i,j-1) + u(i+1,j-1));
            v_N = 0.5*(v(i-1,j) + v(i,j));
            v_S = 0.5*(v(i,j) + v(i+1,j));

            a_E = -0.5*u_E*h + nu;
            a_W = 0.5*u_W*h + nu;
            a_N = -0.5*v_N*h + nu;
            a_S = 0.5*v_S*h + nu;

            a_n = 0.5*u_E*h - 0.5*u_W*h + 0.5*v_N*h - 0.5*v_S*h + 4*nu;

            A_n = -h;
            d_n(i,j) = A_n/a_n;

            v_star(i,j) = (a_E*v(i,j+1) + a_W*v(i,j-1) + a_N*v(i-1,j) + a_S*v(i+1,j))/a_n + d_n(i,j)*(p(i,j) - p(i+1,j));
        end
    end

    % y-momentum equation - Boundary
    v_star(:,1) = -v_star(:,2);
    v_star(:,n_points+1) = -v_star(:,n_points);
    v_star(1,2:n_points) = 0;
    v_star(n_points,2:n_points) = 0;

    pc(:,:) = 0;

    % Pressure correction (continuity) equation - Interior
    for i = 2:n_points
        for j = 2:n_points
            a_E = -d_e(i,j)*h;
            a_W = -d_e(i,j-1)*h;
            a_N = -d_n(i-1,j)*h;
            a_S = -d_n(i,j)*h;
            a_P = a_E + a_W + a_N + a_S;

            b(i,j) = -(u_star(i,j) - u_star(i,j-1))*h + (v_star(i,j) - v_star(i-1,j))*h;

            pc(i,j) = (a_E*pc(i,j+1) + a_W*pc(i,j-1) + a_N*pc(i-1,j) + a_S*pc(i+1,j) + b(i,j))/a_P;
        end
    end

    % Pressure correction - Boundary
    p_new(1,:) = p_new(2,:);
    p_new(n_points+1,:) = p_new(n_points,:);
    p_new(:,1) = p_new(:,2);
    p_new(:,n_points+1) = p_new(:,n_points);

    % Correct pressure
    for i = 2:n_points
        for j = 2:n_points
            p_new(i,j) = p(i,j) + alpha_p*pc(i,j);
        end
    end

    % Correct velocities
    for i = 2:n_points
        for j = 2:n_points-1
            u_new(i,j) = u_star(i,j) + alpha*d_e(i,j)*(pc(i,j+1) - pc(i,j));
        end
    end

    for i = 2:n_points-1
        for j = 2:n_points
            v_new(i,j) = v_star(i,j) + alpha*d_n(i,j)*(pc(i,j) - pc(i+1,j));
        end
    end

    % Apply boundary conditions
    u_new(1,:) = 2 - u_new(2,:);
    u_new(n_points+1,:) = -u_new(n_points,:);
    u_new(2:n_points,1) = 0;
    u_new(2:n_points,n_points) = 0;

    v_new(:,1) = -v_new(:,2);
    v_new(:,n_points+1) = -v_new(:,n_points);
    v_new(1,2:n_points) = 0;
    v_new(n_points,2:n_points) = 0;

    % Compute residual
    error = sum(sum(abs(b(2:n_points,2:n_points))));

    % Update for next iteration
    u = u_new;
    v = v_new;
    p = p_new;
    iterations = iterations + 1;
end

% Map staggered grid to collocated
for i = 1:n_points
    for j = 1:n_points
        u_final(i,j) = 0.5*(u(i,j) + u(i+1,j));
        v_final(i,j) = 0.5*(v(i,j) + v(i,j+1));
        p_final(i,j) = 0.25*(p(i,j) + p(i,j+1) + p(i+1,j) + p(i+1,j+1));
    end
end

% Plots and Visualizations
x_dom = ((1:n_points)-1).*h;
y_dom = 1 - ((1:n_points)-1).*h;
[X, Y] = meshgrid(x_dom, y_dom);

% Quiver plot
figure;
quiver(X, Y, u_final, v_final, 5, 'k')
xlabel('x'); ylabel('y');
title('Velocity Vectors (Quiver Plot)')

% Contour of u-velocity
figure;
contourf(X, Y, u_final, 21, 'LineStyle', 'none');
colorbar; colormap('jet')
xlabel('x'); ylabel('y');
title('Contour of u-velocity')

% Contour of v-velocity
figure;
contourf(X, Y, v_final, 21, 'LineStyle', 'none');
colorbar; colormap('jet')
xlabel('x'); ylabel('y');
title('Contour of v-velocity')

% Contour of pressure
figure;
contourf(X, Y, p_final, 21, 'LineStyle', 'none');
colorbar; colormap('jet')
xlabel('x'); ylabel('y');
title('Contour of Pressure')

% Streamline plot
figure;
streamslice(X, Y, u_final, v_final);
xlabel('x'); ylabel('y');
title('Streamline Plot')
