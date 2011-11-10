return router {
    submapper('/', {controller => 'Root'})
        ->connect('', {action => 'index'});
};
