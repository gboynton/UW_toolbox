function out = xls2struct(filename, sheet, range, fieldnames)
%   function OUT = XLS2STRUCT(FILENAME, [SHEET], [RANGE], [FIELDNAMES])
%   XLS2STRUCT read Microsoft Excel spreadsheet data to matlab struct.
%   Replaces blank cells with NaN.
%   OUT = XLS2STRUCT(FILENAME) reads the data from the first worksheet in the
%   Microsoft excel spreadsheet named FILENAME. The fieldnames are specified
%   by the first row of the worksheet. Columns that are not headed by text
%   will be discarded (see use of fieldnames, below)
%   OUT = XLS2STRUCT(FILENAME, SHEETNAME) reads the specified worksheet
%   OUT = XLS2STRUCT(FILENAME, SHEETNAME, RANGE) reads from the specified worksheet
%   and range
%   OUT = XLS2STRUCT(FILENAME, SHEETNAME, RANGE, FIELDNAMES). Assumes the
%   workseet does NOT have headers, names the columns based on the fieldnames.
%   the number of fieldnames has to match the range. Range supported for XLSX
%   files only.
%
%   Input Arguments:
%
%   FILE    String that specifies the name of the file to read.
%   SHEET   Worksheet to read. One of the following:
%           * String that contains the worksheet name.
%           * Positive, integer-valued scalar indicating the worksheet
%             index.
%   RANGE   String that specifies a rectangular portion of the worksheet to
%           read. Not case sensitive. Use Excel A1 reference style.
%           If you do not specify a SHEET, RANGE must include both corners
%           and a colon character (:), even for a single cell (such as
%           'D2:D2').
%   FIELDNAMES Cell array that contains the field names into which columns
%           will be assigned length(fieldnames) must equal the number of columns
%           being read in
%
%   Example
%   out = xls2struct('xls2struct_testworkbook', 'headers', 'A2:E7', {'h1', 'h2', 'h3', 'h4', 'h5'})
%   
%   Written Geoffrey M. Boynton
%   Edited Ione Fine 2/24/2017

if nargin < 2
    sheet = 1;
    range = '';
elseif nargin <3
    range = '';
end

if isempty(range)
    range='';
end

[~,b,c] = xlsread(filename, sheet, range);

if exist('fieldnames', 'var')
    if size(c, 2) ~= length(fieldnames)
        error('xls2struct: the number of fieldnames must equal the number of columns')
    end
    stRow=1;
else
    fieldnames = rmspaces(b(1,:));
    stRow=2;
end
    
c = c(1:size(b,1),:);
out = [];
for i=1:length(fieldnames)
    if ~isempty(fieldnames{i})
        out.(fieldnames{i}) = c(stRow:end,strcmp(fieldnames,fieldnames{i}));
    end
end
