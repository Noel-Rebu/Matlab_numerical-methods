%Matlab/Octave code for steady-state heat conduction
clc
clearvars;

%Geometry information
N=10; %number of nodes
L=10/100; %Lenght of rod in meters(10cm)
dx=L/(N-1); %grid size

%Initial and boundary condition
T=zeros(N,1);
Tbase=200;
Ttip=20;

%Solution
k=100; %number of iterations

for j=1:1:k
    T(1,1)=Tbase;

    for(i=2:1:N-1)
        T(i,1)=(T(i+1)+T(i-1))/2;
    end
    T(N,1)=Ttip;
plot(T);
hold on;
end