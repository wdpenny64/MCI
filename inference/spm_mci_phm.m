function [logev] = spm_mci_phm (L)
% Compute Log Evidence using Posterior Harmonic Mean (PHM)
% FORMAT [logev] = spm_mci_phm (L)
%
% L          [S x 1] vector containing log-likelihood of samples
% logev      log evidence from PHM
%__________________________________________________________________________
% Copyright (C) 2015 Wellcome Trust Centre for Neuroimaging

% Will Penny
% $Id: spm_mci_phm.m 6548 2015-09-11 12:39:47Z will $

Lbar=mean(L);
S=length(L);
maxnum=709;
delta=min(Lbar-L,maxnum);
logev=-log(sum(exp(delta)/S))+Lbar;

% if isnan(logev) | isinf(logev)
%     keyboard
% end