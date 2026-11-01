function result=frequency_domain(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED. Specialist adapter; not a complete physical model.
% cfg.frequencies must carry an agreed frequency unit; configure excitation, damping and complex FRF metric.
% configure/solve/extract/validate/export callbacks follow analysis_workflow.m.
assert(isfield(cfg,'frequencies') && all(isfinite(cfg.frequencies)) && all(cfg.frequencies>=0));
result=analysis_workflow(model,cfg,runDir);
end
