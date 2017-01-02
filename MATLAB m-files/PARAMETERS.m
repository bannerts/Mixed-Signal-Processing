% This file has attempted to be recreated as the original m-file has been lost
% File is to be placed in \PARAMETERS directory

global VARIABLE PARAMETER SIMULATION

%% SIMULATION.DIRECTORY = % Directory of simulation files
%% SIMULATION.PARAMETERS.DIRECTORY = % Directory of PARAMETERS.m file (this file)
%% SIMULATION.PARAMETERS.FILENAME = % Filename of parameters m-file (this file)
%% SIMULATION.EVENTS
%% SIMULATION.OPTIONS

% PARAMETER
	% OP-AMP Integrator
		PARAMETER.A_0 = 1.5*10^5 % Op-amp Integrator DC Gain (103.5 dB)
		PARAMETER.w_1 = 2 * pi * 10^6 % Unity gain frequency in rad/sec
		PARAMETER.C_fb = 0.47 * 10^-6; Feeback capacitor (farads)
	
	% Reset Circuit
		PARAMETER.V_ref = 5.8 % Reference voltage
		PARAMETER.C_r =	0.47 * 10^-6 % Reset circuit capacitance (farads)
		PARAMETER.R_r =	25 % Reset circuit resistance (ohms)
		PARAMETER.dT_r = 8 * PARAMETER.R_r * PARAMETER.C_r % Reset circuit time (~11.75 microseconds, 8 time constants)
	
	% State Register : uses Single precision floating point format
		PARAMETER.E =	8 % Exponent register size of 8 bits	
		PARAMETER.M = 23 % Mantisa register size of 23 bits
		PARAMETER.k_0	= 19 % Initial scaling index value	(when set to a constant)
	
	% DAC & R2R
		PARAMETER.N_S = 13 % Size of R2R ladder in bits
		PARAMETER.R_R2R = 1000 % Resistance of R_R and R_2R resistor (ohms) in R2R ladder
		PARAMETER.C_iGAMMA_DAC = % R2R ladder matrix (see pg 27 of report pdf)
	
	% Simulation related parameters
		PARAMETER.dT_fa = 0.005 % time (seconds) between function approximation updates (0.005 sec default)
		PARAMETER.n = % # of integrators	(order of ODE being simulated)

	
%% VARIABLE ~ initialized in FCNS_simulate.m function
	% VARIABLE.DYNAMICS: State variable values
		%	VARIABLE.DYNAMICS.Q_fb ~ electrostatic charge on feedback capacitor (coloumbs)
		% VARIABLE.DYNAMICS.DQ.fb ~ current moving through feedback capacitor (amps)
		% VARIABLE.DYNAMICS.Q_r  ~ reset capacitor charge (coloumbs)
		% VARIABLE.DYNAMICS.DQ_r ~ reset capacitor current (amps)
		% VARIABLE.DYNAMICS.T : HxA HARDWARE TIME	(seconds)
		% VARIABLE.DYNAMICS.V_a ~ analog bit voltage
		% VARIABLE.DYNAMICS.DV_a ~ analog bit voltage time derivative 
		% VARIABLE.DYNAMICS.V ~ Virtual Ground voltage
		% VARIABLE.DYNAMICS.I ~ function approximator current vector
		% VARIABLE.DYNAMICS.I_r ~ Reset circuit current
	% VARIABLE.FUNCTION_APPROXIMATION.T ~ function approximation update time
	% VARIABLE.ODE	
		% VARIABLE.ODE.t ~ time in ODE state space
		% VARIABLE.ODE.X ~ state variable in ODE space
	% VARIABLE.RESET
		% VARIABLE.RESET.S_r ~ reset circuit signal (binary: 0 or 1)
		% VARIABLE.RESET.T_r ~ reset circuit signaling time (seconds)
	% VARIABLE.SCALING
		% VARIABLE.SCALING.tau ~ time scaling exponent (between ODE and hardware)
		% VARIABLE.SCALING.k
