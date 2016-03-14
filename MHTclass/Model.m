classdef Model
    properties (Constant)
        % Used for updating posterior
        % T = 1;
        A = [1 1 0 0;
             0 1 0 0;
             0 0 1 1;
             0 0 0 1]; % Transition Matrix
        
        H = [1 0 0 0;
             0 0 1 0]; % Measurement Matrix
        
        Q = 0.05.*[0 0 0 0;
                   0 1 0 0;
                   0 0 0 0;
                   0 0 0 1]; % Covariance for Transition
        Qm = 0.05;
        
        R = 0.025.*[1 0;
                   0 1]; % Covariance for Measurement
        Rm = 0.025;
        % Used for track initiation
        vmax = 4;  % Maximal (assumed) velocity
        kappa = 30; % scaling factor
        
        % Contains detection probability and clutter specification
        rho = 0.0001; % False Measurement Density
        V = 1;     % Volume/Area of Measurement Space
        Pd = 1;    % Detection Probability
        
        spwn = 0.0001; % New target spawning density
    end
end