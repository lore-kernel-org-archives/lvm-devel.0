From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Dec 2009 01:47:34 -0000
Subject: LVM2 lib/metadata/lv_manip.c tools/lvcreate.c
Message-ID: <20091203014734.3260.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-12-03 01:47:34

Modified files:
	lib/metadata   : lv_manip.c 
	tools          : lvcreate.c 

Log message:
	Fix setting of readahead in lvcreate.
	
	The default comes from the configuration settings, with possible
	commandline override.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212

--- LVM2/lib/metadata/lv_manip.c	2009/11/24 22:55:56	1.186
+++ LVM2/lib/metadata/lv_manip.c	2009/12/03 01:47:33	1.187
@@ -3019,7 +3019,7 @@
 				   status, lp->alloc, vg)))
 		return_0;
 
-	if (lp->read_ahead) {
+	if (lp->read_ahead != lv->read_ahead) {
 		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;
 	}
--- LVM2/tools/lvcreate.c	2009/11/27 14:35:39	1.211
+++ LVM2/tools/lvcreate.c	2009/12/03 01:47:34	1.212
@@ -509,7 +509,8 @@
 	/*
 	 * Read ahead.
 	 */
-	lp->read_ahead = arg_uint_value(cmd, readahead_ARG, DM_READ_AHEAD_NONE);
+	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+					cmd->default_settings.read_ahead);
 	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
 	    lp->read_ahead != DM_READ_AHEAD_NONE &&


