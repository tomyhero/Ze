package Ze::Home;
use warnings;
use strict;
use parent 'App::Home';
1;

=head1 NAME

Ze::Home - fine your application home


=head1 SYNOPSYS

 package MyApp::Home;
 use parent 'Ze::Home';
 1;

 my $home = MyApp::Home->get(); # Path::Class::File

=cut
