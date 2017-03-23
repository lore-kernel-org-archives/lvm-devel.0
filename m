From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 22 Mar 2017 21:03:08 -0400
Subject: master - tools: Show configuration command line in lvm version.
Message-ID: <201703230103.v2N138QU014558@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8362b4cb7fcb4575d843f5b1f6e5c8b66fa99c0
Commit:        e8362b4cb7fcb4575d843f5b1f6e5c8b66fa99c0
Parent:        b84bf3e8cd95e74bc39c7e661a6e010fdccb5078
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 23 01:00:49 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 23 01:01:35 2017 +0000

tools: Show configuration command line in lvm version.

Also update configure.in with some items recently added to the tree.
---
 WHATS_NEW              |    1 +
 configure              |   29 ++++++++++++++++++++++++++++-
 configure.in           |    6 +++++-
 include/configure.h.in |    6 ++++++
 tools/lvmcmdline.c     |    1 +
 5 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99a0bda..b06effe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add configuration command line to 'lvm version' output.
   Adjust to misordered raid parameters
   Conditionally reject raid convert to striped/raid0* after reshape
   Ensure raid6 upconversion restrictions
diff --git a/configure b/configure
index 4798d5e..c3901d4 100755
--- a/configure
+++ b/configure
@@ -3015,6 +3015,7 @@ ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 
+CONFIGURE_LINE="$0 $@"
 
 ac_config_headers="$ac_config_headers include/configure.h"
 
@@ -6078,7 +6079,7 @@ fi
 done
 
 
-for ac_header in termios.h sys/statvfs.h sys/timerfd.h linux/magic.h linux/fiemap.h
+for ac_header in termios.h sys/statvfs.h sys/timerfd.h sys/vfs.h linux/magic.h linux/fiemap.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -6271,6 +6272,26 @@ _ACEOF
 
 fi
 
+ac_fn_c_check_member "$LINENO" "struct stat" "st_blocks" "ac_cv_member_struct_stat_st_blocks" "$ac_includes_default"
+if test "x$ac_cv_member_struct_stat_st_blocks" = xyes; then :
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE_STRUCT_STAT_ST_BLOCKS 1
+_ACEOF
+
+
+$as_echo "#define HAVE_ST_BLOCKS 1" >>confdefs.h
+
+else
+  case " $LIBOBJS " in
+  *" fileblocks.$ac_objext "* ) ;;
+  *) LIBOBJS="$LIBOBJS fileblocks.$ac_objext"
+ ;;
+esac
+
+fi
+
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
 $as_echo_n "checking whether struct tm is in sys/time.h or time.h... " >&6; }
 if ${ac_cv_struct_tm+:} false; then :
@@ -15473,6 +15494,12 @@ LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
 LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[(.]' '{print $3}'`
 LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
+
+cat >>confdefs.h <<_ACEOF
+#define LVM_CONFIGURE_LINE "$CONFIGURE_LINE"
+_ACEOF
+
+
 ################################################################################
 
 
diff --git a/configure.in b/configure.in
index 9dfb836..42ec52f 100644
--- a/configure.in
+++ b/configure.in
@@ -15,6 +15,7 @@ AC_PREREQ(2.69)
 ################################################################################
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT
+CONFIGURE_LINE="$0 $@"
 AC_CONFIG_SRCDIR([lib/device/dev-cache.h])
 AC_CONFIG_HEADERS([include/configure.h])
 
@@ -105,7 +106,7 @@ AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
   sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
   unistd.h], , [AC_MSG_ERROR(bailing out)])
 
-AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h linux/magic.h linux/fiemap.h)
+AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h sys/vfs.h linux/magic.h linux/fiemap.h)
 
 case "$host_os" in
 	linux*)
@@ -120,6 +121,7 @@ AC_C_CONST
 AC_C_INLINE
 AC_CHECK_MEMBERS([struct stat.st_rdev])
 AC_CHECK_TYPES([ptrdiff_t])
+AC_STRUCT_ST_BLOCKS
 AC_STRUCT_TM
 AC_TYPE_OFF_T
 AC_TYPE_PID_T
@@ -2001,6 +2003,8 @@ LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
 LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[[(.]]' '{print $3}'`
 LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 
+AC_DEFINE_UNQUOTED(LVM_CONFIGURE_LINE, "$CONFIGURE_LINE", [configure command line used])
+
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(AWK)
diff --git a/include/configure.h.in b/include/configure.h.in
index 89a5e48..04e7f4b 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -491,6 +491,9 @@
 /* Define to 1 if you have the <sys/file.h> header file. */
 #undef HAVE_SYS_FILE_H
 
+/* Define to 1 if you have the <sys/inotify.h> header file. */
+#undef HAVE_SYS_INOTIFY_H
+
 /* Define to 1 if you have the <sys/ioctl.h> header file. */
 #undef HAVE_SYS_IOCTL_H
 
@@ -626,6 +629,9 @@
 /* Define to 1 to include code that uses lvmpolld. */
 #undef LVMPOLLD_SUPPORT
 
+/* configure command line used */
+#undef LVM_CONFIGURE_LINE
+
 /* Path to lvm binary. */
 #undef LVM_PATH
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5386bf3..f339928 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2139,6 +2139,7 @@ int version(struct cmd_context *cmd __attribute__((unused)),
 		log_print("Library version: %s", vsn);
 	if (driver_version(vsn, sizeof(vsn)))
 		log_print("Driver version:  %s", vsn);
+	log_print("Configuration:   %s", LVM_CONFIGURE_LINE);
 
 	return ECMD_PROCESSED;
 }


