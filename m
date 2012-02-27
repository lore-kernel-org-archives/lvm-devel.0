From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 09:51:33 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120227095133.1813.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 09:51:32

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Just reindent with tabs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.486&r2=1.487

--- LVM2/lib/metadata/metadata.c	2012/02/23 13:11:10	1.486
+++ LVM2/lib/metadata/metadata.c	2012/02/27 09:51:31	1.487
@@ -1896,12 +1896,12 @@
 
 struct lv_segment *last_seg(const struct logical_volume *lv)
 {
-       struct lv_segment *seg;
+	struct lv_segment *seg;
 
-       dm_list_iterate_back_items(seg, &lv->segments)
-               return seg;
+	dm_list_iterate_back_items(seg, &lv->segments)
+		return seg;
 
-       return NULL;
+	return NULL;
 }
 
 int vg_remove_mdas(struct volume_group *vg)


