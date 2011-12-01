From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Dec 2011 00:04:21 -0000
Subject: LVM2/tools lvchange.c
Message-ID: <20111201000421.23150.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-12-01 00:04:21

Modified files:
	tools          : lvchange.c 

Log message:
	Do not allow users to change permissions on RAID sub-LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/tools/lvchange.c	2011/11/18 19:22:49	1.136
+++ LVM2/tools/lvchange.c	2011/12/01 00:04:21	1.137
@@ -43,6 +43,14 @@
 		return 0;
 	}
 
+	/* Not allowed to change permissions on RAID sub-LVs directly */
+	if ((lv->status & RAID_META) || (lv->status & RAID_IMAGE)) {
+		log_error("Cannot change permissions of RAID %s \"%s\"",
+			  (lv->status & RAID_IMAGE) ? "image" :
+			  "metadata area", lv->name);
+		return 0;
+	}
+
 	if (lv_access & LVM_WRITE) {
 		lv->status |= LVM_WRITE;
 		log_verbose("Setting logical volume \"%s\" read/write",


