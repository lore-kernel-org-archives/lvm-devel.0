From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 20:00:02 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20080116200002.2623.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 20:00:01

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	additional safety check on new segment list

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/lib/metadata/lv_manip.c	2008/01/16 19:00:59	1.141
+++ LVM2/lib/metadata/lv_manip.c	2008/01/16 20:00:01	1.142
@@ -91,6 +91,13 @@
 
 	sl = list_item(list_first(&lv->segs_using_this_lv), struct seg_list);
 
+	if (sl->count != 1) {
+		log_error("%s is expected to have only one segment using it, "
+			  "while %s:%" PRIu32 " uses it %d times",
+			  lv->name, sl->seg->lv->name, sl->seg->le, sl->count);
+		return NULL;
+	}
+
 	return sl->seg;
 }
 


