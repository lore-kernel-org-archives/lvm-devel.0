From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2012 18:52:03 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in tools/dms ...
Message-ID: <20120118185203.16346.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-18 18:52:03

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add dmsetup 'wipe_table' to replace table with one that uses error target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.531&r2=1.532
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172

--- LVM2/WHATS_NEW_DM	2012/01/11 12:46:19	1.531
+++ LVM2/WHATS_NEW_DM	2012/01/18 18:52:02	1.532
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dmsetup wipe_table to replace table with one that uses error target.
   Add 'blkdevname' and 'blkdevs_used' field to dmsetup info -c -o.
   Add 'blkdevname' option to dmsetup ls --tree to see block device names.
   Add '-o options' to dmsetup deps and ls to select device name type on output.
--- LVM2/man/dmsetup.8.in	2012/01/11 12:46:20	1.49
+++ LVM2/man/dmsetup.8.in	2012/01/18 18:52:02	1.50
@@ -69,6 +69,9 @@
 .RB [ \-\-table
 .RI < table >| table_file ]
 .br
+.B dmsetup wipe_table
+.I device_name
+.br
 .B dmsetup remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]
@@ -355,6 +358,15 @@
 If neither is supplied, reads a table from standard input.
 .br
 .HP
+.B wipe_table
+.I device_name
+.br
+Wait for any I/O in-flight through the device to complete, then
+replace the table with a new table that fails any new I/O
+sent to the device.  If successful, this should release any devices 
+held open by the device's table(s).
+.br
+.HP
 .B message
 .I device_name sector message
 .br
--- LVM2/tools/dmsetup.c	2012/01/11 12:46:20	1.171
+++ LVM2/tools/dmsetup.c	2012/01/18 18:52:02	1.172
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2005-2007 NEC Corporation
  *
  * This file is part of the device-mapper userspace tools.
@@ -2870,6 +2870,7 @@
 	{"load", "<device> [<table_file>]", 0, 2, 0, _load},
 	{"clear", "<device>", 0, -1, 1, _clear},
 	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
+	{"wipe_table", "<device>", 0, -1, 1, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, _ls},


