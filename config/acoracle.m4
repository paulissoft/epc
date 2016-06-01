dnl $Id$
dnl
dnl acoracle.m4
dnl
dnl Author: G.J. Paulissen (g.paulissen@chello.nl)
dnl
dnl Defines the macros:
dnl  ACX_SEARCH_LIBS
dnl  ACX_PROG_PROC
dnl  ACX_PROG_SQLPLUS
dnl


# ACX_SEARCH_LIBS(ROOT-DIR, SUB-DIRS, FUNCTION, SEARCH-LIBS [, ACTION-IF-FOUND
#            [, ACTION-IF-NOT-FOUND [, OTHER-LIBRARIES]]])
# Search for a library defining FUNC, if it's not already available.
#
# Similar to AC_SEARCH_LIBS but also adds the directory name where the library
# is found to LDFLAGS.
#
# This macro has been developed because the Oracle libraries on a Windows
# platform may reside in various subdirectories. For instance the orasql9
# library may be found in $ORACLE_HOME/precomp/lib/msvc, but also in
# $ORACLE_HOME/precomp/lib. On Unix systems the library is called clntsh and
# can be found in $ORACLE_HOME/lib (or $ORACLE_HOME/lib32 for 64 bit systems like AIX).
#
# The Cygwin compiler is also able to link to DLLs on a Windows platform.
# However this will likely result in static libraries being built.
#
# The Iterix compiler (Windows Services For Unix from Microsoft) can not link
# to a .lib file via -l. In that case the full path must be added to
# LIBS before calling this macro.

AC_DEFUN([ACX_SEARCH_LIBS],
[AC_CACHE_CHECK([for directory and library containing $3], [acx_cv_search_$3],
[acx_func_search_save_LDFLAGS=$LDFLAGS
acx_func_search_save_LIBS=$LIBS
acx_cv_search_$3=no
AC_LINK_IFELSE([AC_LANG_CALL([], [$3])],
	             [acx_cv_search_$3="none required"])
if test "$acx_cv_search_$3" = no; then
  for acx_subdir in $2; do
    acx_dir="$1/$acx_subdir"
    test -d $acx_dir || continue
    # is "-L$acx_dir" already part of $LDFLAGS?
    if ! echo "$acx_func_search_save_LDFLAGS" | grep "\\-L${acx_dir}" 1>/dev/null; then
      LDFLAGS="-L${acx_dir} $acx_func_search_save_LDFLAGS"
    fi
    for acx_lib in $4; do
      # is "-l$acx_lib $7" already part of $LIBS?
      if ! echo "$acx_func_search_save_LIBS" | grep "\\-l$acx_lib $7" 1>/dev/null; then
        LIBS="-l$acx_lib $7 $acx_func_search_save_LIBS"
      fi
      AC_LINK_IFELSE([AC_LANG_CALL([], [$3])],
                     [acx_cv_search_$3="-L$acx_dir -l$acx_lib $7" && break])
    done
    test "$acx_cv_search_$3" = "no" || break
  done
fi
LDFLAGS=$acx_func_search_save_LDFLAGS
LIBS=$acx_func_search_save_LIBS])
AS_IF([test "$acx_cv_search_$3" != no],
      [if test "$acx_cv_search_$3" != "none required"
then 
  acx_LDFLAGS=`eval echo \$acx_cv_search_$3 | cut -d' ' -f 1`
  acx_LIBS="`eval echo \$acx_cv_search_$3 | cut -d' ' -f 2` $7"
  # is "-L$acx_dir" already part of $LDFLAGS?
  if ! echo "$LDFLAGS" | grep "\\$acx_LDFLAGS" 1>/dev/null; then
    LDFLAGS="$acx_LDFLAGS $LDFLAGS"
  fi
  # is "-l$acx_lib $7" already part of $LIBS?
  if ! echo "$LIBS" | grep "\\$acx_LIBS" 1>/dev/null; then
    LIBS="$acx_LIBS $LIBS"
  fi
fi
       $5],
      [$6])dnl
])

# ACX_PROG_PROC
# -------------
# Look for the Oracle PRO*C compiler. 
# Sets/updates the following variables:
# - PROC          the full path name of the PRO*C compiler
# - PROCFLAGS     PRO*C compiler flags.
#                 The -D.. flags of CPPFLAGS are converted into define=..
# - PROCINCLUDES  PRO*C compiler includes including directory
#                 of the PRO*C prototype header.
#                 The -I flags of CPPFLAGS are converted into include=..

AC_DEFUN([ACX_PROG_PROC],
[AC_PATH_PROG([PROC], [proc], [AC_MSG_ERROR(proc not found)], ["$ORACLE_HOME/bin:$PATH"])dnl

acx_oracle_home="$ORACLE_HOME"
acx_proc_home=`dirname $PROC`
acx_proc_home=`dirname $acx_proc_home`
if test -z "$acx_oracle_home"
then
  acx_oracle_home=$acx_proc_home
	acx_oracle_homes=$acx_proc_home
else
  acx_oracle_homes="acx_oracle_home $acx_proc_home"
fi

ACX_SEARCH_LIBS([$acx_oracle_home],
                [. lib32 lib precomp precomp/lib precomp/lib/msvc bin],
                [sqlglm],
                [clntsh orasql12 orasql11 orasql10 orasql9 orasql8 orasql7],
		[],
                [AC_MSG_ERROR(sqlglm not found)])
ACX_SEARCH_LIBS([$acx_oracle_home],
                [. lib32 lib precomp precomp/lib precomp/lib/msvc bin],
                [osnsui],
                [clntsh oraociei12 oran12 n12 oraociei11 oran11 n11 oran10 n10 oran9 n9 oran8 n8 oran7 n7],
		[],
		[AC_MSG_ERROR(osnsui not found)])

acx_protohdrs="sqlcpr.h sqlproto.h"
acx_protohdr=
for dir in $acx_oracle_homes
do
  test -d $dir || continue
  for file in $acx_protohdrs 
  do
    # Windows: ignore case
    # Bug 849475: just return one header by using head -1
    acx_protohdr=`find $dir \( -name \*.h -o -name \*.H \) | grep -i $file | head -1 2>/dev/null`

    test -n "$acx_protohdr" || continue

    AC_MSG_CHECKING([$acx_protohdr])

    # sqlcpr.h.bak is not right, but SQLCPR.H is (at least on Windows)
    if test `basename "$acx_protohdr" | tr 'A-Z' 'a-z'` = "$file"
    then
      CPPFLAGS="-I`dirname $acx_protohdr` $CPPFLAGS"
      AC_MSG_RESULT([yes])
      break
    else
      acx_protohdr=
      AC_MSG_RESULT([no])
      continue
    fi
  done
  # One is enough
  test -z "$acx_protohdr" || break
done

AC_CHECK_HEADERS([$acx_protohdrs], [break], [AC_MSG_ERROR(PRO*C prototype header not found)])

PROCINCLUDES='`echo " $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)" | sed "s/ -I/ INCLUDE=/g;s/ -[[^ \t]]*//g"`'
PROCFLAGS='`echo " $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)" | sed "s/ -D/ DEFINE=/g;s/ -[[^ \t]]*//g"`'

AC_SUBST(PROCINCLUDES)
PROCFLAGS="$PROCFLAGS CODE=ANSI_C PARSE=NONE SQLCHECK=FULL USERID=\$(USERID)"
AC_SUBST(PROCFLAGS)
])


# ACX_PROG_SQLPLUS
# ----------------
# Look for the Oracle SQL*Plus program in directory of PRO*C, ORACLE_HOME/bin or PATH.
# Sets/updates the following variables:
# - SQLPLUS       the full path name of the SQL*Plus program.

AC_DEFUN([ACX_PROG_SQLPLUS],
[AC_ARG_VAR([SQLPLUS], [Oracle SQL*Plus program])dnl

if test -n "${PROC:=}"
then
  acx_path="`dirname $PROC`:$PATH"
elif test -n "${ORACLE_HOME:=}"
then
  acx_path="$ORACLE_HOME/bin:$PATH"
else
  acx_path="$PATH"
fi

AC_PATH_PROGS([SQLPLUS], [plus80 plus33 plus32 plus31 sqlplus], [], [$acx_path])
test -n "$SQLPLUS" || AC_MSG_ERROR(sqlplus not found)
])


# ACX_PROG_XML
# -------------
# Look for the Oracle XML library and header.
# Sets/updates the following variables:
# - LIBS          extended with the XML library
# - CPPFLAGS      extended with the XML header

AC_DEFUN([ACX_PROG_XML],
[
acx_oracle_home="$ORACLE_HOME"
if test -z "$acx_oracle_home"
then
  acx_oracle_home=`dirname $PROC`
  acx_oracle_home=`dirname $acx_oracle_home`
fi

ACX_SEARCH_LIBS([$acx_oracle_home],
                [lib32 lib bin],
                [xmlinit],
                [nmemso xml11 xml10 oraxml11 oraxml10 oraxml9 oraxml8],
								[],
								[AC_MSG_ERROR(xmlinit not found)])

acx_xmlhdrs="oraxml.h oratypes.h"
AC_MSG_NOTICE([Checking headers for XML C SDK: $acx_xmlhdrs])
for acx_file in $acx_xmlhdrs
do
	# Windows: ignore case
	if printenv WINDIR 1>/dev/null
	then
	  acx_file_upper=`echo $acx_file | tr 'a-z'	'A-Z'`
	else
	  acx_file_upper=$acx_file
	fi

  for acx_dir in $acx_oracle_home/xdk/include $acx_oracle_home/xdk/c/parser/include $acx_oracle_home `find $acx_oracle_home -name include -type d 2>/dev/null`
  do
    # Must be a directory and we must be able to change to the directory
    test -d $acx_dir -a -x $acx_dir || continue

    AC_MSG_CHECKING([$acx_file in $acx_dir])

		if test -f "$acx_dir/$acx_file"
		then
			acx_xmlhdr="$acx_dir/$acx_file"
		elif test -f "$acx_dir/$acx_file_upper"
		then
			acx_xmlhdr="$acx_dir/$acx_file_upper"
		else
		  acx_xmlhdr=
	  fi

    if test -n "$acx_xmlhdr"
    then
      if ! echo "$CPPFLAGS" | grep "\\-I${acx_dir}" 1>/dev/null; then
        CPPFLAGS="-I${acx_dir} $CPPFLAGS"
			fi
			AC_MSG_RESULT([yes])
      break
    else
			AC_MSG_RESULT([no])
      continue
    fi
  done
done

# to prevent: fatal error: orastruc.h: No such file or directory
CPPFLAGS="-DORASTRUC $CPPFLAGS"
for acx_var in CPPFLAGS LDFLAGS LIBS
do
  AC_MSG_NOTICE([environment variable $acx_var])
	export $acx_var
  env | grep $acx_var
done

# Do not check Oracle headers because it gives too many errors
# AC_CHECK_HEADERS([$acx_xmlhdrs], [], [AC_MSG_ERROR(Header file(s) $acx_xmlhdrs could not be processed)])
])

# ACX_PROG_OCI
# -------------
# Look for the Oracle OCI header.
# Sets/updates the following variables:
# - CPPFLAGS      extended with the OCI header

AC_DEFUN([ACX_PROG_OCI],
[
acx_oracle_home="$ORACLE_HOME"
if test -z "$acx_oracle_home"
then
  acx_oracle_home=`dirname $PROC`
  acx_oracle_home=`dirname $acx_oracle_home`
fi

acx_ocihdrs="oci.h"
acx_ocihdr=
for dir in $acx_oracle_home/rdbms/public `find $acx_oracle_home -name include -type d 2>/dev/null` $acx_oracle_home
do
  # Must be a directory and we must be able to change to the directory
  test -d $dir -a -x $dir || continue
  for file in $acx_ocihdrs
  do
    # Windows: ignore case
    # Bug 849475: just return one header by using head -1
    acx_ocihdr=`find $dir \( -name \*.h -o -name \*.H \) | grep -i $file | head -1 2>/dev/null`

    test -n "$acx_ocihdr" || continue

    AC_MSG_CHECKING([$acx_ocihdr])

    # oraoci.h.bak is not right, but ORAOCI.H is (at least on Windows)
    if test `basename "$acx_ocihdr" | tr 'A-Z' 'a-z'` = "$file"
    then
      CPPFLAGS="-I`dirname $acx_ocihdr` $CPPFLAGS"
      AC_MSG_RESULT([yes])
      break
    else
      acx_ocihdr=
      AC_MSG_RESULT([no])
      continue
    fi
  done
  test -z "$acx_ocihdr" || break
done

AC_CHECK_HEADERS([$acx_ocihdrs], [continue], [AC_MSG_ERROR(OCI header(s) $acx_ocihdrs not found)])
])

dnl $Id$
