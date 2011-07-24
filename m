From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2011 23:59:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110724235904.10711.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-24 23:59:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix read-only identical table reload supression.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.481&r2=1.482
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/WHATS_NEW_DM	2011/07/08 19:57:33	1.481
+++ LVM2/WHATS_NEW_DM	2011/07/24 23:59:03	1.482
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Fix read-only identical table reload supression.
 
 Version 1.02.65 - 8th July 2011
 ===============================
--- LVM2/libdm/ioctl/libdm-iface.c	2011/07/02 01:17:10	1.113
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/07/24 23:59:03	1.114
@@ -1848,7 +1848,7 @@
 		t2 = t2->next;
 	dmt->existing_table_size = t2 ? t2->start + t2->length : 0;
 
-	if ((task->dmi.v4->flags & DM_READONLY_FLAG) ? 1 : 0 != dmt->read_only)
+	if (((task->dmi.v4->flags & DM_READONLY_FLAG) ? 1 : 0) != dmt->read_only)
 		goto no_match;
 
 	t1 = dmt->head;


