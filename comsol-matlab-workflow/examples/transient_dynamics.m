function result=transient_dynamics(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED. Specialist adapter; not a complete physical model.
% Configure initial conditions, load history, solver steps and output sampling separately.
% configure/solve/extract/validate/export callbacks follow analysis_workflow.m.
assert(isfield(cfg,'times') && numel(cfg.times)>1 && all(isfinite(cfg.times)) && all(diff(cfg.times)>0));
result=analysis_workflow(model,cfg,runDir);
end
