From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jun 2010 14:32:06 -0000
Subject: LVM2 configure configure.in
Message-ID: <20100607143206.15575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-07 14:32:03

Modified files:
	.              : configure configure.in 

Log message:
	Fix wrong usage of exec_prefix from previous patch introducing LVM_PATH define
	
	Introduce lvm_exec_prefix with resolved exec_prefix.
	(using same ac_default_prefix as for CLVMD_PATH)
	Use lvm_exec_prefix instead of dmeventd_prefix (fixes missing ac_default_prefix)
	
	Note: This patch is rather hot-fix as currently generate code
	does not create correct code for make exec_prefix=

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/configure	2010/06/03 13:50:26	1.131
+++ LVM2/configure	2010/06/07 14:31:59	1.132
@@ -15518,8 +15518,12 @@
 fi
 
 
+lvm_exec_prefix=$exec_prefix
+test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
+test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
+
 cat >>confdefs.h <<_ACEOF
-#define LVM_PATH "$exec_prefix/sbin/lvm"
+#define LVM_PATH "$lvm_exec_prefix/sbin/lvm"
 _ACEOF
 
 
@@ -15556,13 +15560,6 @@
 
 
 if test "$BUILD_DMEVENTD" = yes; then
-        dmeventd_prefix="$exec_prefix"
-        if test "x$dmeventd_prefix" = "xNONE"; then
-                dmeventd_prefix="$prefix"
-        fi
-        if test "x$dmeventd_prefix" = "xNONE"; then
-                dmeventd_prefix=""
-        fi
 
 # Check whether --with-dmeventd-path was given.
 if test "${with_dmeventd_path+set}" = set; then
@@ -15572,7 +15569,7 @@
 
 else
    cat >>confdefs.h <<_ACEOF
-#define DMEVENTD_PATH "$dmeventd_prefix/sbin/dmeventd"
+#define DMEVENTD_PATH "$lvm_exec_prefix/sbin/dmeventd"
 _ACEOF
 
 fi
--- LVM2/configure.in	2010/06/03 13:50:26	1.142
+++ LVM2/configure.in	2010/06/07 14:32:01	1.143
@@ -1009,7 +1009,11 @@
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
 fi
 
-AC_DEFINE_UNQUOTED(LVM_PATH, ["$exec_prefix/sbin/lvm"], [Path to lvm binary.])
+
+lvm_exec_prefix=$exec_prefix
+test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
+test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
+AC_DEFINE_UNQUOTED(LVM_PATH, ["$lvm_exec_prefix/sbin/lvm"], [Path to lvm binary.])
 
 if  test "$CLVMD" != none; then
         clvmd_prefix=$ac_default_prefix
@@ -1029,17 +1033,10 @@
 
 AH_TEMPLATE(DMEVENTD_PATH, [Path to dmeventd binary.])
 if test "$BUILD_DMEVENTD" = yes; then
-        dmeventd_prefix="$exec_prefix"
-        if test "x$dmeventd_prefix" = "xNONE"; then
-                dmeventd_prefix="$prefix"
-        fi
-        if test "x$dmeventd_prefix" = "xNONE"; then
-                dmeventd_prefix=""
-        fi
 	AC_ARG_WITH(dmeventd-path,
 		    [  --with-dmeventd-path=PATH       dmeventd path [[EPREFIX/sbin/dmeventd]] ],
 		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$withval") ],
-		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$dmeventd_prefix/sbin/dmeventd") ])
+		    [ AC_DEFINE_UNQUOTED(DMEVENTD_PATH,"$lvm_exec_prefix/sbin/dmeventd") ])
 fi
 
 ################################################################################


