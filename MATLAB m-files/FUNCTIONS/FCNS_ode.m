function [varargout] = FCNS_ode(varargin)
%%
% This function creates the ode files used by the simulation program.
%
% INPUT FORMS
% [X] = FCNS_ode(’Create X’, Length_of_X )
% [DF] = FCNS_ode(’Create DF’, X, F)
% [] = FCNS_ode(’Create M-Files’, X, F, DF, ...
% F_FileName, DF_File_Name)

%% CODE
if strcmpi(varargin{1}, ’Create X’)
		Length_of_X = varargin{2};
	X = STATE_VECTOR( Length_of_X );
	varargout(1) = {X};
elseif strcmpi(varargin{1}, ’Create DF’)
		X = varargin{2};
		F = varargin{3};
	DF = PARTIAL_DERIVATIVES( F, X );
	varargout(1) = {DF};
elseif strcmpi(varargin{1}, ’Create M-Files’)
		X = varargin{2};
		F = varargin{3};
		DF = varargin{4};
		F_FileName = varargin{5};
		DF_FileName = varargin{6};
	[s_X, s_F, s_DF] = CREATE_STRINGS(F, DF, X, F_FileName, DF_FileName);
	CREATE_FILES(s_X, s_F, s_DF, F_FileName, DF_FileName);
	varargout(1) = {’ODE FUNCTIONS CREATED’};
end

%% SUBFUNCTION: CREATE STATE VECTOR -------------------------------------
function X = STATE_VECTOR( Length_of_X )
	for i=1:Length_of_X
		eval([ ’X(’ int2str(i) ’,1) = sym(’’x’ ...
			int2str(i) ’’’, ’’real’’);’]);
	end
return

%% SUBFUNCTION: CALCULATE PARTIAL DERIVATIVES ---------------------------
function DF = PARTIAL_DERIVATIVES( F, X )
	for i = 1: length(F)
		for j = 1: length(F)
			DF(i,j) = diff(F(i),X(j));
		end
	end
return

%% SUBFUNCTION: CREATE M-FILE STRINGS
function [s_X, s_F, s_DF] = CREATE_STRINGS(F, DF, X, F_Name, DF_Name)
% This subfunction creates the character strings used in writing each
% m-file.
	s_F.HEADING = ...
		[’function [ F ] = ’ F_Name ’( X )’];
	s_DF.HEADING = ...
		[’function [ DF ] = ’ DF_Name ’( X )’];
	for i=1:length(X)
		s_X.LINE(i).STRING = ...
			[’x’ int2str(i) ’ = X(’ int2str(i) ’);’];
		s_F.LINE(i).STRING = ...
			[’F(’ int2str(i) ’, 1) = ’ char( F(i) ) ’; ’ ];
		for j=1:length(X)
			s_DF.LINE(i,j).STRING = ...
				[’DF(’ int2str(i) ’, ’ int2str(j) ’) = ’ ...
				char(DF(i,j)) ’;’ ];
		end
	end
return

%% SUBFUNCTION: CREATE M-files
function [] = CREATE_FILES(s_X, s_F, s_DF, F_FileName, DF_FileName)
% This file creates m-files from character strings.
	fid_F = fopen([F_FileName ’.m’], ’wt’);
	fid_DF = fopen([DF_FileName ’.m’], ’wt’);
	% HEADING
		fprintf(fid_F, ’%s \n’, s_F.HEADING );
		fprintf(fid_DF, ’%s \n’, s_DF.HEADING);
	% X Variable
	for i=1:length(s_X.LINE)
		fprintf(fid_F, ’%s \n’, s_X.LINE(i).STRING );
		fprintf(fid_DF, ’%s \n’, s_X.LINE(i).STRING );
	end
	% Functions
	for i=1:length(s_X.LINE)
		fprintf(fid_F, ’%s \n’, s_F.LINE(i).STRING );
		for j=1:length(s_X.LINE)
			fprintf(fid_DF, ’%s \n’, s_DF.LINE(i,j).STRING );
		end
	end
	fclose(fid_F);
	fclose(fid_DF);
return
