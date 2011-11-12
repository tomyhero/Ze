package TestApp::WAF::Context;
use Ze::Class;
extends 'Ze::WAF::Context';

__PACKAGE__->load_plugins('Ze::WAF::Plugin::Encode');

__PACKAGE__->context_config({
        'Plugin::Encode' => {
            output_encoding => 'utf-8',
            input_encoding => 'utf-8',
        }
});


EOC;
