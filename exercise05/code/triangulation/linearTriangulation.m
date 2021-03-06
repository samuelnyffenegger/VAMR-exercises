function P = linearTriangulation(p1,p2,M1,M2)
% LINEARTRIANGULATION  Linear Triangulation
%
% Input:
%  - p1(3,N): homogeneous coordinates of points in image 1
%  - p2(3,N): homogeneous coordinates of points in image 2
%  - M1(3,4): projection matrix corresponding to first image
%  - M2(3,4): projection matrix corresponding to second image
%
% Output:
%  - P(4,N): homogeneous coordinates of 3-D points

%% calculations

% init
N = size(p1,2);
P = zeros(4,N);

for i = 1:N
    Q = [skew(p1(:,i))*M1; ...
         skew(p2(:,i))*M2];
    [~,~,V] = svd(Q);
    Pi = V(:,end); 
    Pi = Pi / Pi(end);
    P(:,i) = Pi;
end


end

