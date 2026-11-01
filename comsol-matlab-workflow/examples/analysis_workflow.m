function result=analysis_workflow(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED: modal, FRF, transient, acoustics or optimization adapter.
% cfg.configure(model,cfg) implements approved, 5.6-documented physics/mesh/study.
% cfg.solve(model,cfg) runs the inspected study/solver.
% cfg.extract(model,cfg) returns values; cfg.validate(values,cfg) returns status/checks.
% cfg.export(model,values,validation,runDir) writes NEW MPH/CSV/MAT/PNG, no originals.
assert(isequal(cfg.authorized,true),'Workflow:Authorization','Task not authorized.');
callbacks={'configure','solve','extract','validate','export'};
for k=1:numel(callbacks),assert(isa(cfg.(callbacks{k}),'function_handle'));end
assert(isfolder(runDir),'Workflow:RunDirectory','Prepared independent directory required.');
try
    cfg.configure(model,cfg);
    cfg.solve(model,cfg);
    values=cfg.extract(model,cfg);
    validation=cfg.validate(values,cfg);
    assert(isfield(validation,'status') && isfield(validation,'checks') ...
        && ~isempty(validation.checks),'Workflow:Validation','Explicit checks required.');
    cfg.export(model,values,validation,runDir);
    result=struct('validation',validation,'values',values);
catch ME
    file=fullfile(runDir,'matlab_error.txt');
    if ~isfile(file)
        fid=fopen(file,'w','n','UTF-8');
        if fid>=0
            cleaner=onCleanup(@()fclose(fid));
            fprintf(fid,'%s',getReport(ME,'extended','hyperlinks','off'));
            clear cleaner
        end
    end
    rethrow(ME);
end
end
