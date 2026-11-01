function matlab_entry_template(runDir)
% Execute an authorized task in a prepared run, optionally in an EXISTING
% LiveLink session. Never starts or authenticates a COMSOL connection.
context = jsondecode(fileread(fullfile(runDir,'run_context.json')));
statusFile = fullfile(runDir,'matlab_status.json');
assert(~isfile(statusFile),'Workflow:ExistingStatus','Refusing to replay a run.');
state = struct('status','RUNNING','stage','initialization','started_utc',utc_now(), ...
    'matlab_version',version,'matlab_root',matlabroot,'comsol_version','NOT TESTED', ...
    'validation','NOT TESTED','server_log','UNAVAILABLE', ...
    'solver_log','NOT REQUESTED','error','');
write_state(statusFile,state);
diaryPath = fullfile(runDir,'logs','matlab_diary.txt');
assert(~isfile(diaryPath),'Workflow:ExistingLog','Refusing to overwrite a diary.');
originalPath = path;
cleanup = onCleanup(@() restore_session(originalPath));
% Authentication must already be complete before logging starts.
diary(diaryPath);
try
    assert(strcmp(version('-release'),'2023a'),'Workflow:Release','Expected R2023a.');
    assert(strcmpi(matlabroot,'D:\Program Files\MATLAB\R2023a'), ...
        'Workflow:Root','Unexpected MATLAB root.');
    if context.require_comsol
        state.stage = 'existing_connection'; write_state(statusFile,state);
        com.comsol.model.util.ModelUtil.tags(); % Read-only existing request.
        state.comsol_version = char(mphversion);
        assert(~isempty(regexp(state.comsol_version,'5\.6','once')), ...
            'Workflow:COMSOLVersion','Expected COMSOL 5.6.');
        progressFile = fullfile(runDir,'logs','comsol_solver.log');
        try
            enabled = com.comsol.model.util.ModelUtil.showProgress(progressFile);
            if enabled
                state.solver_log = 'REQUESTED';
            else
                state.solver_log = 'UNAVAILABLE';
            end
        catch logException
            state.solver_log = 'UNAVAILABLE';
            write_new_text(fullfile(runDir,'logs','solver_log_error.txt'), ...
                getReport(logException,'extended','hyperlinks','off'));
        end
    end
    state.stage = 'task'; write_state(statusFile,state);
    addpath(fullfile(runDir,'source'),'-begin'); % Session only; restored on return.
    cfg = jsondecode(fileread(fullfile(runDir,'input','config.json')));
    result = feval(context.task_function,cfg,runDir);
    assert(isstruct(result) && isscalar(result),'Workflow:Result','Task must return one struct.');
    if isfield(result,'metrics'), check_finite(result.metrics); end
    state.stage = 'validation'; write_state(statusFile,state);
    state.status = 'COMPLETED_UNVALIDATED';
    if isfield(result,'validation') && isfield(result.validation,'status')
        state.validation = result.validation.status;
        if strcmp(state.validation,'PASS') && isfield(result.validation,'checks') ...
                && ~isempty(result.validation.checks)
            state.status = 'PASS';
        elseif strcmp(state.validation,'FAIL')
            error('Workflow:ValidationFailed','Task acceptance criteria failed.');
        end
    end
    resultPath = fullfile(runDir,'output','task_result.mat');
    assert(~isfile(resultPath),'Workflow:ExistingOutput','Task result already exists.');
    save(resultPath,'result');
    state.stage = 'finished'; state.finished_utc = utc_now();
    write_state(statusFile,state);
catch exception
    state.status = 'FAIL'; state.finished_utc = utc_now();
    state.error = getReport(exception,'extended','hyperlinks','off');
    write_new_text(fullfile(runDir,'logs','matlab_error.txt'),state.error);
    write_state(statusFile,state);
    rethrow(exception);
end
% Leave the existing model/connection intact. Do not disconnect/clear/quit.
end

function restore_session(originalPath)
diary off
path(originalPath);
end

function value = utc_now()
value = char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));
end

function write_state(filename,state)
% Only this run's own state is updated; original inputs are never overwritten.
fid = fopen(filename,'w','n','UTF-8');
assert(fid >= 0,'Workflow:LogOpen','Cannot write run state.');
closer = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',jsonencode(state,'PrettyPrint',true));
end

function write_new_text(filename,text)
assert(~isfile(filename),'Workflow:ExistingOutput','Refusing to overwrite log.');
fid = fopen(filename,'w','n','UTF-8');
assert(fid >= 0,'Workflow:LogOpen','Cannot write log.');
closer = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',text);
end

function check_finite(value)
if isnumeric(value)
    assert(all(~isnan(value(:)) & ~isinf(value(:))), ...
        'Workflow:Nonfinite','Metrics contain NaN or Inf.');
elseif isstruct(value)
    names = fieldnames(value);
    for idx = 1:numel(value)
        for k = 1:numel(names), check_finite(value(idx).(names{k})); end
    end
elseif iscell(value)
    for k = 1:numel(value), check_finite(value{k}); end
end
end
