function audit = parameter_modification(model, name, approvedExpression, authorized)
% Values must come from config/model_config.m; archive cfg/sync for each run.
% Low-level adapter, not a second independent design-parameter source.
% DOC_VERIFIED: model.param() 5.6. RUNTIME_NOT_TESTED.
assert(isequal(authorized,true),'Workflow:Authorization','Parameter change must be authorized.');
assert(ischar(name) && ischar(approvedExpression),'Workflow:Type','Use explicit character vectors.');
names = cellfun(@char,cell(model.param().varnames()),'UniformOutput',false);
assert(any(strcmp(names,name)),'Workflow:UnknownParameter','Inspect the existing parameter first.');
old = char(model.param().get(name));
audit = struct('name',name,'before',old,'after',approvedExpression);
model.param().set(name,approvedExpression);
assert(strcmp(char(model.param().get(name)),approvedExpression), ...
    'Workflow:ParameterMismatch','Stored expression differs from the requested expression.');
% A successful set does not validate geometry, solution freshness, or physics.
end
