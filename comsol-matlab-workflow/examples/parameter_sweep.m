function audits = parameter_sweep(model, parameter, expressions, runDir, executeApprovedPoint, authorized)
% Values must come from config/model_config.m; archive cfg/sync for each run.
% Low-level adapter, not a second independent design-parameter source.
% DOC_VERIFIED primitive calls: param.get/set 5.6. RUNTIME_NOT_TESTED.
% executeApprovedPoint(model,pointDir) must rebuild approved dependencies,
% solve the approved sequence, save outputs and return validation.status/checks.
assert(isequal(authorized,true),'Workflow:Authorization','Sweep must be authorized.');
assert((iscellstr(expressions) || isstring(expressions)) && ~isempty(expressions), ...
    'Workflow:Expressions','Provide explicit unit-bearing expressions.');
expressions = cellstr(expressions);
assert(isa(executeApprovedPoint,'function_handle'),'Workflow:Callback','Supply an approved point workflow.');
original = char(model.param().get(parameter));
audits = cell(numel(expressions),1);
for k = 1:numel(expressions)
    pointDir = fullfile(runDir,'output',sprintf('point_%04d',k));
    assert(~isfolder(pointDir),'Workflow:ExistingOutput','Point directory exists.');
    mkdir(pointDir);
    model.param().set(parameter,expressions{k});
    % Fail fast and preserve the failing point; never substitute zero results.
    result = executeApprovedPoint(model,pointDir);
    assert(isfield(result,'validation') && strcmp(result.validation.status,'PASS') ...
        && isfield(result.validation,'checks') && ~isempty(result.validation.checks), ...
        'Workflow:UnvalidatedPoint','Point lacks acceptance evidence.');
    audits{k} = struct('index',k,'expression',expressions{k},'result',result);
end
% Deliberately leave the working model at its final point. Restoring only the
% parameter would mismatch its geometry/mesh/solution; caller decides next step.
fprintf('Original parameter expression: %s\n',original);
end
