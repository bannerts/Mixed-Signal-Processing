function [varargout] = FCNS_simulate(varargin)
% This function performs all major functions required during the
% simulation.
global SIMULATION FUNCTION PARAMETER VARIABLE
global ODE FA
%% SIMULATION TYPE: ’NEW’ OR ’CONTINUED’
if strcmpi(varargin{1},’New or Continued’)
path(pathdef, pwd);
cd(SIMULATION.DIRECTORY);
STRING = ’NEW’;
if ~strcmpi(SIMULATION.CONTINUE, ’no’)
if isfield(VARIABLE, ’R2R’) && isfield(FUNCTION, ’SIZE’)
if isfield(VARIABLE.R2R, ’S’) && isfield(PARAMETER, ’N_S’)
if length(VARIABLE.R2R(1,1,:) == PARAMETER.n)
if length(VAR.D.S(:,1,1)== PARAMETER.N_S)
STRING = {’CONTINUED’};
end, end, end, end
end
varargout(1) = {STRING};
83
%% INITIALIZE SIMULATION
elseif strcmpi(varargin{1},’Initialize’)
if strcmpi(varargin{2}, ’CONTINUED’)
STATUS = ’Initialization process skipped’;
elseif strcmpi(varargin{2}, ’NEW’)
% CLEAR VARIABLES
FA.t = []; FA.T = [];
for i=1:FUNCTION.SIZE,
ODE(i).t = []; ODE(i).x = [];
end, clear i
% CREATE ODE FUNCTION
STATUS.ode = FCNS_ode(’Create M-Files’, ...
FUNCTION.X, FUNCTION.F, FUNCTION.DF, ...
FUNCTION.FILENAME.F, FUNCTION.FILENAME.DF);
FUNCTION.F_HANDLE = str2func(FUNCTION.FILENAME.F);
FUNCTION.DF_HANDLE = str2func(FUNCTION.FILENAME.DF);
% DECLARE PARAMETERS
cd(SIMULATION.PARAMETERS.DIRECTORY);
eval( SIMULATION.PARAMETERS.FILENAME );
STATUS.parameters = [’EXECUTED: ’’’ ...
SIMULATION.PARAMETERS.FILENAME ’’];
cd(SIMULATION.DIRECTORY);
84
% ODE VARIABLES
for i=1:PARAMETER.n
ODE(i).x = FUNCTION.X_0(i);
ODE(i).t = FUNCTION.t_0;
FCNS_floatingPoint(’FP_X’, i, FUNCTION.X_0(i));
end
VARIABLE.ODE.t = FUNCTION.t_0;
VARIABLE.DYNAMICS.T = 0;
% SCALING VARIABLES
VARIABLE.SCALING.tau = 0;
VARIABLE.SCALING.k = ones(PARAMETER.n, 1)*PARAMETER.k_0;
% RESET SIGNALS
VARIABLE.RESET.S_r = zeros( PARAMETER.n, 1);
VARIABLE.RESET.T_r = zeros( PARAMETER.n, 1);
% DYNAMIC VARIABLES: SET TO ZERO INITIALLY
% Analog Bit Voltage
VARIABLE.DYNAMICS.V_a = zeros( PARAMETER.n,1);
VARIABLE.DYNAMICS.DV_a = zeros( PARAMETER.n,1);
% Feedback Capacitor Charge
VARIABLE.DYNAMICS.Q_fb = zeros( PARAMETER.n,1);
VARIABLE.DYNAMICS.DQ_fb = zeros( PARAMETER.n,1);
% Reset Capacitor Charge
85
VARIABLE.DYNAMICS.Q_r = zeros( PARAMETER.n,1);
VARIABLE.DYNAMICS.DQ_r = zeros( PARAMETER.n,1);
% Virtual Ground
VARIABLE.DYNAMICS.V = zeros( PARAMETER.n,1);
% Function Approximation Current
VARIABLE.DYNAMICS.I = zeros( PARAMETER.n,1);
% Reset Current
VARIABLE.DYNAMICS.I_r = zeros( PARAMETER.n,1);
% DAC’s and R2R’s
% Function Approx Update time:
VARIABLE.FUNCTION_APPROXIMATION.T = 0;
% R2R and DAC SIZING (give zero values)
% R2R Mantissa Registers:
VARIABLE.R2R.S = zeros( PARAMETER.N_S, PARAMETER.n, ...
PARAMETER.n);
% R2R Sign Register:
VARIABLE.R2R.B = zeros( PARAMETER.n, PARAMETER.n);
% R2R Mantissa Value w/ sign
VARIABLE.R2R.value = zeros( PARAMETER.n, PARAMETER.n);
% DAC Mantissa Registers
VARIABLE.DAC.S = zeros( PARAMETER.N_S, PARAMETER.n);
% DAC Sign Resister
86
VARIABLE.DAC.B = zeros( PARAMETER.n, 1);
% DAC Mantissa value w/ sign
VARIABLE.DAC.value = zeros( PARAMETER.n, 1);
% SET DAC and R2R Value
FCNS_processing(’function approximation’, ’all’);
VARIABLE.FUNCTION_APPROXIMATION.T = ...
VARIABLE.DYNAMICS.T + PARAMETER.dT_fa;
STATUS.variables = [’All variables initialized’];
varargout(1) = {STATUS};
end
%% SIMULATE UNTIL EVENT
elseif strcmpi(varargin{1},’Simulate until Event’)
[T, Z] = FCNS_hardware(’Solver State’);
SIMULATION.ZDOT = @( T, Z) FCNS_hardware(’Zdot Function’, T, Z);
SIMULATION.EVENTS = @(T, Z) FCNS_hardware(’Event Function’, T, Z);
SIMULATION.OPTIONS = odeset(’events’, SIMULATION.EVENTS);
[T_out, Z_out, T_end, Z_end, N_end] = ...
ode15s( SIMULATION.ZDOT, [T, T+1], Z, SIMULATION.OPTIONS);
FCNS_hardware(’Update HxA’, T_end, Z_end);
[type, location] = FCNS_hardware(’Event Information’, N_end);
varargout(1) = {T_out};
87
varargout(2) = {Z_out};
varargout(3) = {type};
varargout(4) = {location};
%% PROCESS EVENTS
elseif strcmpi(varargin{1},’Process Event’)
type = varargin{2};
location = varargin{3};
if strcmpi(type,’pabr’)
I = location;
VARIABLE.RESET.S_r(I) = 1;
VARIABLE.RESET.T_r(I) = VARIABLE.DYNAMICS.T;
FCNS_processing(’Analog Bit Reset’, ’pabr’, I);
L_ODE = length(ODE(I).t);
ODE(I).x(L_ODE+1) = VARIABLE.ODE.X(I);
ODE(I).t(L_ODE+1) = VARIABLE.ODE.t;
% Negative Analog Bit Reset
elseif strcmpi(type,’nabr’)
I = location;
VARIABLE.RESET.S_r(I) = -1;
VARIABLE.RESET.T_r(I) = VARIABLE.DYNAMICS.T;
FCNS_processing(’Analog Bit Reset’, ’nabr’, I);
88
L_ODE = length(ODE(I).t);
ODE(I).x(L_ODE+1) = VARIABLE.ODE.X(I);
ODE(I).t(L_ODE+1) = VARIABLE.ODE.t;
% Function Approximation
elseif strcmpi(type,’function approximation’)
FCNS_processing(’function approximation’, ’all’);
VARIABLE.FUNCTION_APPROXIMATION.T = ...
VARIABLE.FUNCTION_APPROXIMATION.T + PARAMETER.dT_fa;
FA.t(length(FA.t)+1) = VARIABLE.ODE.t;
FA.T(length(FA.T)+1) = VARIABLE.DYNAMICS.T;
end
end
