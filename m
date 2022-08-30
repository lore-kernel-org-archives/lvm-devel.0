From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Aug 2022 11:57:42 +0000 (GMT)
Subject: main - configure: remove some obsolete or duplicate checks
Message-ID: <20220830115742.496E1385C335@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5aa8683e8693f405d560b93a1bd8de809dc985ef
Commit:        5aa8683e8693f405d560b93a1bd8de809dc985ef
Parent:        bda93ed4bcdc1bf7493298f6c90076cc3a033223
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 30 13:36:52 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 30 13:54:19 2022 +0200

configure: remove some obsolete or duplicate checks

As autoupdate suggested, drop unneeded checks.
---
 configure              | 166 +------------------------------------------------
 configure.ac           |  10 +--
 include/configure.h.in |   7 ---
 3 files changed, 5 insertions(+), 178 deletions(-)

diff --git a/configure b/configure
index aa3b83fcb..2dbcf1c40 100755
--- a/configure
+++ b/configure
@@ -3417,10 +3417,10 @@ as_fn_append ac_header_c_list " strings.h strings_h HAVE_STRINGS_H"
 as_fn_append ac_header_c_list " sys/stat.h sys_stat_h HAVE_SYS_STAT_H"
 as_fn_append ac_header_c_list " sys/types.h sys_types_h HAVE_SYS_TYPES_H"
 as_fn_append ac_header_c_list " unistd.h unistd_h HAVE_UNISTD_H"
-as_fn_append ac_header_c_list " sys/time.h sys_time_h HAVE_SYS_TIME_H"
 as_fn_append ac_header_c_list " vfork.h vfork_h HAVE_VFORK_H"
 as_fn_append ac_func_c_list " fork HAVE_FORK"
 as_fn_append ac_func_c_list " vfork HAVE_VFORK"
+as_fn_append ac_header_c_list " sys/time.h sys_time_h HAVE_SYS_TIME_H"
 as_fn_append ac_func_c_list " alarm HAVE_ALARM"
 as_fn_append ac_header_c_list " sys/param.h sys_param_h HAVE_SYS_PARAM_H"
 as_fn_append ac_func_c_list " getpagesize HAVE_GETPAGESIZE"
@@ -6872,136 +6872,6 @@ printf "%s\n" "#define HAVE_STDBOOL_H 1" >>confdefs.h
 
 fi
 
-# Autoupdate added the next two lines to ensure that your configure
-# script's behavior did not change.  They are probably safe to remove.
-
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for egrep" >&5
-printf %s "checking for egrep... " >&6; }
-if test ${ac_cv_path_EGREP+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  if echo a | $GREP -E '(a|b)' >/dev/null 2>&1
-   then ac_cv_path_EGREP="$GREP -E"
-   else
-     if test -z "$EGREP"; then
-  ac_path_EGREP_found=false
-  # Loop through the user's path and test for each of PROGNAME-LIST
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH$PATH_SEPARATOR/usr/xpg4/bin
-do
-  IFS=$as_save_IFS
-  case $as_dir in #(((
-    '') as_dir=./ ;;
-    */) ;;
-    *) as_dir=$as_dir/ ;;
-  esac
-    for ac_prog in egrep
-   do
-    for ac_exec_ext in '' $ac_executable_extensions; do
-      ac_path_EGREP="$as_dir$ac_prog$ac_exec_ext"
-      as_fn_executable_p "$ac_path_EGREP" || continue
-# Check for GNU ac_path_EGREP and select it if it is found.
-  # Check for GNU $ac_path_EGREP
-case `"$ac_path_EGREP" --version 2>&1` in
-*GNU*)
-  ac_cv_path_EGREP="$ac_path_EGREP" ac_path_EGREP_found=:;;
-*)
-  ac_count=0
-  printf %s 0123456789 >"conftest.in"
-  while :
-  do
-    cat "conftest.in" "conftest.in" >"conftest.tmp"
-    mv "conftest.tmp" "conftest.in"
-    cp "conftest.in" "conftest.nl"
-    printf "%s\n" 'EGREP' >> "conftest.nl"
-    "$ac_path_EGREP" 'EGREP$' < "conftest.nl" >"conftest.out" 2>/dev/null || break
-    diff "conftest.out" "conftest.nl" >/dev/null 2>&1 || break
-    as_fn_arith $ac_count + 1 && ac_count=$as_val
-    if test $ac_count -gt ${ac_path_EGREP_max-0}; then
-      # Best one so far, save it but keep looking for a better one
-      ac_cv_path_EGREP="$ac_path_EGREP"
-      ac_path_EGREP_max=$ac_count
-    fi
-    # 10*(2^10) chars as input seems more than enough
-    test $ac_count -gt 10 && break
-  done
-  rm -f conftest.in conftest.tmp conftest.nl conftest.out;;
-esac
-
-      $ac_path_EGREP_found && break 3
-    done
-  done
-  done
-IFS=$as_save_IFS
-  if test -z "$ac_cv_path_EGREP"; then
-    as_fn_error $? "no acceptable egrep could be found in $PATH$PATH_SEPARATOR/usr/xpg4/bin" "$LINENO" 5
-  fi
-else
-  ac_cv_path_EGREP=$EGREP
-fi
-
-   fi
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_path_EGREP" >&5
-printf "%s\n" "$ac_cv_path_EGREP" >&6; }
- EGREP="$ac_cv_path_EGREP"
-
-
-
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sys/wait.h that is POSIX.1 compatible" >&5
-printf %s "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
-if test ${ac_cv_header_sys_wait_h+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <sys/wait.h>
-#ifndef WEXITSTATUS
-# define WEXITSTATUS(stat_val) ((unsigned int) (stat_val) >> 8)
-#endif
-#ifndef WIFEXITED
-# define WIFEXITED(stat_val) (((stat_val) & 255) == 0)
-#endif
-
-int
-main (void)
-{
-  int s;
-  wait (&s);
-  s = WIFEXITED (s) ? WEXITSTATUS (s) : 1;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  ac_cv_header_sys_wait_h=yes
-else $as_nop
-  ac_cv_header_sys_wait_h=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_sys_wait_h" >&5
-printf "%s\n" "$ac_cv_header_sys_wait_h" >&6; }
-if test $ac_cv_header_sys_wait_h = yes; then
-
-printf "%s\n" "#define HAVE_SYS_WAIT_H 1" >>confdefs.h
-
-fi
-
-
-
-# Obsolete code to be removed.
-if test $ac_cv_header_sys_time_h = yes; then
-
-printf "%s\n" "#define TIME_WITH_SYS_TIME 1" >>confdefs.h
-
-fi
-# End of obsolete code.
-
 
        for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h unistd.h
 do :
@@ -7352,39 +7222,6 @@ printf "%s\n" "#define pid_t $ac_pid_type" >>confdefs.h
 fi
 
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking return type of signal handlers" >&5
-printf %s "checking return type of signal handlers... " >&6; }
-if test ${ac_cv_type_signal+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <signal.h>
-
-int
-main (void)
-{
-return *(signal (0, 0)) (0) == 1;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  ac_cv_type_signal=int
-else $as_nop
-  ac_cv_type_signal=void
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_type_signal" >&5
-printf "%s\n" "$ac_cv_type_signal" >&6; }
-
-printf "%s\n" "#define RETSIGTYPE $ac_cv_type_signal" >>confdefs.h
-
-
 ac_fn_c_check_type "$LINENO" "size_t" "ac_cv_type_size_t" "$ac_includes_default"
 if test "x$ac_cv_type_size_t" = xyes
 then :
@@ -8439,6 +8276,7 @@ esac
 
 
 
+
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working mktime" >&5
 printf %s "checking for working mktime... " >&6; }
 if test ${ac_cv_func_working_mktime+y}
diff --git a/configure.ac b/configure.ac
index 3148370ad..39bbc4fef 100644
--- a/configure.ac
+++ b/configure.ac
@@ -95,9 +95,6 @@ dnl -- Check for header files.
 AC_HEADER_DIRENT
 AC_HEADER_MAJOR
 AC_HEADER_STDBOOL
-AC_HEADER_STDC
-AC_HEADER_SYS_WAIT
-AC_HEADER_TIME
 
 AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
   getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
@@ -125,7 +122,6 @@ AC_STRUCT_ST_BLOCKS
 AC_STRUCT_TM
 AC_TYPE_OFF_T
 AC_TYPE_PID_T
-AC_TYPE_SIGNAL
 AC_TYPE_SIZE_T
 AC_TYPE_MODE_T
 AC_TYPE_INT8_T
@@ -1139,7 +1135,7 @@ AC_CHECK_HEADER([systemd/sd-id128.h],
 		[APP_MACHINEID_SUPPORT=no])
 AC_MSG_CHECKING(whether to support systemd appmachineid)
 AC_ARG_ENABLE(app-machineid,
-	      AC_HELP_STRING([--disable-app-machineid],
+	      AS_HELP_STRING([--disable-app-machineid],
 			     [disable LVM system ID using app-specific machine-id]),
 	      AS_IF([test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no],
 		    AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h and systemd >= 234.]))
@@ -1323,8 +1319,8 @@ if test "$BUILD_LVMDBUSD" = yes; then
 	test "$PYTHON3_BINDINGS" = yes && PYTHON_BINDINGS=yes
 
 	# To get this macro, install autoconf-archive package then run autoreconf
-	AC_PYTHON_MODULE([pyudev], [Required], python3)
-	AC_PYTHON_MODULE([dbus], [Required], python3)
+	AX_PYTHON_MODULE([pyudev], [Required], python3)
+	AX_PYTHON_MODULE([dbus], [Required], python3)
 fi
 
 ################################################################################
diff --git a/include/configure.h.in b/include/configure.h.in
index 63c296550..230658f7b 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -642,9 +642,6 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
-/* Define as the return type of signal handlers (`int' or `void'). */
-#undef RETSIGTYPE
-
 /* Define to 1 to include built-in support for snapshots. */
 #undef SNAPSHOT_INTERNAL
 
@@ -689,10 +686,6 @@
 /* The path to 'thin_restore', if available. */
 #undef THIN_RESTORE_CMD
 
-/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. This
-   macro is obsolete. */
-#undef TIME_WITH_SYS_TIME
-
 /* Define to 1 if your <sys/time.h> declares `struct tm'. */
 #undef TM_IN_SYS_TIME
 

