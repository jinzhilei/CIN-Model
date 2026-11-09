%% ========================================================================
%  Function: initialzation
%
%  Description:
%      Construct the initial state matrix for delay differential equations,
%      assuming constant steady-state history over the delay window.
%
%  Input:
%      initial  - Vector containing steady-state values [Q0, M0, N0, phi]
%
%  Output:
%      y0       - State matrix (4 × y_tau), constant steady-state history
% =========================================================================
function y0=initialzation(initial)
    y_tau=5000;
    Q0 = initial(1);
    M0 = initial(2);
    N0 = initial(3);
    phi= initial(4);
    y_steady=[Q0,M0,N0,phi];
    y0 = zeros(4,y_tau);
    for i=1:y_tau
        y0(:,i)=y_steady;
    end
end
