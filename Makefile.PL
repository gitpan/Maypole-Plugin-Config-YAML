use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Maypole::Plugin::Config::YAML',
    AUTHOR       => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM    => { Maypole => '2.0', YAML => 0 },
    VERSION_FROM => 'YAML.pm'
);
