From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 09:03:36 -0000
Subject: LVM2/lib/metadata merge.c
Message-ID: <20110929090336.18702.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 09:03:36

Modified files:
	lib/metadata   : merge.c 

Log message:
	Fix bad error message for thinp validation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/metadata/merge.c	2011/09/29 08:56:39	1.50
+++ LVM2/lib/metadata/merge.c	2011/09/29 09:03:36	1.51
@@ -239,7 +239,7 @@
 				}
 
 				if (seg->device_id >= (1 << 24)) {
-					log_error("LV %s: thin volume segment %u pool LV to large device id %d",
+					log_error("LV %s: thin volume segment %u has too large device id %d",
 						  lv->name, seg_count, seg->device_id);
 					inc_error_count;
 				}


