function result=optimization_case(model,cfg,runDir)
% PENDING / RUNTIME_NOT_TESTED. Specialist adapter; not a complete physical model.
% One explicitly supplied design evaluation; external optimizer or sweep records every case and failure, never substitutes zero.
% configure/solve/extract/validate/export callbacks follow analysis_workflow.m.
assert(isfield(cfg,'designParameters') && isstruct(cfg.designParameters));
result=analysis_workflow(model,cfg,runDir);
end
