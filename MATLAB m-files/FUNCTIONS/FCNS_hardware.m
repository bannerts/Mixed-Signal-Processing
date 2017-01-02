function [varargout] = FCNS_hardware(varargin)
% [DZ] = FCNS_hardware(’Zdot Function’, T, Z)
% [] = FCNS_hardware(’Update HxA’, T, Z)
% [T, Z] = FCNS_hardware(’Solver State’)
% [value, isterminal, direction] = FCNS_hardware(’Event Function’, T, Z)
% [type, location] = FCNS_hardware(’Event Information’, N)
global VARIABLE PARAMETER

%% ZDOT FUNCTION
	if strcmpi(varargin{1},’Zdot function’)
		% INPUT
			T = varargin{2};
			Z = varargin{3};
		% CALCULATIONS
			Z_to_HxA(T, Z, ’save’);
			Evaluate_HxA();
			DZ = HxA_to_Zdot();
		% OUPTUT
			varargout(1) = {DZ};
%% UPDATE HxA DYNAMICS
	elseif strcmpi(varargin{1}, ’Update HxA’)
		% INPUT
			T = varargin{2};
			Z = varargin{3};
		% CALCULATIONS
			Z_to_HxA( T, Z, ’save’);
			Evaluate_HxA();
%% GET SOLVER STATE
	elseif strcmpi(varargin{1}, ’solver state’)
		[T, Z] = HxA_to_Z();
		% OUPTUT
			varargout(1) = {T};
			varargout(2) = {Z};
%% EVENT FUNCTION
	elseif strcmpi(varargin{1}, ’event function’)
		% INPUT
			T = varargin{2};
			Z = varargin{3};
		% CALCULATIONS
			[value, isterminal, direction] = EVENT_values(T,Z);
		% OUPTUT
			varargout(1) = {value};
			varargout(2) = {isterminal};
			varargout(3) = {direction};
%% GET EVENT INFORMATION
	elseif strcmpi(varargin{1},’event information’)
		% INPUT
			N = varargin{2};
		% CALCULATIONS
			[type, location] = EVENT_Information(N);
		% OUPTUT
			varargout(1) = {type};
			varargout(2) = {location};
	end
	
	
%% SUBFUNCTION: HxA_to_Z
function [T, Z] = HxA_to_Z()
% This function determines Z (Matlab’s solver) variables from HxA (system
% description) variables.
global VARIABLE PARAMETER
	Z([1:PARAMETER.n],1) = VARIABLE.DYNAMICS.V_a(:,1);
	Z([PARAMETER.n+1:2*PARAMETER.n],1) = VARIABLE.DYNAMICS.Q_fb(:,1);
	Z([2*PARAMETER.n+1:3*PARAMETER.n],1)= VARIABLE.DYNAMICS.Q_r(:,1);
	Z(3*PARAMETER.n+1,1) = VARIABLE.ODE.t; % ODE TIME
	T = VARIABLE.DYNAMICS.T; % HxA HARDWARE TIME
return

%% SUBFUNCTION: Z_to_HxA
function [varargout] = Z_to_HxA( T, Z, SAVE)
% This function transforms Z (Matlab solver) variables into HxA (system
% description) variables.
global VARIABLE PARAMETER
	if strcmpi(SAVE, ’save’)
		VARIABLE.DYNAMICS.V_a(:,1) = Z(1:PARAMETER.n);
		VARIABLE.DYNAMICS.Q_fb(:,1) = Z(PARAMETER.n+1:2*PARAMETER.n);
		VARIABLE.DYNAMICS.Q_r(:,1) = Z(2*PARAMETER.n+1:3*PARAMETER.n);
		VARIABLE.DYNAMICS.T = T; % "REAL TIME"
		VARIABLE.ODE.t = Z(1+3*PARAMETER.n); % ODE TIME
	elseif strcmpi(SAVE, ’no save’)
		V_a(:,1) = Z(1:PARAMETER.n);
		Q_fb(:,1) = Z(PARAMETER.n+1:2*PARAMETER.n);
		Q_r(:,1) = Z(2*PARAMETER.n+1:3*PARAMETER.n);
		t = Z(1+3*PARAMETER.n); % ODE TIME
		varargout(1) = {T};
		varargout(2) = {t};
		varargout(3) = {V_a};
		varargout(4) = {Q_fb};
		varargout(5) = {Q_r};
	else
		disp(’ERROR: Input in FCNS_hardware/Z_to_HxA()’); beep;
	end
return

%% SUBFUNCTION: HxA_to_Zdot
function DZ = HxA_to_Zdot()
% This function determines Zdot (Matlab’s solver) variables from HxA
% (system description) variables.
global VARIABLE PARAMETER
	DZ([1:PARAMETER.n],1) = VARIABLE.DYNAMICS.DV_a;
	DZ([PARAMETER.n+1:2*PARAMETER.n],1) = VARIABLE.DYNAMICS.DQ_fb;
	DZ([2*PARAMETER.n+1:3*PARAMETER.n],1)= VARIABLE.DYNAMICS.DQ_r;
	DZ(3*PARAMETER.n+1,1) = 2^(VARIABLE.SCALING.tau);
return

%% SUBFUNCTION: EVENT_values
function [value, isterminal, direction] = EVENT_values(T,Z)
% This function gets event information for matlabs solver
global VARIABLE PARAMETER
	[T, t, V_a, Q_fb, Q_r] = Z_to_HxA( T, Z, ’no save’);
	% Positive Analog Bit Resets
		value_PABR(:,1) = V_a - PARAMETER.V_ref;
	% Negative Analog Bit Resets
		value_NABR(:,1) = - V_a - PARAMETER.V_ref;
	% Function Reapproximation
		value_FA(:,1) = T - VARIABLE.FUNCTION_APPROXIMATION.T;
		value = [ value_PABR; value_NABR; value_FA ];
		isterminal = ones(2*PARAMETER.n+1,1);
		direction = ones(2*PARAMETER.n+1,1);
return

%% SUBFUNCTION: EVENT_information
function [type, location] = EVENT_Information(N)
% This function specifies what type of event has occured based on its
% event number.
global PARAMETER
	% Not an Event
		if length(N)==0
			type = ’no event’;
			location = 0;
	% Multiple events stated
		elseif length(N)>1
			type = ’redundant listing’;
			location = 0;
	% Positive Analog Bit Resets
		elseif N <= PARAMETER.n
			type = ’PABR’;
			location = N;
	% Negative Analog Bit Resets
		elseif N <= 2*PARAMETER.n % Negative Reset
			type = ’NABR’;
			location = N-PARAMETER.n;
	% Function Reapproximation
		elseif N == 2*PARAMETER.n + 1 % F.A. Needs Updating
			type = ’function approximation’;
			location = 0;
	% Unknown?
		else
			type = ’WTF?’;
			location = 0;
	end
return

%% SUBFUNCTION: Evaluate_HxA
function [] = Evaluate_HxA()
% This function calculates information describing HxA based on input
% values.
global PARAMETER VARIABLE
	% Solve for the Virtual Ground
		VARIABLE.DYNAMICS.V = VARIABLE.DYNAMICS.V_a + ...
			VARIABLE.DYNAMICS.Q_fb./PARAMETER.C_fb;
	% Solve for Current: Reset Circuit: DQ_r, I_r
	for i=1:PARAMETER.n
		if( VARIABLE.RESET.S_r(i) == 0 )
			VARIABLE.DYNAMICS.DQ_r(i,1) = -VARIABLE.DYNAMICS.Q_r(i) ...
				/PARAMETER.R_r/PARAMETER.C_r + PARAMETER.V_ref ...
				/PARAMETER.R_r;
			VARIABLE.DYNAMICS.I_r(i,1) = 0;
		elseif( VARIABLE.RESET.S_r(i) == -1)
			VARIABLE.DYNAMICS.DQ_r(i,1) = -VARIABLE.DYNAMICS.Q_r(i) ...
				/PARAMETER.R_r/PARAMETER.C_r + ...
				VARIABLE.DYNAMICS.V(i)/PARAMETER.R_r;
			VARIABLE.DYNAMICS.I_r(i,1) = VARIABLE.DYNAMICS.DQ_r(i,1);
			if( VARIABLE.DYNAMICS.T > VARIABLE.RESET.T_r(i) + ...
					PARAMETER.dT_r )
				VARIABLE.RESET.S_r(i) = 0;
			end
		elseif( VARIABLE.RESET.S_r(i,1) == 1 )
			VARIABLE.DYNAMICS.DQ_r(i,1) = -VARIABLE.DYNAMICS.Q_r(i) ...
				/PARAMETER.R_r/PARAMETER.C_r - ...
				VARIABLE.DYNAMICS.V(i)/PARAMETER.R_r;
			VARIABLE.DYNAMICS.I_r(i,1) = -VARIABLE.DYNAMICS.DQ_r(i,1);
			if( VARIABLE.DYNAMICS.T > VARIABLE.RESET.T_r(i) ...
					+ PARAMETER.dT_r )
				VARIABLE.RESET.S_r(i,1) = 0;
			end
		else, disp(’A Signal Sent to Reset Capacitor is not valid’);
		end
	end
% Solve for Current: DAC/R2R: I
	for i=1:PARAMETER.n
		I=0;
		I = (PARAMETER.C_iGAMMA_DAC(:,:,i)*(PARAMETER.V_ref* ...
			((-1)^VARIABLE.DAC.B(i))-[VARIABLE.DAC.S(:,i);0] ...
			*VARIABLE.DYNAMICS.V(i)))’*[VARIABLE.DAC.S(:,i);0];
		for j=1:PARAMETER.n
			I = I+(PARAMETER.C_iGAMMA(:,:,i,j)* ...
				(VARIABLE.DYNAMICS.V_a(j)*((-1)^VARIABLE.R2R.B(i,j)) ...
				-[VARIABLE.R2R.S(:,i,j);0]*VARIABLE.DYNAMICS.V(i)))’ ...
				*[VARIABLE.R2R.S(:,i,j);0];
		end
		VARIABLE.DYNAMICS.I(i,1) = I;
	end,
% Determine remaining dynamic variables
	% Analog Bit Voltage
		VARIABLE.DYNAMICS.DV_a= -PARAMETER.w_1.* ...
			VARIABLE.DYNAMICS.V_a./PARAMETER.A_0 - ...
			PARAMETER.w_1.*VARIABLE.DYNAMICS.V;
	% Feedback Capacitor Charge
		VARIABLE.DYNAMICS.DQ_fb = VARIABLE.DYNAMICS.I + ...
			VARIABLE.DYNAMICS.I_r;
return
