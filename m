From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:25:46 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/snapshot_manip.c
Message-ID: <20090513212546.27791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:25:46

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : snapshot_manip.c 

Log message:
	Fix lv_is_visible to handle virtual origin.
	
	Snapshot is visible if its origin is marked visible,
	or if the origin is virtual.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1106&r2=1.1107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2009/05/13 21:25:01	1.1106
+++ LVM2/WHATS_NEW	2009/05/13 21:25:45	1.1107
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix lv_is_visible to handle virtual origin.
   Introduce link_lv_to_vg and unlink_lv_from_vg functions.
   Remove lv_count from VG and use counter function instead.
   Fix snapshot segment import to not use duplicate segments & replace.
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:22:57	1.38
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:25:46	1.39
@@ -30,8 +30,15 @@
 
 int lv_is_visible(const struct logical_volume *lv)
 {
-	if (lv_is_cow(lv))
-		return lv_is_visible(find_cow(lv)->lv);
+	if (lv->status & SNAPSHOT)
+		return 0;
+
+	if (lv_is_cow(lv)) {
+		if (lv_is_virtual_origin(origin_from_cow(lv)))
+			return 1;
+
+		return lv_is_visible(origin_from_cow(lv));
+	}
 
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }


