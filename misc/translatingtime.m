function [es, rat, ferret, human]=translatingtime(days, species, pflag)
%   TRANLATINGTIME(DAYS, SPECIES, PFLAG) 
%   TRANSLATINGTIME implements the Workman translating time model to translate time across
%   species
%   http://www.translatingtime.net/
%   TRANLATINGTIME(days, species, pflag) 
%   Note that the Workman model has interaction terms that aren't
%   implemented, so these numbers will be WRONG for cortical neurogenesis in
% or anything to do with cat retina.
% Input:
%       days: (postconception or postnatal) for the input species
%       species: name of the input ('rat', 'ferret', 'human')
%       pflag: ('PC' or 'PN' to represent post-conception or postnatal)
% Returns:
%       the Workman event score, and equivalent post-conception and postnatal days for 
%       for rat, ferret and human
% easy to add more species, using the numbers from this table
%
% http://www.translatingtime.net/species

if ~exist('pflag')
    disp('using post-conception days');
    pflag='PC';
end

if pflag=='PC'
    pc=days;
else
    if strcmp(species, 'rat')
    pc=days+21;
    elseif strcmp(species, 'ferret')
        pc=days+41;
    elseif strcmp(species, 'human')
        pc=days+270;
    else
    disp('species not recognized');
    return
    end
end
if strcmp(species, 'rat')
    es=(log(pc)-2.31)./1.705;
elseif strcmp(species, 'ferret')
    es=(log(pc)-2.706)./2.174;
elseif strcmp(species,'human')
    es=(log(pc)-3.167)./3.72;
elseif strcmp(species, 'event')
    es=pc;
end

rat = round(exp(2.31 + 1.705*es));
ferret = round(exp(2.706 + 2.174*es));
human = round(exp(3.167 + 3.72*es));
    
disp(['es = ', num2str(round(es, 2))]); 
disp(['RAT: PC = ', num2str(rat), ' / PN  = ', num2str(rat-21)]); 
disp(['FERRET, PC = ', num2str(ferret), ' / PN  = ', num2str(ferret-41)]);  
disp(['HUMAN, PC = ', num2str(human), ' / PN  = ', num2str(human-270)]); 

