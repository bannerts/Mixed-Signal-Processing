function [] = FCNS_floatingPoint(varargin)
% FCNS_floatingPoint(’FP_X’, i, X)
% FCNS_floatingPoint(’FP_Z’, i, B, M, E)
% FCNS_floatingPoint(’FP_N’, i, b, m, e)
	global PARAMETER VARIABLE % Contains most Parameters

%% Floating Point Update w/ "X"
	if strcmpi(varargin{1},’FP_X’)
		i = varargin{2};
		[N_b, N_m, N_e, Z_B, Z_M, Z_E] = ...
			Num_2_FP( varargin{3} );
				VARIABLE.ODE.X(i,1) = varargin{3};
				VARIABLE.ODE.b(i,1) = N_b;
				VARIABLE.ODE.m(i,1) = N_m;
				VARIABLE.ODE.e(i,1) = N_e;
				VARIABLE.ODE.B(i,1) = Z_B;
				VARIABLE.ODE.M(:,i) = Z_M;
				VARIABLE.ODE.E(:,i) = Z_E;

%% Floating Point Update w/ "(B,M,E)"
	elseif strcmpi(varargin{1},’FP_Z’)
		i = varargin{2};
		B = varargin{3}; M = varargin{4}; E = varargin{5};
		[b, m, e, X] = Dig_to_Num(B, M, E)
			VARIABLE.ODE.B(i,1) = B;
			VARIABLE.ODE.M(:,i) = M;
			VARIABLE.ODE.E(:,i) = E;
			VARIABLE.ODE.X(i) = X;
			VARIABLE.ODE.b(i,1) = b;
			VARIABLE.ODE.m(i,1) = m;
			VARIABLE.ODE.e(i,1) = e;

%% Floating Point Update w/ "(b,m,e)"
	elseif strcmpi(varargin{1},’FP_N’)
		i = varargin{2};
		b = varargin{3}; m = varargin{4}; e = varargin{5};
		X = b*m*2^e;
		[N_b, N_m, N_e, Z_B, Z_M, Z_E] = ...
			Num_2_FP( X );
			VARIABLE.ODE.X(i) = X;
			VARIABLE.ODE.b(i,1) = b;
			VARIABLE.ODE.m(i,1) = m;
			VARIABLE.ODE.e(i,1) = e;
			VARIABLE.ODE.B(i,1) = Z_B;
			VARIABLE.ODE.M(:,i) = Z_M;
			VARIABLE.ODE.E(:,i) = Z_E;
	end
	
%% FUNCTION
function [ b, m, e, Z_B, Z_M, Z_E ] = Num_2_FP( X )
	global PARAMETER % NOTE: BIT 1 is the LSB
b = sign(X); Z_B = (b == -1); X = abs(X);
if( X > (2-2^(-PARAMETER.M))*2^(2^(PARAMETER.E-1)-1) )% Inf/NaN:
	Z_E = ones(PARAMETER.E,1)==ones(PARAMETER.E,1);
	e = NaN; m = NaN;
	Z_M = ones(PARAMETER.M,1)==zeros(PARAMETER.M,1);
elseif( X < 2^(-2^(PARAMETER.E-1)-PARAMETER.M+2))% ZERO
	Z_E = ones(PARAMETER.E,1)==zeros(PARAMETER.E,1);
	e = -2^(PARAMETER.E-1) + 2;
	Z_M = ones(PARAMETER.M,1)==zeros(PARAMETER.M,1);
	m=0;
elseif( X < 2^(-2^(PARAMETER.E-1) + 2))% DENORMALIZED
	Z_E = ones(PARAMETER.E,1)==zeros(PARAMETER.E,1);
	e = -2^(PARAMETER.E-1) + 2;
	m = X*2^(e); X = m;
	for i=PARAMETER.M:-1:1
		if( X >= 2^(-PARAMETER.M+i-1) )
			Z_M(i,1) = (1==1);
			X = X - 2^(-PARAMETER.M+i-1);
		else
			Z_M(i,1) = (1==0);
	end, end
else 	% Standard form
	e = floor(log2(X));
	e_temp = e +2^(PARAMETER.E-1)-1;
	m = X*2^(-e);
	m_temp = m-1;
	for i = PARAMETER.E:-1:1
		if( e_temp >= 2^(i-1))
			Z_E(i,1)=(1==1);
			e_temp = e_temp - 2^(i-1);
		else, Z_E(i,1)=(1==0);
	end, end
	for i = PARAMETER.M:-1:1
		if( m_temp >= 2^(i-PARAMETER.M-1) )
			Z_M(i,1)=(1==1);
			m_temp = m_temp - 2^(i-PARAMETER.M-1);
		else, Z_M(i,1)=(1==0);
end, end, end,
return;

%% FUNCTION
function [b, m, e, X] = Dig_to_Num(Z_B, Z_M, Z_E)
	global PARAMETER % NOTE: BIT 1 is the LSB
	b = ( -1 )^ Z_B;
	if( max(Z_E)==0 )% DENORMALIZED
		m = sum(Z_M’.*2.^[-PARAMETER.M:-1]);
		e = -2^(PARAMETER.E-1)+2;
		X = b*m*2^e;
	elseif( min(Z_E)==1 ) && ( min(Z_M)==1 )% INFINITY
		m = inf; e = inf; X = inf;
	elseif( min(Z_E)==1 )% NaN
		m = NaN; e = NaN; X = NaN;
	else% NORMALIZED
		m = 1+sum(Z_M’.*2.^[-PARAMETER.M:-1]);
		e = -2^(PARAMETER.E-1) + 1 + sum(Z_E’.*2.^[0:PARAMETER.E-1]);
		X = b*m*2^e;
	end
return;
