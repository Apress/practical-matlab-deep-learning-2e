%% MAKEHELP Make function help and publish demos for a folder.
% This creates content for the helptoc.xml and demos.xml files and prints it to
% text files. If the function has a demo it is executed. The function html is
% placed in a subfolder in the html directory relative to this function. The
% demo html is placed in the relevant content folder.
%% Form
% MakeHelp( folder )

%% Copyright
% Copyright (c) 2015 Princeton Satellite Systems, Inc.
% All rights reserved.

%% Definition
function MakeHelp( folder, doDemos )

if nargin < 1
  folder = './';
end

% redo demos/functions publishing?
if nargin<2 || isempty(doDemos)
  doDemos = true;
end

disp(['Making help in ' folder])

thisDir = fileparts(mfilename('fullpath'));
htmlDir = fullfile(thisDir,'./','');

w = what(folder);
s = pwd;
[~,thisDir] = fileparts(s);
if (length(w)>1)
  error('Multiple folders of the same name found. Please use a partial path.');
end
if (isempty(w))
  error('No M-files found in %s',thisDir);
end
[success,message] = mkdir(fullfile(htmlDir,'functions'));
if ~success
  disp(message)
  return;
end

fprintf(1,'Number of M-files: %d\n\n',length(w.m));
fTOC = fopen(fullfile(folder,'helptoc.txt'),'wt');
fprintf(fTOC,'<tocitem target="function_categories.html#1">%s\n',folder);
for kM = 1:length(w.m)
  [~,thisFile] = fileparts(w.m{kM});
  if strcmp(thisFile,mfilename)
    continue;
  end
  disp(w.m{kM})
  isScript = false;
  try 
    nargin(w.m{kM});
  catch
    isScript = true;
  end
  if ~isScript
    hasDemo = true;
    try
      eval(thisFile);
      close all;
    catch ME
      fprintf(1,'\tERROR: %s\n',ME.message);
      hasDemo = false;
    end
    if hasDemo
      evalCode = true;
    else
      evalCode = false;
    end
    funcDir = fullfile(htmlDir,'functions','');
    publish(w.m{kM},struct('format','html',...
                           'outputDir',funcDir,...
                           'evalCode',evalCode,...
                           'showCode',false));
    fprintf(fTOC,'\t<tocitem target="./functions/%s.html">%s</tocitem>\n',thisFile,thisFile);
  else
    % no arguments, file is a script
    if ~strcmp(w.m{kM},'Contents.m') && doDemos
      demoDir = fullfile(folder,'html','');
      publish(w.m{kM},struct('format','html',...
                           'outputDir',demoDir,...
                           'evalCode',true,...
                           'showCode',true));
      close all;
%       fid = fopen(w.m{kM});
%       line = fgetl(fid);
%       [~,comment] = strtok(line);
%       fclose(fid);
%       fprintf(fDEM,'<demoitem>\n\t<label>%s</label>\n',strtrim(comment));
%       fprintf(fDEM,'\t<callback>%s</callback>\n',thisFile); 
%       fprintf(fDEM,'\t<file>%s/html/%s.html</file>\n</demoitem>\n',thisDir,thisFile);
    end
  end
end
fprintf(fTOC,'</tocitem>\n');
fclose(fTOC);
type(fullfile(folder,'helptoc.txt'))

% fprintf(fDEM,'</demosection>\n');
% fclose(fDEM);
