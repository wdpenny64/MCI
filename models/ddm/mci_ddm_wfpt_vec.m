function [pr] = mci_ddm_wfpt_vec (ddm,M,U,y)% Wiener First Passage Time (WFPT) density for multiple decisions% FORMAT [pr] = mci_ddm_wfpt_vec (ddm,M,U,y)%% ddm       .v drift rate, .a boundary sep, .b non decision time% M         model% U         inputs% y         y(n,1)= nth outcome, x_n; y(n,2)=nth reaction time, t_n%% pr        joint probability density, p(n) p(y_n)=p(x_n,t_n)% Ksmall    Number of terms used in small time approximation% Klarge    Number of terms used in large time approximation%% This code is based on the wfpt.m function from % Navarro and Fuss (2009) Fast and accurate calculations% for first-passage times in Wiener diffusion models.% Journal of Mathematical Psychology, 53:222-230.%__________________________________________________________________________% Copyright (C) 2016 Wellcome Trust Centre for Neuroimaging% Will Penny% $Id$%       .v     drift rate%       .a     boundary separation%       .b     non-decision time%       .r     starting point (relative)%              Absolute start z= r*a% Truncation error in series expansiontry err=M.truncation_error; catch err=10^(-6); endv=ddm.v;a=ddm.a;b=ddm.b;% Unbiased DDM if r not specifiedtry r = ddm.r; catch r=0.5; end% Remove trials for which t is less than non-decision time % Set probability density of these to eps (at end of this function)ni=find(y(:,2)<=ddm.b);nk=find(y(:,2)>ddm.b);Ny_orig=size(y,1);if length(ni) > 0    y(ni,:)=[];    if length(a) > 1        % if a varies over trial, remove offending trial value        a(ni)=[];    endendNy=size(y,1);if Ny==0    % If no trials left !    pr=eps*ones(Ny,1);    returnend% Remove non-decision timet=y(:,2)-ddm.b;% use normalized timett=t./(a.^2); % Flip sign of v to -ve for correct trialssgn=ones(Ny,1)-2*y(:,1);v = sgn*ddm.v;% Set w=r for error trials and (1-r) for correct trialsw=y(:,1)*(1-r)+(1-y(:,1))*r;% calculate number of terms needed for large tlow_enough=pi*tt*err<1;kl_low=sqrt(-2*log(pi*tt*err)./(pi^2*tt)); % boundkl_high=1./(pi*sqrt(tt)); % set to boundary conditionkl_low=max(kl_low,kl_high); % ensure boundary conditions metkl=low_enough.*kl_low+(1-low_enough).*kl_high;% calculate number of terms needed for small tlow_enough=2*sqrt(2*pi*tt)*err<1; % if error threshold is set low enoughks_low=2+sqrt(-2*tt.*log(2*sqrt(2*pi*tt)*err)); % boundks_low=max(ks_low,sqrt(tt)+1); % ensure boundary conditions are metks_high=2*ones(Ny,1); % minimal kappa for that caseks=low_enough.*ks_low+(1-low_enough).*ks_high;% compute f(tt|0,1,w)%initialize densityp=eps*ones(Ny,1);% Further Approximation !!!% Split trials into those that will use small versus large t approximation% Use same K value for all trials of each type (but diff for type)sb=(ks<kl); % small is betterif sum(sb) > 0    ksmax=max(ks(sb));    K=ceil(ksmax); % round to smallest integer meeting error    if K>30        keyboard    end    for k=-floor((K-1)/2):ceil((K-1)/2) % loop over k        p(sb)=p(sb)+(w(sb)+2*k).*exp(-((w(sb)+2*k).^2)./2./tt(sb)); % increment sum    end    p(sb)=p(sb)./sqrt(2*pi*tt(sb).^3); % add constant termendlb=(ks>=kl); % large is betterif sum(lb) > 0    klmax=max(kl(lb));	K=ceil(klmax); % round to smallest integer meeting error    if K > 30        keyboard    end	for k=1:K		p(lb)=p(lb)+k*exp(-(k^2).*(pi^2).*tt(lb)/2).*sin(k*pi*w(lb)); % increment sum	end	p(lb)=p(lb)*pi; % add constant termend% convert to f(t|v,a,w)p=p.*exp(-v.*a.*w -(v.^2).*t/2)./(a.^2); % Set prob density of 'bad trials' (y(:,2)>b) to epspr=eps*ones(Ny_orig,1);pr(nk)=p;