clearvars;

% function [data] = ReadTest1(filename)
machinefmt = 'ieee-le'; encodingIn = 'US-ASCII';
fileID = fopen('test.edf','r',machinefmt,encodingIn);

%% Extracting header information
Version             = str2double(char(fread(fileID,8,'uint8')'));
LocalPatientID      = char(fread(fileID,80,'uint8')');
LocalRecordingID    = char(fread(fileID,80,'uint8')');
StartDate           = char(fread(fileID,8,'uint8')');
StartTime           = char(fread(fileID,8,'uint8')');
NfBytesHeader       = str2double(char(fread(fileID,8,'uint8')'));
Reserved1           = char(fread(fileID,44,'uint8')');
NfDataRecords       = str2double(char(fread(fileID,8,'uint8')'));    % No. of data records
DuDataRecord        = str2double(char(fread(fileID,8,'uint8')'));    % Duration of a data record
NfSignals           = str2double(char(fread(fileID,4,'uint8')'));

for i = 1:NfSignals
    ChanLabels(i,:) = char(fread(fileID,16,'uint8')');
end
for i = 1:NfSignals
    TransdType(i,:) = char(fread(fileID,80,'uint8')');
end
for i = 1:NfSignals
    PhysDims(i,:)   = char(fread(fileID,8,'uint8')');
end
for i = 1:NfSignals
    PhysMin(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:NfSignals
    PhysMax(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:NfSignals
    DigiMin(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:NfSignals
    DigiMax(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:NfSignals
    PreFilt(i,:)    = char(fread(fileID,80,'uint8')');
end
for i = 1:NfSignals
    NfSmpDatRec(i,:)= str2double(char(fread(fileID,8,'uint8')'));   % No. of Samples per data record
end
for i = 1:NfSignals
    Reserved2(i,:)  = char(fread(fileID,32,'uint8')');
end

%% Method 2: Extracting data

% Store data in a cell
for i = 1:NfDataRecords 
    for j = 1:NfSignals
        data_read{j,1}((NfSmpDatRec(j)*(i-1)+1) : NfSmpDatRec(j)*i) = fread(fileID,NfSmpDatRec(j),'int16');
    end
end

fclose(fileID);



