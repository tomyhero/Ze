package TestApp::PC;
use Mouse;
extends 'Ze::WAF';

__PACKAGE__->context_class('TestApp::WAF::Context');
__PACKAGE__->dispatcher_class('TestApp::WAF::Dispatcher::Router');
__PACKAGE__->view_class('TestApp::PC::View');



__PACKAGE__->meta->make_immutable();

1;
