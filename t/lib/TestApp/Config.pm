package TestApp::Config;
use parent 'Ze::Config';
use TestApp::Home;

sub home { TestApp::Home->get() }
1;
