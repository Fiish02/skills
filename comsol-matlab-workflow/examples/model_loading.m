function [model, audit] = model_loading(originalFile, runDir)
% DOC_VERIFIED 5.6 mphload / ModelUtil.tags. RUNTIME_NOT_TESTED.
% Load only a new working copy; requires an existing authorized connection.
assert(isfile(originalFile),'Workflow:MissingModel','Input MPH does not exist.');
[~,base,ext] = fileparts(originalFile);
assert(strcmpi(ext,'.mph'),'Workflow:Extension','Expected an MPH file.');
copyDir = fullfile(runDir,'input');
assert(isfolder(copyDir),'Workflow:RunDirectory','Run input directory must exist.');
workCopy = fullfile(copyDir,[base '_working.mph']);
assert(~isfile(workCopy),'Workflow:ExistingFile','Working copy already exists.');
import com.comsol.model.util.*
tag = ['wf_' strrep(char(java.util.UUID.randomUUID()),'-','')];
tags = cellfun(@char,cell(ModelUtil.tags()),'UniformOutput',false);
assert(~any(strcmp(tags,tag)),'Workflow:TagCollision','Tag already exists.');
[ok,message] = copyfile(originalFile,workCopy);
assert(ok,'Workflow:CopyFailed','%s',message);
model = mphload(workCopy,tag);
audit = struct('original',originalFile,'working_copy',workCopy,'model_tag',tag);
% Inspect the loaded structure before passing this model to mutation examples.
end
