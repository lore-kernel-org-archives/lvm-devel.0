From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 22:17:57 -0000
Subject: LVM2 ./configure ./configure.in lib/misc/confi ...
Message-ID: <20110204221757.25399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 22:17:55

Modified files:
	.              : configure configure.in 
	lib/misc       : configure.h.in 
	tools          : dmsetup.c 

Log message:
	Add configure option --with-device-nodes-on
	
	Make configurable default behaviour how to deal with device node creates.
	With udev system natural options should be  'resume'.
	For older systems where user expect there is node in /dev/mapper immediately
	after  dmsetup create --notable  -  use 'create'
	
	FIXME:
	Code needs fixing passing this flag through udev cookie.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/configure	2011/01/10 14:28:18	1.145
+++ LVM2/configure	2011/02/04 22:17:54	1.146
@@ -788,6 +788,7 @@
 with_device_uid
 with_device_gid
 with_device_mode
+with_device_nodes_on
 enable_lvm1_fallback
 with_lvm1
 with_pool
@@ -1526,6 +1527,8 @@
   --with-device-uid=UID   set the owner used for new device nodes [[UID=0]]
   --with-device-gid=GID   set the group used for new device nodes [[GID=0]]
   --with-device-mode=MODE set the mode used for new device nodes [[MODE=0600]]
+  --with-device-nodes-on=ON
+                          create nodes on resume or create [[ON=resume]]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
                           [[TYPE=internal]]
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
@@ -6711,6 +6714,29 @@
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DM_DEVICE_MODE" >&5
 $as_echo "$DM_DEVICE_MODE" >&6; }
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking when to create device nodes" >&5
+$as_echo_n "checking when to create device nodes... " >&6; }
+
+# Check whether --with-device-nodes-on was given.
+if test "${with_device_nodes_on+set}" = set; then :
+  withval=$with_device_nodes_on; ADD_NODE=$withval
+else
+  ADD_NODE=resume
+fi
+
+case "$ADD_NODE" in
+ resume) add_on=DM_ADD_NODE_ON_RESUME;;
+ create) add_on=DM_ADD_NODE_ON_CREATE;;
+ *) as_fn_error $? "--with-device-nodes-on parameter invalid" "$LINENO" 5;;
+esac
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: on $ADD_NODE" >&5
+$as_echo "on $ADD_NODE" >&6; }
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_DM_ADD_NODE $add_on
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable lvm1 fallback" >&5
 $as_echo_n "checking whether to enable lvm1 fallback... " >&6; }
--- LVM2/configure.in	2011/01/10 13:00:53	1.159
+++ LVM2/configure.in	2011/02/04 22:17:54	1.160
@@ -213,6 +213,19 @@
 	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
 AC_MSG_RESULT($DM_DEVICE_MODE)
 
+AC_MSG_CHECKING(when to create device nodes)
+AC_ARG_WITH(device-nodes-on,
+	    AC_HELP_STRING([--with-device-nodes-on=ON],
+			   [create nodes on resume or create [[ON=resume]]]),
+	    ADD_NODE=$withval, ADD_NODE=resume)
+case "$ADD_NODE" in
+ resume) add_on=DM_ADD_NODE_ON_RESUME;;
+ create) add_on=DM_ADD_NODE_ON_CREATE;;
+ *) AC_MSG_ERROR([--with-device-nodes-on parameter invalid]);;
+esac
+AC_MSG_RESULT(on $ADD_NODE)
+AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
+
 ################################################################################
 dnl -- LVM1 tool fallback option
 AC_MSG_CHECKING(whether to enable lvm1 fallback)
--- LVM2/lib/misc/configure.h.in	2011/01/07 14:38:35	1.31
+++ LVM2/lib/misc/configure.h.in	2011/02/04 22:17:55	1.32
@@ -35,6 +35,9 @@
 /* Default data alignment. */
 #undef DEFAULT_DATA_ALIGNMENT
 
+/* Define default node creation behavior with dmsetup create */
+#undef DEFAULT_DM_ADD_NODE
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
--- LVM2/tools/dmsetup.c	2011/02/04 19:33:54	1.152
+++ LVM2/tools/dmsetup.c	2011/02/04 22:17:55	1.153
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2005-2007 NEC Corporation
  *
  * This file is part of the device-mapper userspace tools.
@@ -507,6 +507,22 @@
 	return 1;
 }
 
+static int _set_task_add_node(struct dm_task *dmt)
+{
+	if (!dm_task_set_add_node(dmt, DEFAULT_DM_ADD_NODE))
+		return 0;
+
+	if (_switches[ADD_NODE_ON_RESUME_ARG] &&
+	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_RESUME))
+		return 0;
+
+	if (_switches[ADD_NODE_ON_CREATE_ARG] &&
+	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_CREATE))
+		return 0;
+
+	return 1;
+}
+
 static int _load(int argc, char **argv, void *data __attribute__((unused)))
 {
 	int r = 0;
@@ -626,13 +642,9 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
-	if (_switches[ADD_NODE_ON_RESUME_ARG] &&
-	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_RESUME))
-		goto out;
 
-	if (_switches[ADD_NODE_ON_CREATE_ARG] &&
-	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_CREATE))
-		goto out;
+	if (!_set_task_add_node(dmt))
+                goto out;
 
 	if (_udev_cookie) {
 		cookie = _udev_cookie;
@@ -1206,6 +1218,10 @@
 	if (_switches[NOLOCKFS_ARG] && !dm_task_skip_lockfs(dmt))
 		goto out;
 
+	/* FIXME: needs to coperate with udev */
+	if (!_set_task_add_node(dmt))
+                goto out;
+
 	if (_switches[READAHEAD_ARG] &&
 	    !dm_task_set_read_ahead(dmt, _int_args[READAHEAD_ARG],
 				    _read_ahead_flags))
@@ -2709,7 +2725,7 @@
 	{"remove", "[-f|--force] <device>", 0, 1, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, _remove_all},
 	{"suspend", "[--noflush] <device>", 0, 1, _suspend},
-	{"resume", "<device>", 0, 1, _resume},
+	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, 1, _resume},
 	{"load", "<device> [<table_file>]", 0, 2, _load},
 	{"clear", "<device>", 0, 1, _clear},
 	{"reload", "<device> [<table_file>]", 0, 2, _load},


