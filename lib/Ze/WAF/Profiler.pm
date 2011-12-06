package Ze::WAF::Profiler;
use Ze::Role;

has '__Profiler_tool' => ( is => 'rw');

before 'BUILD' => sub {
    my $self = shift;
    my $tool = Ze::WAF::Profiler::Tool->new();
    $tool->parent($self);
    $self->__Profiler_tool($tool);
    $tool->begin_method('BUILD');
};

after 'setup_context' => sub  {
    my $self = shift;
    $self->context_class->load_plugin('Ze::WAF::Plugin::Profiler');
};

after ['BUILD'] => sub {
    my $self  = shift;
    my $tool = $self->__Profiler_tool();
    $tool->end_method('BUILD');

    my $dispatcher = $self->dispatcher;
    $tool->loaded_controllers( $dispatcher->controllers );

    $tool->notice_waf();
};


after 'prepare_context' => sub {
    my $self = shift;
    my $tool = $self->__Profiler_tool;
    $tool->notice_waf_memory();
};



{
 package Ze::WAF::Profiler::Tool;
 use Time::HiRes qw(gettimeofday tv_interval );
 use Text::SimpleTable;
 use Plack::Util::Accessor qw(method_start method_end start controllers parent);
 use Devel::Size qw(total_size);
 use Ze::Util;
 use Term::ANSIColor;;
 use utf8;
 no warnings;

 our $LEVEL = 1;

 sub new {
    my $class = shift;
    my $self = bless {},$class;
    $self->start([gettimeofday]);
    $self->method_start({});
    $self->method_end([]);
    return $self;
 }

 sub begin_method {
    my $self   = shift;
    my $method = shift;

    my $data = $self->method_start;;
    $data->{$method}{start}  = [gettimeofday];
    $self->method_start($data);

 }

 sub end_method {
    my $self   = shift;
    my $method = shift;
    my $data = {
        method => $method,
        sec => tv_interval( $self->method_start->{$method}{start} ),
    };
    push @{$self->method_end},$data;
 }
 
 sub loaded_controllers {
    my $self = shift;
    my $controllers  = shift;
    $self->controllers($controllers);
 }

 sub notice_waf {
    my $self = shift;

    my $column_width = Ze::Util::term_width() - 20;

    my $col1 = int($column_width  / 3) || 10;
    my $t1 =Text::SimpleTable->new([$col1,'METHOD'],[$col1,'SEC'],[$col1,'SIZE']);
    for(@{$self->method_end}){
        $t1->row('WAF::' . $_->{method},$_->{sec},total_size($self->parent));
    }

    
    my $t2 =Text::SimpleTable->new([$column_width + 5,'LOADED CONTROLLER']);
    for(sort keys %{$self->controllers}){
        $t2->row($_);
    }
    print color 'yellow';
    print $t2->draw if $LEVEL > 2;
    print color 'blue';
    print $t1->draw if $LEVEL > 1;
    print color 'reset';
 }
 sub notice_waf_memory {
    my $self = shift;
    return if $LEVEL < 3;

    my $column_width = Ze::Util::term_width() - 15;
    my $t1 = Text::SimpleTable->new([$column_width,'WAF SIZE']);
    $t1->row(total_size($self->parent));
    print color 'blue';
    print $t1->draw();
    print color 'reset';
}

 sub notice_context {
    my $self = shift;

    my $c = $self->parent;

    my $column_width = Ze::Util::term_width() - 20;
    my $t4 = Text::SimpleTable->new([10,'PATH'],[ $column_width - 8 ,$c->req->path]);
    $t4->row('METHOD', $c->req->method);
    print color 'red';
    print $t4->draw;


    if(keys %{$c->args}){
        my $t3 = Text::SimpleTable->new([20,'ARGS'], [$column_width - 18 ,'VALUE']);
        for my $key ( sort keys %{$c->args}) {
            my $param = $c->args->{$key};
            my $value = defined($param) ? $param : '';
            $t3->row( $key, ref $value eq 'ARRAY' ? ( join ', ', @$value ) : $value );
        }
        print color 'yellow';
        print $t3->draw;
    }

    my $fdat = $c->req->as_fdat;
    if(keys %$fdat){
    my $t2 = Text::SimpleTable->new([20,'PARAMETER'], [$column_width - 18,'VALUE']);
        for my $key ( sort keys %$fdat) {
            my $param = $fdat->{$key};
            my $value = defined($param) ? $param : '';
            $t2->row( $key, ref $value eq 'ARRAY' ? ( join ', ', @$value ) : $value );
        }
        print color 'magenta';
        print $t2->draw;
    }

    my $col1 = int($column_width  / 3) || 10;

    my $t1 = Text::SimpleTable->new([20,'METHOD'], [20,'SEC'],[20,'SIZE']);
    my $total = pop @{$self->method_end};
    $t1->row('C::' . $total->{method},$total->{sec},total_size($c));
    $t1->hr;
    my $sec = 0;
    for(@{$self->method_end}){
        $t1->row( '-' . $_->{method},$_->{sec},total_size($self->parent));
        $sec += $_->{sec};
    }
    $t1->row( '-EXECUTE',$total->{sec} - $sec,total_size($self->parent));
    
    
    print color 'blue';
    print $t1->draw() if $LEVEL > 2;
    print color 'reset';
 }


 1;
}

1;
