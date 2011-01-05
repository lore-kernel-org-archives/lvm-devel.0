From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 14:03:38 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20110105140338.25448.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 14:03:37

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Add missing error path tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1859&r2=1.1860
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/WHATS_NEW	2011/01/05 12:59:46	1.1859
+++ LVM2/WHATS_NEW	2011/01/05 14:03:36	1.1860
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Add missing tests in _setup_task().
   Fail poll daemon creation when lvmcache_init() fails.
   Return defined value for errors in _copy_percent() and _snap_percent().
   Correct return code of cmirrord when issuing 'start' when already running.
--- LVM2/lib/activate/dev_manager.c	2010/12/22 15:32:15	1.210
+++ LVM2/lib/activate/dev_manager.c	2011/01/05 14:03:37	1.211
@@ -75,19 +75,22 @@
 	if (!(dmt = dm_task_create(task)))
 		return_NULL;
 
-	if (name)
-		dm_task_set_name(dmt, name);
+	if (name && !dm_task_set_name(dmt, name))
+		goto_out;
 
-	if (uuid && *uuid)
-		dm_task_set_uuid(dmt, uuid);
+	if (uuid && *uuid && !dm_task_set_uuid(dmt, uuid))
+		goto_out;
 
-	if (event_nr)
-		dm_task_set_event_nr(dmt, *event_nr);
+	if (event_nr && !dm_task_set_event_nr(dmt, *event_nr))
+		goto_out;
 
-	if (major)
-		dm_task_set_major_minor(dmt, major, minor, 1);
+	if (major && !dm_task_set_major_minor(dmt, major, minor, 1))
+		goto_out;
 
 	return dmt;
+      out:
+	dm_task_destroy(dmt);
+	return NULL;
 }
 
 static int _info_run(const char *name, const char *dlid, struct dm_info *info,


