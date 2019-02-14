clearvars;
spc = 32;

% Importing data and relevant info
[data_write, SmpFrq] = DummyData();

%%% Write header record
machinefmt = 'ieee-le'; encodingIn = 'US-ASCII';
fileID = fopen('test.edf','w', machinefmt, encodingIn);

% Record entries ***********************
Version         = '0';                 % Version = 0
LocalPatientID  = 'PAT';
LocalRecordID   = 'REC';
StartDate       = '01.02.03';           % dd.mm.yy
StartTime       = '04.05.06';           % hh.mm.ss 
Reserved1       = 'r1';                 % EDF+C or EDF+D 
NfRecords       = length(data_write{1})/SmpFrq(1); % TODO perform a check to see this is the same for all the signals
DuRecord        = 1;                    % TODO combine this with NfSmpDatRec | in seconds
NfSignals       = length(data_write); 
NfBytesHeader   = 256*(1+NfSignals);    
Label           = {'Lb1'; 'Lb22'; 'Lb333'};       % semicolon because easy to read at the fwrite
Transducer      = {'Td1'; 'Td222'; 'Td333'};
PhysDim         = {'Dim1'; 'Dim22'; 'Dim333'};
PhysMin         = [0.1; -22; 33];
PhysMax         = [11; 2.22; 3333];
DigiMin         = [0; 0.001; 33];
DigiMax         = [1111; 11; 3333];
PreFilt         = {'PF1'; 'PF22'; 'PF333'};
NfSmpDatRec     = SmpFrq;             % TODO check for this maximum condition | = sampling rate if DuRecord=1s % maximum samples per data record is 61440 (Kemp et. al. 1992)
Reserved2       = {'r21';'';'r23'};

% Write records to file ******************
fwrite(fileID, [Version repmat(spc,1,7)], 'char*1'); % Version=0 (8 bytes)
fwrite(fileID, [LocalPatientID repmat(spc,1,80-length(LocalPatientID))], 'char*1');
fwrite(fileID, [LocalRecordID repmat(spc,1,80-length(LocalPatientID))], 'char*1'); 
fwrite(fileID, StartDate, 'char*1');
fwrite(fileID, StartTime, 'char*1');
fwrite(fileID, [num2str(NfBytesHeader) repmat(spc,1,8-length(num2str(NfBytesHeader)))],'char*1');
fwrite(fileID, [Reserved1 repmat(spc,1,44-length(Reserved1))], 'char*1');
fwrite(fileID, [num2str(NfRecords) repmat(spc,1,8-length(num2str(NfRecords)))]);
fwrite(fileID, [num2str(DuRecord) repmat(spc,1,8-length(num2str(DuRecord)))]);
fwrite(fileID, [num2str(NfSignals) repmat(spc,1,4-length(num2str(NfSignals)))]);

for i = 1:NfSignals
    fwrite(fileID, [Label{i} repmat(spc,1,16-length(Label{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [Transducer{i} repmat(spc,1,80-length(Transducer{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [PhysDim{i} repmat(spc,1,8-length(PhysDim{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(PhysMin(i,:)) repmat(spc,1,8-length(num2str(PhysMin(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(PhysMax(i,:)) repmat(spc,1,8-length(num2str(PhysMax(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(DigiMin(i,:)) repmat(spc,1,8-length(num2str(DigiMin(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(DigiMax(i,:)) repmat(spc,1,8-length(num2str(DigiMax(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [PreFilt{i} repmat(spc,1,80-length(PreFilt{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(NfSmpDatRec(i,:)) repmat(spc,1,8-length(num2str(NfSmpDatRec(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [Reserved2{i} repmat(spc,1,32-length(Reserved2{i}))], 'char*1');
end


%% Write data to the file**************************

% Data in a cell
for i = 1:NfRecords 
    for j = 1:NfSignals
        temp_data = data_write{j}((NfSmpDatRec(j)*(i-1)+1) : NfSmpDatRec(j)*i); % rearranging data to [1 1 1 2 2 2 3 3 3 1 1 1 2 2 2 3 3 3] format
        fwrite(fileID,temp_data,'int16');
    end
end

fclose(fileID);