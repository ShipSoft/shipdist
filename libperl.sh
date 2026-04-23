package: libperl
version: "1.0"
system_requirement_missing: "Please install libperl and perl-ExtUtils-Embed development package on your system"
system_requirement: ".*"
system_requirement_check: |
  # shellcheck disable=SC2046
  PERL_ARCHLIB=$(perl -MConfig -e 'print $Config{archlib}')
  printf "#include <EXTERN.h>\nint main(){}\n" |
    cc -xc -lperl \
      -L"$PERL_ARCHLIB/CORE" -I"$PERL_ARCHLIB/CORE" \
      - -o /dev/null &&
    perl -MExtUtils::Embed -e 1
---
