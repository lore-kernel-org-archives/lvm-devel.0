From: meyering@sourceware.org <meyering@sourceware.org>
Date: 23 Jun 2008 09:25:58 -0000
Subject: LVM2 configure
Message-ID: <20080623092558.8238.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-23 09:25:57

Modified files:
	.              : configure 

Log message:
	configure: regenerate

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/configure	2008/06/13 14:37:15	1.69
+++ LVM2/configure	2008/06/23 09:25:57	1.70
@@ -685,6 +685,7 @@
 ALLOCA
 LIBOBJS
 POW_LIB
+LVM2CMD_LIB
 MSGFMT
 MODPROBE_CMD
 BUILD_DMEVENTD
@@ -8469,14 +8470,6 @@
 { echo "$as_me:$LINENO: result: $READLINE" >&5
 echo "${ECHO_T}$READLINE" >&6; }
 
-if test x$READLINE = xyes; then
-
-cat >>confdefs.h <<\_ACEOF
-#define READLINE_SUPPORT 1
-_ACEOF
-
-fi
-
 ################################################################################
 { echo "$as_me:$LINENO: checking whether to enable realtime support" >&5
 echo $ECHO_N "checking whether to enable realtime support... $ECHO_C" >&6; }
@@ -8591,6 +8584,10 @@
 { echo "$as_me:$LINENO: result: $CMDLIB" >&5
 echo "${ECHO_T}$CMDLIB" >&6; }
 
+test $CMDLIB=yes \
+  && LVM2CMD_LIB=-llvm2cmd \
+  || LVM2CMD_LIB=
+
 ################################################################################
 { echo "$as_me:$LINENO: checking whether to install fsadm" >&5
 echo $ECHO_N "checking whether to install fsadm... $ECHO_C" >&6; }
@@ -9517,6 +9514,11 @@
 
 fi
 
+
+cat >>confdefs.h <<\_ACEOF
+#define READLINE_SUPPORT 1
+_ACEOF
+
 fi
 
 ################################################################################
@@ -12001,6 +12003,7 @@
 ALLOCA!$ALLOCA$ac_delim
 LIBOBJS!$LIBOBJS$ac_delim
 POW_LIB!$POW_LIB$ac_delim
+LVM2CMD_LIB!$LVM2CMD_LIB$ac_delim
 MSGFMT!$MSGFMT$ac_delim
 MODPROBE_CMD!$MODPROBE_CMD$ac_delim
 BUILD_DMEVENTD!$BUILD_DMEVENTD$ac_delim
@@ -12026,7 +12029,6 @@
 HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
 HAVE_SELINUX!$HAVE_SELINUX$ac_delim
-INTL!$INTL$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12068,6 +12070,7 @@
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
+INTL!$INTL$ac_delim
 INTL_PACKAGE!$INTL_PACKAGE$ac_delim
 JOBS!$JOBS$ac_delim
 LDDEPS!$LDDEPS$ac_delim
@@ -12088,7 +12091,7 @@
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 18; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 19; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5


