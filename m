From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 11:20:13 -0000
Subject: LVM2 ./configure lib/misc/configure.h.in
Message-ID: <20120215112013.7949.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 11:20:13

Modified files:
	.              : configure 
	lib/misc       : configure.h.in 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/configure	2012/02/13 13:02:47	1.167
+++ LVM2/configure	2012/02/15 11:20:12	1.168
@@ -796,6 +796,7 @@
 with_device_gid
 with_device_mode
 with_device_nodes_on
+with_default_name_mangling
 enable_lvm1_fallback
 with_lvm1
 with_pool
@@ -1543,6 +1544,9 @@
   --with-device-mode=MODE set the mode used for new device nodes [[MODE=0600]]
   --with-device-nodes-on=ON
                           create nodes on resume or create [[ON=resume]]
+  --with-default-name-mangling=MANGLING
+                          default name mangling: auto/none/hex
+                          [[MANGLING=auto]]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
                           [[TYPE=internal]]
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
@@ -6762,6 +6766,30 @@
 _ACEOF
 
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking default name mangling" >&5
+$as_echo_n "checking default name mangling... " >&6; }
+
+# Check whether --with-default-name-mangling was given.
+if test "${with_default_name_mangling+set}" = set; then :
+  withval=$with_default_name_mangling; MANGLING=$withval
+else
+  MANGLING=auto
+fi
+
+case "$MANGLING" in
+ auto) mangling=DM_STRING_MANGLING_AUTO;;
+ disabled) mangling=DM_STRING_MANGLING_NONE;;
+ hex) mangling=DM_STRING_MANGLING_HEX;;
+ *) as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5;;
+esac
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $MANGLING" >&5
+$as_echo "$MANGLING" >&6; }
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_DM_NAME_MANGLING $mangling
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable lvm1 fallback" >&5
 $as_echo_n "checking whether to enable lvm1 fallback... " >&6; }
--- LVM2/lib/misc/configure.h.in	2012/01/31 21:21:54	1.36
+++ LVM2/lib/misc/configure.h.in	2012/02/15 11:20:13	1.37
@@ -38,6 +38,9 @@
 /* Define default node creation behavior with dmsetup create */
 #undef DEFAULT_DM_ADD_NODE
 
+/* Define default name mangling behaviour */
+#undef DEFAULT_DM_NAME_MANGLING
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 


