From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Oct 2008 12:06:31 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/snapshot/dmeventd_sn ...
Message-ID: <20081013120631.29905.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-10-13 12:06:30

Modified files:
	.              : WHATS_NEW 
	dmeventd/snapshot: dmeventd_snapshot.c 

Log message:
	Fix snapshot monitoring library to not cancel monitoring invalid snapshot.
	
	snapshot DSO unregistered itself when snapshot changed state to invalid.
	
	This can cause a race (and several timeouts), when for example another snapshot
	is added and in the middle of operation (suspend/resume) the monitoring thread
	unregister itself.
	
	Fix it by keeping the snapshot monitored after invalidation - just reset
	threshold to not really print any messages to syslog.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.973&r2=1.974
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2008/10/08 12:50:12	1.973
+++ LVM2/WHATS_NEW	2008/10/13 12:06:30	1.974
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Fix snapshot monitoring library to not cancel monitoring invalid snapshot.
   Generate man pages from templates and include version.
   Add usrlibdir and usrsbindir to configure.
   Fix conversion of md chunk size into sectors.
--- LVM2/dmeventd/snapshot/dmeventd_snapshot.c	2008/01/31 12:19:35	1.2
+++ LVM2/dmeventd/snapshot/dmeventd_snapshot.c	2008/10/13 12:06:30	1.3
@@ -99,24 +99,6 @@
 	stat->max = atoi(p);
 }
 
-/* send unregister command to itself */
-static void _unregister_self(struct dm_task *dmt)
-{
-	const char *name = dm_task_get_name(dmt);
-	struct dm_event_handler *dmevh;
-
-	if (!(dmevh = dm_event_handler_create()))
-		return;
-
-	if (dm_event_handler_set_dev_name(dmevh, name))
-		goto fail;
-
-	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS|DM_EVENT_TIMEOUT);
-	dm_event_unregister_handler(dmevh);
-fail:
-	dm_event_handler_destroy(dmevh);
-}
-
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute((unused)),
 		   void **private)
@@ -149,7 +131,6 @@
 	 */
 	if (stat.invalid || !stat.max) {
 		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
-		_unregister_self(dmt);
 		*percent_warning = 0;
 		goto out;
 	}


