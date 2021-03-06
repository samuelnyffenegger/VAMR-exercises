clear all; close all; clc       

addpath('8point/');
addpath('triangulation/');
addpath('plot/');
addpath('utilities/');

rng(42);

N = 40;         % Number of 3-D points
X = randn(4,N);  % Homogeneous coordinates of 3-D points

% Simulated scene with error-free correspondences
X(3, :) = X(3, :) * 5 + 10;
X(4, :) = 1;

P1 =   [500 0 320 0
        0 500 240 0
        0 0 1 0];

P2 =   [500 0 320 -100
        0 500 240 0
        0 0 1 0];
				
x1 = P1 * X;     % Image (i.e., projected) points
x2 = P2 * X;

sigma = 1e-1;
noisy_x1 = x1 + sigma * randn(size(x1));
noisy_x2 = x2 + sigma * randn(size(x1));


%% Essential matrix estimation via the 8-point algorithm
clc

% Estimate essential matrix
% Call the 8-point algorithm on inputs x1,x2
E = estimateEssentialMatrix(x1, x2, P1(1:3,1:3), P2(1:3,1:3));

% Check the epipolar constraint x2(i).' * F * x1(i) = 0 for all points i.
cost_algebraic = norm( sum(x2.*(E*x1)) ) / sqrt(N);
cost_dist_epi_line = distPoint2EpipolarLine(E,x1,x2);

fprintf('Noise-free correspondences\n');
fprintf('Algebraic error: %f\n', cost_algebraic);
fprintf('Geometric error: %f px\n\n', cost_dist_epi_line);

% print binary success status
tol = 1e-8;
fprintf('SN:Info: ')
if norm(E)~=0 && cost_algebraic < tol && cost_dist_epi_line < tol
    cprintf([0,0.5,0],'Noise-free essential matrix calculation was successful\n')
else
    cprintf([0.9,0,0],'Noise-free essential matrix calculation calculation failed\n')
end

%% Fundamental matrix estimation via the 8-point algorithm
clc

% Estimate fundamental matrix
% Call the 8-point algorithm on inputs x1,x2
F = fundamentalEightPoint(x1,x2);

% Check the epipolar constraint x2(i).' * F * x1(i) = 0 for all points i.
cost_algebraic = norm( sum(x2.*(F*x1)) ) / sqrt(N);
cost_dist_epi_line = distPoint2EpipolarLine(F,x1,x2);

fprintf('Noise-free correspondences\n');
fprintf('Algebraic error: %f\n', cost_algebraic);
fprintf('Geometric error: %f px\n\n', cost_dist_epi_line);

% print binary success status
tol = 1e-9;
fprintf('SN:Info: ')
if norm(F)~=0 && cost_algebraic < tol && cost_dist_epi_line < tol
    cprintf([0,0.5,0],'Noise-free fundamental matrix calculation was successful\n')
else
    cprintf([0.9,0,0],'Noise-free fundamental matrix calculation calculation failed\n')
end

%% Test with noise:
clc

% Estimate fundamental matrix
% Call the 8-point algorithm on noisy inputs x1,x2
F = fundamentalEightPoint(noisy_x1,noisy_x2);

% Check the epipolar constraint x2(i).' * F * x1(i) = 0 for all points i.
cost_algebraic = norm( sum(noisy_x2.*(F*noisy_x1)) ) / sqrt(N);
cost_dist_epi_line = distPoint2EpipolarLine(F,noisy_x1,noisy_x2);

fprintf('Noisy correspondences (sigma=%f), with fundamentalEightPoint\n', sigma);
fprintf('Algebraic error: %f\n', cost_algebraic);
fprintf('Geometric error: %f px\n\n', cost_dist_epi_line);

% print binary success status
tol = 1e-10;
fprintf('SN:Info: ')
if norm(F)~=0 && cost_algebraic < tol && cost_dist_epi_line < tol
    cprintf([0,0.5,0],'Noisy fundamental matrix calculation was successful\n')
else
    cprintf([0.9,0,0],'Noisy fundamental matrix calculation calculation failed\n')
end

%% Normalized 8-point algorithm
clc

% Call the normalized 8-point algorithm on inputs x1,x2
Fn = fundamentalEightPoint_normalized(noisy_x1,noisy_x2);

% Check the epipolar constraint x2(i).' * F * x1(i) = 0 for all points i.
cost_algebraic = norm( sum(noisy_x2.*(Fn*noisy_x1)) ) / sqrt(N);
cost_dist_epi_line = distPoint2EpipolarLine(Fn,noisy_x1,noisy_x2);


fprintf('Noisy correspondences (sigma=%f), with fundamentalEightPoint_normalized\n', sigma);
fprintf('Algebraic error: %f\n', cost_algebraic);
fprintf('Geometric error: %f px\n\n', cost_dist_epi_line);

% print binary success status
fprintf('SN:Info: ')
if norm(F)~=0 && cost_algebraic < 0.01 && cost_dist_epi_line < 100
    cprintf([0,0.5,0],'Normalized 8-point algorithm for fundamental matrix calculation was successful\n')
else
    cprintf([0.9,0,0],'Normalized 8-point algorithm for fundamental matrix calculation calculation failed\n')
end
