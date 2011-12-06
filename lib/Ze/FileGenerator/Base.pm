package Ze::FileGenerator::Base;
use warnings;
use strict;
#use TestApp -command;
use Ze::View;
use UNIVERSAL::require;
use Path::Class;
use base qw/Class::Data::Inheritable Class::Accessor::Fast/;

__PACKAGE__->mk_classdata('view_type');

__PACKAGE__->mk_classdata('in_path');
__PACKAGE__->mk_classdata('out_path');

__PACKAGE__->mk_accessors(qw/view name/);

__PACKAGE__->view_type('Xslate');

sub setup_view {
    my $self = shift;
    $self->{view} = $self->create_view;
}
sub setup_name {
    my $self = shift;
    $self->{name} = $self->create_name;
}

sub create_view {
    my $self = shift;

    die 'impelement me';

}

sub create_name {
    my $self = shift;
    my $class = ref $self;
    my ($name) = $class =~ /::([a-zA-Z0-9_]+)$/;
    $name = lc $name;
}
sub setup {
    my $self = shift;
    $self->setup_view;
    $self->setup_name;
}

sub generate {
    my $self = shift;
    my $targets = shift;
    my $args = shift || {} ;

    my $vars = $args->{vars};
    my $view_type = $args->{view_type} || $self->view_type;

    $targets = ref $targets ? $targets : [$targets];

    for(@$targets){
        my $name =  $args->{name} || $self->name;
        my $file = sprintf("%s/%s",$_,$name);

        my $content = $self->view->render( $view_type ,{ file => $file , vars => $vars } );

        $self->write_file( $_, $content , $args );
    }
}

sub write_file {
    my $self    = shift;
    my $target  = shift;
    my $content = shift;
    my $args    = shift || {};
    my $name    = $args->{out_name} || $args->{name} || $self->name ;
    my $file = sprintf("%s/%s",$target,$name);
    my $out_file = $self->get_out_file( $file );
    $out_file->dir->mkpath();
    open(FH,'> ' . $out_file) ;
    print FH $content;
    close(FH);
}



sub get_out_file {
    my $self = shift;
    my $name = shift;
    my $dir = Path::Class::Dir->new( $self->out_path );
    return $dir->file( $name .'.inc');
}

sub run { die 'Implement Me' }



1;
