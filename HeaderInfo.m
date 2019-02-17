function Header_w = HeaderInfo()
% Header information according to EDF format
% Kemp et. al.: "A simple format for exchange of digitized polygraphic recordings", Electroencephalography and clinical Neurophysiology, 82:391-3, 1992.

Header_w                  = struct;
Header_w.Version          = '0';                            % Do not change
Header_w.LocalPatientID   = 'PATID';                        % Max 80 characters 
Header_w.LocalRecordID    = 'RECID';                        % Max 80 characters
Header_w.SmpFreq          = [1; 2; 10];                     % Min 1 Hz (this example has 3 signals)
Header_w.StartDate        = '01.02.03';                     % dd.mm.yy (must be in this format)
Header_w.StartTime        = '04.05.06';                     % hh.mm.ss (must be in this format)
Header_w.Reserved1        = '';                             % Must be empty
Header_w.Label            = {'Lb1'; 'Lb22'; 'Lb333'};       % Max 16 character per label
Header_w.Transducer       = {'Td1'; 'Td222'; 'Td333'};      % Max 80 character per transducer
Header_w.PhysDim          = {'Dim1'; 'Dim22'; 'Dim333'};    % Max 8 character per dimension
Header_w.PreFilt          = {'PF1'; 'PF22'; 'PF333'};       % Max 80 character per Pre-filter
Header_w.Reserved2        = {'';'';''};                     % Must be empty (should be equal to no. of signals)