# Note: this file was auto-generated by Module::Build::Compat version 0.4232
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'TMDB',
  'VERSION_FROM' => 'lib/TMDB.pm',
  'PREREQ_PM' => {
                   'Encode' => 0,
                   'HTTP::Tiny' => '0.016',
                   'IO::Socket::SSL' => '1.56',
                   'JSON::MaybeXS' => 0,
                   'Locale::Codes' => '3.20',
                   'Net::SSLeay' => '1.49',
                   'Object::Tiny' => '1.03',
                   'Params::Validate' => '1.03',
                   'Test::More' => 0,
                   'URI::Encode' => '0.05',
                   'version' => 0
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;
