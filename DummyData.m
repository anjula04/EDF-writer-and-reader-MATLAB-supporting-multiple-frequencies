% Creates random data with multiple frequencies to test the EDF writing

function [data_write, SmpFrq] = DummyData()

SmpFrq = [1; 2; 10];            % predefined sampling frequencies
Dur = 2;                        % Duration of the signal in seconds
NfSignals = length(SmpFrq);

data_write = cell(NfSignals,1); % pre-allocation
for i = 1:NfSignals
    data_write{i,1} = randn(1,(SmpFrq(i)*Dur));
end