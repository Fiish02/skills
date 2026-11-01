function values = result_extraction(model, cfg)
% DOC_VERIFIED: mphglobal/mphinterp/mpheval 5.6. RUNTIME_NOT_TESTED.
% cfg: dataset, solnum, outersolnum, globalExpression, fieldExpression, coord.
assert(isnumeric(cfg.coord) && ismatrix(cfg.coord),'Workflow:Coordinates','coord must be sdim-by-N.');
selector = {'dataset',cfg.dataset,'solnum',cfg.solnum,'outersolnum',cfg.outersolnum};
[values.global_value,values.global_unit] = mphglobal(model,{cfg.globalExpression},selector{:});
[values.interpolated,values.interpolated_unit] = mphinterp(model,{cfg.fieldExpression}, ...
    'coord',cfg.coord,selector{:},'complexout','on');
values.nodes = mpheval(model,{cfg.fieldExpression},selector{:},'complexout','on');
arrays = {values.global_value,values.interpolated,values.nodes.d1};
for k = 1:numel(arrays)
    x = arrays{k};
    assert(~isempty(x) && all(~isnan(x(:)) & ~isinf(x(:))), ...
        'Workflow:InvalidResult','Empty/NaN/Inf values require investigation.');
end
% Also validate units, shape, coordinate mapping, selectors and physical limits
% against the task-specific acceptance criteria before returning PASS.
end
