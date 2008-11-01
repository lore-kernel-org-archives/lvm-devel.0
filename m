From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2008 02:20:08 -0000
Subject: LVM2 configure
Message-ID: <20081101022008.16760.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-01 02:20:07

Modified files:
	.              : configure 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/configure	2008/10/31 22:34:42	1.81
+++ LVM2/configure	2008/11/01 02:20:06	1.82
@@ -1346,6 +1346,8 @@
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
   --with-user=USER        Set the owner of installed files [USER=root]
   --with-group=GROUP      Set the group owner of installed files [GROUP=root]
+  --with-device-uid=UID   Set the owner used for new device nodes [UID=0]
+  --with-device-gid=UID   Set the group used for new device nodes [GID=0]
   --with-device-mode=MODE Set the mode used for new device nodes [MODE=0600]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
                           TYPE=internal
@@ -8433,6 +8435,36 @@
 fi
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking device node uid" >&5
+echo $ECHO_N "checking device node uid... $ECHO_C" >&6; }
+
+
+# Check whether --with-device-uid was given.
+if test "${with_device_uid+set}" = set; then
+  withval=$with_device_uid;  DM_DEVICE_UID="$withval"
+else
+   DM_DEVICE_UID="0"
+fi
+
+{ echo "$as_me:$LINENO: result: $DM_DEVICE_UID" >&5
+echo "${ECHO_T}$DM_DEVICE_UID" >&6; }
+
+################################################################################
+{ echo "$as_me:$LINENO: checking device node gid" >&5
+echo $ECHO_N "checking device node gid... $ECHO_C" >&6; }
+
+
+# Check whether --with-device-gid was given.
+if test "${with_device_gid+set}" = set; then
+  withval=$with_device_gid;  DM_DEVICE_GID="$withval"
+else
+   DM_DEVICE_GID="0"
+fi
+
+{ echo "$as_me:$LINENO: result: $DM_DEVICE_GID" >&5
+echo "${ECHO_T}$DM_DEVICE_GID" >&6; }
+
+################################################################################
 { echo "$as_me:$LINENO: checking device node mode" >&5
 echo $ECHO_N "checking device node mode... $ECHO_C" >&6; }
 
@@ -11766,6 +11798,12 @@
 
 ################################################################################
 DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
+
+cat >>confdefs.h <<_ACEOF
+#define DM_LIB_VERSION $DM_LIB_VERSION
+_ACEOF
+
+
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################


