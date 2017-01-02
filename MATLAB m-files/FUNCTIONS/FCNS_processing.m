function [varargout] = FCNS_processing(varargin)

global FUNCTION VARIABLE PARAMETER

%% ANALOG BIT RESET UPDATE
if strcmpi(varargin{1}, ’Analog Bit Reset’)
	type = varargin{2}; % ’pabr’ or ’nabr’
	location = varargin{3};
	Analog_Bit_Reset(type, location);

%% FUNCTION APPROXIMATION
elseif strcmpi(varargin{1}, ’Function Approximation’)
	% UPDATE ALL REGISTERS
	if strcmpi(varargin{2}, ’all’)
		FUNCTION_APPROXIMATION(’all’, 0, 0);
	% UPDATING A DAC REGISTER
	elseif varargin{3} == 0
		FUNCTION_APPROXIMATION(’DAC’, varargin{2}, 0);
	% UPDATING AN R2R REGISTER
	else
		FUNCTION_APPROXIMATION(’R2R’, varargin{2}, varargin{3});
	end

%% SCALING INDEX CONTROL
elseif strcmpi(varargin{1}, ’Scaling Control’)
	% Determine for this Variable number
		i = varargin{2};
end


%% ANALOG BIT RESETS -----------------------------------------------------
function [] = Analog_Bit_Reset(type, location)
global VARIABLE PARAMETER
% Determine Type
	if strcmpi(type, ’pabr’)
		reset_sign = 1;
	elseif strcmpi(type, ’nabr’)
		reset_sign = -1;
	end
% UPDATE DACS
	for i=1:PARAMETER.n
		VARIABLE.DAC.value(i) = VARIABLE.DAC.value(i) + ...
			reset_sign*VARIABLE.R2R.value(i,location);
		while(VARIABLE.DAC.value(i) > ( 1 - 2^(-PARAMETER.N_S) ))
			Change_tau( -1 );
		end
		[VARIABLE.DAC.B(i), VARIABLE.DAC.S(:,i)] ...
				= Num_to_Mant(VARIABLE.DAC.value(i));
	end
% UPDATE STATE REGISTER
	e_old = VARIABLE.ODE.e(location);
	X_new = VARIABLE.ODE.X(location) + reset_sign * ...
		2^( VARIABLE.SCALING.k(location) - PARAMETER.M ...
			+ e_old );
	FCNS_floatingPoint(’FP_X’, location, X_new)
	e_new = VARIABLE.ODE.e(location);
	if( e_new ~= e_old) % exponent change
		Change_exp( e_new - e_old , location);
	end
	Find_Max_tau;
return

%% FUNCTION APPROXIMATION ------------------------------------------------
function [] = FUNCTION_APPROXIMATION(TYPE, I, J)
global FUNCTION VARIABLE PARAMETER
% EVALUATE ODE FUNCTION
	F_val = FUNCTION.F_HANDLE( VARIABLE.ODE.X );
	DF_val = FUNCTION.DF_HANDLE( VARIABLE.ODE.X );
% UPDATE EACH DAC/R2R
	for i=1:PARAMETER.n
	% APPROXIMATE DAC VALUES
		if strcmpi(TYPE, ’all’) || ( I==i && J==0)
			VARIABLE.DAC.value(i) = ...
				-PARAMETER.R_R2R * PARAMETER.C_fb * ...
				F_val(i) * 2^( PARAMETER.M + VARIABLE.SCALING.tau - ...
				VARIABLE.ODE.e(i) - VARIABLE.SCALING.k(i) );
			while( abs(VARIABLE.DAC.value(i)) > 1-2^(-PARAMETER.N_S-1) )
				Change_tau( -1 )
			end
			[VARIABLE.DAC.B(i), VARIABLE.DAC.S(:,i)] = ...
				Num_to_Mant(VARIABLE.DAC.value(i));
	end
	% APPROXIMATE R2R VALUES
	for j = 1:PARAMETER.n
		if strcmpi(TYPE, ’all’) || ( I==i && J==j )
			VARIABLE.R2R.value(i,j) = ...
				-PARAMETER.R_R2R * PARAMETER.C_fb * ...
				DF_val(i,j) * 2^( VARIABLE.SCALING.tau - ...
				VARIABLE.ODE.e(i) - VARIABLE.SCALING.k(i) + ...
				VARIABLE.ODE.e(j) + VARIABLE.SCALING.k(j) );
			while( abs(VARIABLE.R2R.value(i,j)) > 1-2^(-PARAMETER.N_S-1) )
				Change_tau( -1 )
			end
			[VARIABLE.R2R.B(i,j), VARIABLE.R2R.S(:,i,j)] = ...
				Num_to_Mant(VARIABLE.R2R.value(i,j));
		end
	end
	end
	Find_Max_tau;
return;

%% MODIFY TIME SCALE (TAU) FACTOR -------------------------------------
function []= Change_tau( delta )
global PARAMETER VARIABLE
	VARIABLE.SCALING.tau = VARIABLE.SCALING.tau + delta;
	for i=1:PARAMETER.n
		VARIABLE.DAC.value(i) = VARIABLE.DAC.value(i)*2^(delta);
		[VARIABLE.DAC.B(i), VARIABLE.DAC.S(:,i)] = ...
			Num_to_Mant(VARIABLE.DAC.value(i));
		for j=1:PARAMETER.n
			VARIABLE.R2R.value(i,j) = VARIABLE.R2R.value(i,j)*2^(delta);
			[VARIABLE.R2R.B(i,j), VARIABLE.R2R.S(:,i,j)] = ...
				Num_to_Mant(VARIABLE.R2R.value(i,j));
		end
	end
return;

%% MODIFICATIONS FROM EXPONENT CHANGES --------------------------------
function [] = Change_exp(delta, N)
global PARAMETER VARIABLE
	VARIABLE.DAC.value(N) = VARIABLE.DAC.value(N)*2^(-delta);
	while( abs(VARIABLE.DAC.value(N)) > 1-2^(-PARAMETER.N_S-1) )
		Change_tau( -1 )
	end
	[VARIABLE.DAC.B(N), VARIABLE.DAC.S(:,N)] = ...
		Num_to_Mant(VARIABLE.DAC.value(N));
		for j=1:PARAMETER.n
			VARIABLE.R2R.value(N,j) = VARIABLE.R2R.value(N,j)*2^(-delta);
			while( abs(VARIABLE.R2R.value(N,j)) > 1-2^(-PARAMETER.N_S-1) )
				Change_tau( -1 )
			end
			[VARIABLE.R2R.B(N,j), VARIABLE.R2R.S(:,N,j)] = ...
				Num_to_Mant(VARIABLE.R2R.value(N,j));
			VARIABLE.R2R.value(j,N) = VARIABLE.R2R.value(j,N)*2^(delta);
			while( abs(VARIABLE.R2R.value(j,N)) > 1-2^(-PARAMETER.N_S-1) )
				Change_tau( -1 )
			end
			[VARIABLE.R2R.B(j,N), VARIABLE.R2R.S(:,j,N)] = ...
				Num_to_Mant(VARIABLE.R2R.value(j,N));
		end
return

%% SET TO MAXIMUM TIME SCALE FACTOR -------------------------------------
function []= Find_Max_tau()
global PARAMETER VARIABLE
	val_DAC = max(abs(VARIABLE.DAC.value));
	val_R2R = max(max(abs(VARIABLE.R2R.value)));
	while( max(val_DAC, val_R2R) < ( 0.5 - 2^(-PARAMETER.N_S)) )
		Change_tau(+1);
		val_DAC = max(abs(VARIABLE.DAC.value));
		val_R2R = max(max(abs(VARIABLE.R2R.value)));
	end
return;

%% CONVERT NUMBER INTO A MANTISSA (DAC/R2R) -----------------------------
function [B, S] = Num_to_Mant(value)
global PARAMETER
	B = sign(value) == -1;
	value = abs(value);
	for i=1:PARAMETER.N_S
		if value >= 2^(-i)-2^(-PARAMETER.N_S-1);
			value = value-2^(-i);
			S(i,1) = (1==1);
		else
			S(i,1) = (1==0);
		end
	end
return

%% CONVERTS MANTISSA INTO NUMBER (DAC/R2R) -------------------------------
function [value] = Mant_to_Num(B, S)
	global PARAMETER
		value = 0;
	for i=1:PARAMETER.N_S
		value = value + S(i)*2^(-i);
	end
		value = value*((-1)^D_B);
return
