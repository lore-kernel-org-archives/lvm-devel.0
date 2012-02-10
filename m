From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 15:17:52 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20120210151752.8608.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 15:17:52

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Fix message check
	
	Check pointer from strchr for NULL instead of crash later.
	Badly formated message would have crash dmeventd otherwise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.548&r2=1.549
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW_DM	2012/02/10 14:48:28	1.548
+++ LVM2/WHATS_NEW_DM	2012/02/10 15:17:52	1.549
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Fix dm_event_get_version() check.
   Add pointer test for dependency check in _add_dev().
   Validate name and uuid params of dm_tree_add_new_dev_with_udev_flags().
   Do not crash for dm_report_init() sort_key == NULL and behave like "".
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2011/07/08 12:35:48	1.42
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/10 15:17:52	1.43
@@ -811,11 +811,11 @@
 	p = msg.data;
 	*version = 0;
 
-	p = strchr(p, ' ') + 1; /* Message ID */
+	p = strchr(p, ' '); /* Message ID */
         if (!p) return 0;
-	p = strchr(p, ' ') + 1; /* HELLO */
+	p = strchr(p + 1, ' '); /* HELLO */
         if (!p) return 0;
-	p = strchr(p, ' '); /* HELLO, once more */
+	p = strchr(p + 1, ' '); /* HELLO, once more */
 	if (p)
 		*version = atoi(p);
 	return 1;


