package TestApp::PC::View;
use Ze::Class;
extends 'Ze::WAF::View';
use TestApp::Home;
use Ze::View;

sub _build_engine {
    my $self = shift;
    my $path = TestApp::Home->get()->subdir('view-test');
    return Ze::View->new(
        engines => [
            { engine => 'Ze::View::Xslate' , config => { path => $path } }, 
            { engine => 'Ze::View::JSON', config  => {} } 
        ]
    );

}


EOC;
