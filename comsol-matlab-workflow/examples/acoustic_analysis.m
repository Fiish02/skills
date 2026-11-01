function result=acoustic_analysis(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED. Specialist adapter; not a complete physical model.
% Configure documented pressure/coupling/PML features; define amplitude/RMS, units and integration normals.
% configure/solve/extract/validate/export callbacks follow analysis_workflow.m.
assert(isfield(cfg,'metric'));
if strcmp(cfg.metric,'SPL'), assert(isfield(cfg,'referencePressure') && cfg.referencePressure>0); end
result=analysis_workflow(model,cfg,runDir);
end
