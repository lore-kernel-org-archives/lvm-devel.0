From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:41:49 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20120301104149.17943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:41:49

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	More useful debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/28 11:03:24	1.47
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/03/01 10:41:48	1.48
@@ -731,8 +731,8 @@
 	if (_do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
 		      DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
 		      &msg, dmevh->dso, uuid, dmevh->mask, 0)) {
+		log_debug("%s: device not registered.", dm_task_get_name(dmt));
 		ret = -ENOENT;
-		stack;
 		goto fail;
 	}
 


