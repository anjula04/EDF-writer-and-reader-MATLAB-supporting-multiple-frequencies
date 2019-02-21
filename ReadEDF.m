% Reads  data created from WriteEDF.m
% Output data 
%     format: cell
%     variable: data_read
% Sampling frequencies 
%     values in 'NfSmpDatRec' in the header are the sampling frequencies
%  Header infomation
%      variable: Header_r

clearvars; clc;

file_name = 'edf_test'; % name of the file to be read

machinefmt = 'ieee-le'; encodingIn = 'US-ASCII';
Header_r = struct;
fileID = fopen(strcat(file_name, '.edf'),'r',machinefmt,encodingIn);  

%% Extracting header information
Header_r.Version             = str2double(char(fread(fileID,8,'uint8')'));
Header_r.LocalPatientID      = char(fread(fileID,80,'uint8')');
Header_r.LocalRecordingID    = char(fread(fileID,80,'uint8')');
Header_r.StartDate           = char(fread(fileID,8,'uint8')');
Header_r.StartTime           = char(fread(fileID,8,'uint8')');
Header_r.NfBytesHeader      = str2double(char(fread(fileID,8,'uint8')'));
Header_r.Reserved1           = char(fread(fileID,44,'uint8')');
Header_r.NfDataRecords       = str2double(char(fread(fileID,8,'uint8')'));    % No. of data records
Header_r.DuRecord            = str2double(char(fread(fileID,8,'uint8')'));    % Duration of a data record
Header_r.NfSignals           = str2double(char(fread(fileID,4,'uint8')'));

for i = 1:Header_r.NfSignals
    Header_r.Label(i,:) = char(fread(fileID,16,'uint8')');
end
for i = 1:Header_r.NfSignals
    Header_r.Transducer(i,:) = char(fread(fileID,80,'uint8')');
end
for i = 1:Header_r.NfSignals
    Header_r.PhysDim(i,:)   = char(fread(fileID,8,'uint8')');
end
for i = 1:Header_r.NfSignals
    Header_r.PhysMin(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:Header_r.NfSignals
    Header_r.PhysMax(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:Header_r.NfSignals
    Header_r.DigiMin(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:Header_r.NfSignals
    Header_r.DigiMax(i,:)    = str2double(char(fread(fileID,8,'uint8')'));
end
for i = 1:Header_r.NfSignals
    Header_r.PreFilt(i,:)    = char(fread(fileID,80,'uint8')');
end
for i = 1:Header_r.NfSignals
    Header_r.NfSmpDatRec(i,:)= str2double(char(fread(fileID,8,'uint8')'));   % No. of Samples per data record
end
for i = 1:Header_r.NfSignals
    Header_r.Reserved2(i,:)  = char(fread(fileID,32,'uint8')');
end

%% Extracting data and store in a cell

for i = 1:Header_r.NfDataRecords
    for j = 1:Header_r.NfSignals
        data_read_map{j,1}((Header_r.NfSmpDatRec(j)*(i-1)+1) : Header_r.NfSmpDatRec(j)*i) = fread(fileID,Header_r.NfSmpDatRec(j),'int16');
    end
end

% Remapping data to original values that was there before wriring
m = (Header_r.DigiMax - Header_r.DigiMin)./(Header_r.PhysMax - Header_r.PhysMin);
c = Header_r.DigiMax - m.*Header_r.PhysMax;
for i = 1:Header_r.NfSignals
    data_read{i,1} = (data_read_map{i,:} - c(i))/m(i);
end

fclose(fileID);
fprintf('''%s.edf'' successfully read.\n',file_name);
