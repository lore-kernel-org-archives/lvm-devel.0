From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Jan 2011 10:45:41 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20110106104541.30667.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-06 10:45:41

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Remove dead assignment of 'ret' value
	
	Variable 'ret' assigned from _do_event() was actually not used and replaced with next
	assignment without any read of the returned value.
	
	Code is reformated - so the error path is put in the if() branch and normal
	code is put after the 'if' together with FIXME comment.
	
	FIXME lowprio: logging needs to be fixed in this code,
	- multiple log_errors are printed, stacks are missing...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2011/01/06 09:45:05	1.38
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2011/01/06 10:45:41	1.39
@@ -715,17 +715,18 @@
 
 	uuid = dm_task_get_uuid(dmt);
 
-	if (!(ret = _do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
-			     DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
-			      &msg, dmevh->dso, uuid, dmevh->mask, 0))) {
-		/* FIXME this will probably horribly break if we get
-		   ill-formatted reply */
-		ret = _parse_message(&msg, &reply_dso, &reply_uuid, &reply_mask);
-	} else {
+	if (_do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
+		      DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
+		      &msg, dmevh->dso, uuid, dmevh->mask, 0)) {
 		ret = -ENOENT;
+		stack;
 		goto fail;
 	}
 
+	/* FIXME this will probably horribly break if we get
+	   ill-formatted reply */
+	ret = _parse_message(&msg, &reply_dso, &reply_uuid, &reply_mask);
+
 	dm_task_destroy(dmt);
 	dmt = NULL;
 


