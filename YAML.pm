package Maypole::Plugin::Config::YAML;

use strict;
use IO::File;
use Carp;
use YAML;
use NEXT;

our $VERSION = '0.04';

=head1 NAME

Maypole::Plugin::Config::YAML - Simple YAML style config for Maypole

=head1 SYNOPSIS

Inline config:

    # MyApp.pm
    package MyApp;

    use strict;
    use Maypole::Application qw(Config::YAML -Setup);

    1;
    __DATA__
    --- #YAML:1.0
    dsn: 'dbi:Pg:dbname=myapp'
    user: myuser
    pass: mypass
    uri_base: 'http://127.0.0.1/myapp'
    template_root: '/home/sri/myapp/templates'
    rows_per_page: 10

Separate config file:

    # MyApp.pm
    package MyApp;

    use strict;
    use Maypole::Application qw(Config::YAML -Setup);

    1;

    # $ENV{MAYPOLE_CONFIG} = '/etc/myapp.yaml';
    --- #YAML:1.0
    dsn: 'dbi:Pg:dbname=myapp'
    user: myuser
    pass: mypass
    uri_base: 'http://127.0.0.1/myapp'
    template_root: '/home/sri/myapp/templates'
    rows_per_page: 10

Advanced example:

    # MyApp.pm
    package MyApp;

    use strict;
    use Maypole::Application qw(Config::YAML Authentication::Abstract -Setup);

    sub authenticate {
        my ($self, $r) = @_;
        $r->public;
        if ($r->{action} eq 'edit') {
            $r->private;
            $r->{template} = 'login' unless $r->{user};
        }
    }

    1;

    # $ENV{MAYPOLE_CONFIG} = '/etc/myapp.yaml';
    --- #YAML:1.0
    dsn: 'dbi:Pg:dbname=myapp'
    user: myuser
    pass: mypass
    uri_base: 'http://127.0.0.1/myapp'
    template_root: '/home/sri/myapp/templates'
    rows_per_page: 10
    auth:
      user_class: MyApp::Customer
      session_class: Apache::Session::Postgres
      session_args:
        DataSource: 'dbi:Pg:dbname=myapp'
        UserName: myuser
        Password: mypass
        TableName: session
        Commit: 1

=head1 DESCRIPTION

You can use the $MAYPOLE_CONFIG environment variable to tell it where to
find a YAML file or put your YAML in the DATA section.

Note that you need Maypole 2.0 or newer to use this module!

=cut

sub setup {
    my $r = shift;
    local $/;
    my $conf;
    if ( $ENV{MAYPOLE_CONFIG} ) {
        my $file = IO::File->new("< $ENV{MAYPOLE_CONFIG}")
          or croak "Unable to open config file $ENV{MAYPOLE_CONFIG}";
        $conf = Load do { <$file> };
    }
    else { $conf = Load eval "package $r; <DATA>" }
    Maypole::Config->mk_accessors( keys %$conf );
    $r->config( Maypole::Config->new($conf) );
    $r->NEXT::DISTINCT::setup(@_);
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
