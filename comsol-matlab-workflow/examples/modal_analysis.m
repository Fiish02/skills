function result=modal_analysis(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED. Specialist adapter; not a complete physical model.
% Mode count, search range and normalization must be configured from the approved 5.6 model.
% configure/solve/extract/validate/export callbacks follow analysis_workflow.m.
assert(isfield(cfg,'modeCount') && cfg.modeCount>=1 && fix(cfg.modeCount)==cfg.modeCount);
result=analysis_workflow(model,cfg,runDir);
end
