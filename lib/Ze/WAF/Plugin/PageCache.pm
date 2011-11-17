package Ze::WAF::Plugin::PageCache;
use Ze::Role;
use Ze::Util;

has '__PageCache_cache_obj' => ( is => 'rw' , required => 1 );

before 'PREPARE' => sub {
        my( $c ) = @_;
        return unless  $c->req->method eq 'GET';

        my $page_cache = $c->args->{page_cache} or return;

        my $cache = $c->__PageCache_cache_obj();

        my $key = $c->PageCache_get_key($page_cache);
        if(my $page = $cache->get($key)){
            $c->res->body( $page->{body} );
            my $header = $page->{header};
            my$content_type = $header->{content_type} || 'text/html; charset=utf-8';
            $c->res->content_type($content_type);
            $c->finished(1);
            $c->abort();
        }
};

after 'RENDER' => sub {
        my $c = shift;
        return unless  $c->req->method eq 'GET';
        return unless $c->res->code eq 200;

        my $page_cache = $c->args->{page_cache} or return;
        my $cache = $c->__PageCache_cache_obj;
        my $key = $c->PageCache_get_key($page_cache);
        my $expire = $page_cache->{expire} || 60 * 1;
        my $body = $c->res->body();#Encode::encode( 'utf-8',$c->res->body());
        my $header = { content_type => $c->res->header('Content-Type') || '' };

        $cache->set( $key , { body => $body ,header => $header }  , $expire );

};

sub PageCache_get_key {
    my $c = shift;
    my $config = shift;
    my $params = $c->req->as_fdat;
    my $query_keys = $config->{query_keys} || [];
    my $query_hash = {};
    for(@$query_keys){
        $query_hash->{$_} = $params->{$_};
    }
    my $key = join(':','cp', $c->req->path_info , Ze::Util::data2key($query_hash) );

    return $key;

}


1;
