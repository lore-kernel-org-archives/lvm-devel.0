From: agk@sourceware.org <agk@sourceware.org>
Date: 13 May 2009 01:48:19 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090513014819.2529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-13 01:48:19

Modified files:
	lib/metadata   : metadata.c 

Log message:
	better variable name for snapshot counting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.215&r2=1.216

--- LVM2/lib/metadata/metadata.c	2009/05/12 19:12:09	1.215
+++ LVM2/lib/metadata/metadata.c	2009/05/13 01:48:18	1.216
@@ -1156,13 +1156,13 @@
 unsigned snapshot_count(const struct volume_group *vg)
 {
 	struct lv_list *lvl;
-	unsigned lv_count = 0;
+	unsigned num_snapshots = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_cow(lvl->lv))
-			lv_count++;
+			num_snapshots++;
 
-	return lv_count;
+	return num_snapshots;
 }
 
 /*


