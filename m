From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 15:28:46 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/libdevmapper ...
Message-ID: <20101222152846.25643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 15:28:44

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Detect errors from dm_task_set calls
	
	Check for errors in dm_task_set calls.
	Use  goto_bad macro with stack trace.
	Replace  label  failed: with bad:.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1853&r2=1.1854
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2010/12/22 13:45:33	1.1853
+++ LVM2/WHATS_NEW	2010/12/22 15:28:44	1.1854
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Detect errors from dm_task_set calls in _get_device_info (dmeventd).
   Add backtraces for archive and backup_locally in check_current_backup().
   Fix memory leak in debug mode of restart_clvmd() error path.
   Log error message for pthread_join() failure in clvmd.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/10/25 11:57:07	1.36
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/12/22 15:28:44	1.37
@@ -538,34 +538,37 @@
 		return NULL;
 	}
 
-	if (dmevh->uuid)
-		dm_task_set_uuid(dmt, dmevh->uuid);
-	else if (dmevh->dev_name)
-		dm_task_set_name(dmt, dmevh->dev_name);
-	else if (dmevh->major && dmevh->minor) {
-		dm_task_set_major(dmt, dmevh->major);
-		dm_task_set_minor(dmt, dmevh->minor);
-        }
+	if (dmevh->uuid) {
+		if (!dm_task_set_uuid(dmt, dmevh->uuid))
+			goto_bad;
+	} else if (dmevh->dev_name) {
+		if (!dm_task_set_name(dmt, dmevh->dev_name))
+			goto_bad;
+	} else if (dmevh->major && dmevh->minor) {
+		if (!dm_task_set_major(dmt, dmevh->major) ||
+		    !dm_task_set_minor(dmt, dmevh->minor))
+			goto_bad;
+	}
 
 	/* FIXME Add name or uuid or devno to messages */
 	if (!dm_task_run(dmt)) {
 		log_error("_get_device_info: dm_task_run() failed");
-		goto failed;
+		goto bad;
 	}
 
 	if (!dm_task_get_info(dmt, &info)) {
 		log_error("_get_device_info: failed to get info for device");
-		goto failed;
+		goto bad;
 	}
 
 	if (!info.exists) {
 		log_error("_get_device_info: device not found");
-		goto failed;
+		goto bad;
 	}
 
 	return dmt;
 
-failed:
+      bad:
 	dm_task_destroy(dmt);
 	return NULL;
 }


