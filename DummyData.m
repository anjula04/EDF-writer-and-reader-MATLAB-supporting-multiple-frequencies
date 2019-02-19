% Creates random data with multiple frequencies to test the EDF writing

function [data_write, SmpFrq] = DummyData()

SmpFrq = [0.23; 50; 23.1];            % predefined sampling frequencies
Dur = 20.2;                        % Duration of the signal in seconds
NfSignals = length(SmpFrq);

data_write = cell(NfSignals,1); % pre-allocation
for i = 1:NfSignals
    data_write{i,1} = randn(1,floor((SmpFrq(i)*Dur)));
end
