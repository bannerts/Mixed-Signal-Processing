%% CREATE_SIMULATION.m
%
% This function is used to simulate the HxA. To perform a new
% simulation, an "ODE file", a "PARAMETERS file", and initial conditions
% must be specified. To Continue a previous simulation, the information
% from previous simulation must be present in Matlabs Workspace.
global SIMULATION FUNCTION VARIABLE PARAMETER
global DATA ODE FA

%% GENERAL INFORMATION:
	% CONTINUE SIMULATIONS IF POSSIBLE:
	% - specify ’no’ to option out
		SIMULATION.CONTINUE = ’no’;
	% OUTPUT DIRECTORY
		SIMULATION.DIRECTORY = [pwd, ’\RESULTS’];

%% ODE FUNCTION:
	% Order of ODE
		FUNCTION.SIZE = 2;
	% State Variable Vector: X = [X(1); X(2); ...; X(N)]
		FUNCTION.X = FCNS_ode(’Create X’, FUNCTION.SIZE);
	% ODE function
		X = FUNCTION.X;
		FUNCTION.F = [ -X(2); -X(1); ]; clear X
		FUNCTION.FILENAME.F = ’fcn_F’;
	% Partial derivatives of ODE function
		FUNCTION.DF = ...
			FCNS_ode(’Create DF’, FUNCTION.X, FUNCTION.F);
		FUNCTION.FILENAME.DF = ’fcn_DF’;
	% Initial Conditions: ["X0_1"; "X0_2"; ..]
		FUNCTION.X_0 = [5; 5];
		FUNCTION.t_0 = 0;

%% PARAMETERS USED IN SIMULATION:
	% DIRECTORY:
		SIMULATION.PARAMETERS.DIRECTORY = [pwd, ’\PARAMETERS’];
	% FILE: [’FILE_NAME’]
		SIMULATION.PARAMETERS.FILENAME = ’PARAMETERS’;
	% FILE MODIFICATION CODE:
		% SYSTEM SIZE
			i=1; SIMULATION.OVERWRITE(i).String = ...
			[’PARAMETER.n = ’ int2str(FUNCTION.SIZE) ’;’];
		% State Register: Exponent/Mantissa Size
			i=i+1; SIMULATION.OVERWRITE(i).String = ...
			[’PARAMETER.E = 8;’];
			i=i+1; SIMULATION.OVERWRITE(i).String = ...
			[’PARAMETER.M = 23;’];
		% Scaling Index: Initial Value
			i=i+1; SIMULATION.OVERWRITE(i).String = ...
			[’PARAMETER.k_0 = 19;’];
		% DAC/R2R: Bits in Mantissa Register
			i=i+1; SIMULATION.OVERWRITE(i).String = ...
			[’PARAMETER.N_S = 13;’];
		% Function Approximation
			% Time between function approximation updates
				i=i+1; SIMULATION.OVERWRITE(i).String = ...
				[’PARAMETER.dT_fa = 0.005;’];
				clear i

%% INITIALIZE SIMULATION
	clear global PARAMETER VARIABLE
	global PARAMETER VARIABLE
	path(pathdef);
	% SIMULATION TYPE: ’NEW’ or ’CONTINUED’
		OUTPUT.Simulation = FCNS_simulate(’New or Continued’);
	% INITIALIZATION
		OUTPUT.Initialization = FCNS_simulate(’Initialize’,...
		OUTPUT.Simulation);

%% PROCESS SIMULATION
	DATA.T = []; DATA.Z = [];
	for i=1:50
		[T_out, Z_out, type, location] = ...
			FCNS_simulate(’Simulate until Event’);
		FCNS_simulate(’Process Event’, type, location);
		DATA.T = [ DATA.T; T_out];
		DATA.Z = [ DATA.Z; Z_out];
		clear T_out Z_out type location
	end, clear i

%% DISPLAY RESULTS
	DISPLAY_RESULTS
	cd ..
