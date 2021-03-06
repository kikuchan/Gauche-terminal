dnl
dnl Configuring Gauche-terminal
dnl  process this file with autoconf to generate 'configure'.
dnl

AC_PREREQ(2.54)
AC_INIT(Gauche-terminal, 0.01, walter@wasao.org,
        [], http://github.com/wasao/Gauche-terminal)
AC_CONFIG_HEADERS(config.h)
dnl If you want to use the system name (OS, architecture, etc) in the
dnl configure, uncomment the following line.  In such a case, you need
dnl to copy config.guess and config.sub from automake distribution.
dnl AC_CANONICAL_SYSTEM

dnl Replace @LOCAL_PATHS@ by --with-local option.
AC_ARG_WITH(local,
  AC_HELP_STRING([--with-local=PATH:PATH...],
                 [For each PATH, add PATH/include to the include search
paths and PATH/lib to the library search paths.  Useful if you have some
libraries installed in non-standard places. ]),
  [
    case $with_local in
      yes|no|"") ;;  #no effect
      *) LOCAL_PATHS=$with_local ;;
    esac
  ])
AC_SUBST(LOCAL_PATHS)

dnl Set up gauche related commands.  The commands are set by scanning
dnl PATH.  You can override them by "GOSH=/my/gosh ./configure" etc.
dnl These variables may contain spaces in the pathnames (especially on
dnl Windows); Makefile.ins and other files that refer to those variables
dnl have to quote them properly.
AC_PATH_PROG([GOSH], gosh)
AC_PATH_PROG([GAUCHE_CONFIG], gauche-config)
AC_PATH_PROG([GAUCHE_PACKAGE], gauche-package)
AC_PATH_PROG([GAUCHE_INSTALL], gauche-install)
AC_PATH_PROG([GAUCHE_CESCONV], gauche-cesconv)

dnl Usually these parameters are set by AC_PROG_CC, but we'd rather use
dnl the same one as Gauche has been compiled with.
SOEXT=`"$GAUCHE_CONFIG" --so-suffix`
OBJEXT=`"$GAUCHE_CONFIG" --object-suffix`
EXEEXT=`"$GAUCHE_CONFIG" --executable-suffix`
AC_SUBST(SOEXT)
AC_SUBST(OBJEXT)
AC_SUBST(EXEEXT)

ac_default_prefix=`"$GAUCHE_CONFIG" --prefix`

GAUCHE_PKGINCDIR=`"$GAUCHE_CONFIG" --pkgincdir`
GAUCHE_PKGLIBDIR=`"$GAUCHE_CONFIG" --pkglibdir`
GAUCHE_PKGARCHDIR=`"$GAUCHE_CONFIG" --pkgarchdir`
GAUCHE_SYSLIBDIR=`"$GAUCHE_CONFIG" --syslibdir`
AC_SUBST(GAUCHE_PKGINCDIR)
AC_SUBST(GAUCHE_PKGLIBDIR)
AC_SUBST(GAUCHE_PKGARCHDIR)
AC_SUBST(GAUCHE_SYSLIBDIR)

dnl Creating gpd (gauche package description) file
GAUCHE_PACKAGE_CONFIGURE_ARGS="`echo ""$ac_configure_args"" | sed 's/[\\""\`\$]/\\\&/g'`"
AC_MSG_NOTICE([creating ${PACKAGE_NAME}.gpd])
"$GAUCHE_PACKAGE" make-gpd "$PACKAGE_NAME" \
  -version "$PACKAGE_VERSION" \
  -configure "./configure $GAUCHE_PACKAGE_CONFIGURE_ARGS"

dnl
dnl enable or disable tparm 
dnl
AC_ARG_ENABLE([tparm], AS_HELP_STRING([--disable-tparm],
                       [disable tparm (default enabled)]),
                       [], [enable_tparm=yes])
AS_IF([test "x$enable_tparm" != xno],
      [AC_DEFINE([ENABLE_TPARM], [1], [Enable tparm])])

dnl
dnl Check for Ncurses libraries
dnl
NCURSES_CFLAGS=""
NCURSES_LIBS="-lncurses"
AC_SUBST(NCURSES_CFLAGS)
AC_SUBST(NCURSES_LIBS)

dnl Output
echo $PACKAGE_VERSION > VERSION
AC_OUTPUT(Makefile)
