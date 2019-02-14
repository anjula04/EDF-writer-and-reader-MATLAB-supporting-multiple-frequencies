function [data_write, SmpFrq] = DummyData()
% clearvars
% clc


SmpFrq = [1; 2; 10];
Dur = 2; % Duration of the signal in seconds
NfSignals = length(SmpFrq);

data_write = cell(NfSignals,1); % pre-allocation
for i = 1:NfSignals
    data_write{i,1} = repmat(i,1,(SmpFrq(i)*Dur));
end