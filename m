From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 19:14:28 -0000
Subject: LVM2 lib/datastruct/list.c lib/datastruct/list ...
Message-ID: <20080410191428.4201.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 19:14:27

Modified files:
	lib/datastruct : list.c list.h 
	lib/metadata   : metadata.c 
	tools          : vgmerge.c vgsplit.c 

Log message:
	make list_move consistent with other list fns

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/lib/datastruct/list.c	2007/08/20 20:55:24	1.3
+++ LVM2/lib/datastruct/list.c	2008/04/10 19:14:26	1.4
@@ -66,6 +66,15 @@
 }
 
 /*
+ * Remove an element from existing list and insert before 'head'.
+ */
+void list_move(struct list *head, struct list *elem)
+{
+        list_del(elem);
+        list_add(head, elem);
+}
+
+/*
  * Is the list empty?
  */
 int list_empty(const struct list *head)
--- LVM2/lib/datastruct/list.h	2008/03/26 16:20:54	1.26
+++ LVM2/lib/datastruct/list.h	2008/04/10 19:14:26	1.27
@@ -55,14 +55,9 @@
 void list_del(struct list *elem);
 
 /*
- * Move an element from an existing list to list 'head'.
- * Insert the element before 'head'.
+ * Remove an element from existing list and insert before 'head'.
  */
-static inline void list_move(struct list *item, struct list *head)
-{
-        list_del(item);
-        list_add(head, item);
-}
+void list_move(struct list *head, struct list *elem);
 
 /*
  * Is the list empty?
--- LVM2/lib/metadata/metadata.c	2008/04/10 17:09:31	1.168
+++ LVM2/lib/metadata/metadata.c	2008/04/10 19:14:26	1.169
@@ -716,7 +716,7 @@
 			if (is_orphan_vg(vg_to->name))
 				list_del(&mda->list);
 			else
-				list_move(&mda->list, mdas_to);
+				list_move(mdas_to, &mda->list);
 		}
 	}
 
--- LVM2/tools/vgmerge.c	2008/03/26 17:26:32	1.46
+++ LVM2/tools/vgmerge.c	2008/04/10 19:14:26	1.47
@@ -54,7 +54,7 @@
 		struct list *pvh = vg_from->pvs.n;
 		struct physical_volume *pv;
 
-		list_move(pvh, &vg_to->pvs);
+		list_move(&vg_to->pvs, pvh);
 
 		pv = list_item(pvh, struct pv_list)->pv;
 		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
@@ -89,13 +89,13 @@
 	while (!list_empty(&vg_from->lvs)) {
 		struct list *lvh = vg_from->lvs.n;
 
-		list_move(lvh, &vg_to->lvs);
+		list_move(&vg_to->lvs, lvh);
 	}
 
 	while (!list_empty(&vg_from->fid->metadata_areas)) {
 		struct list *mdah = vg_from->fid->metadata_areas.n;
 
-		list_move(mdah, &vg_to->fid->metadata_areas);
+		list_move(&vg_to->fid->metadata_areas, mdah);
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
--- LVM2/tools/vgsplit.c	2008/04/10 17:09:32	1.61
+++ LVM2/tools/vgsplit.c	2008/04/10 19:14:27	1.62
@@ -28,7 +28,7 @@
 		return 0;
 	}
 
-	list_move(&pvl->list, &vg_to->pvs);
+	list_move(&vg_to->pvs, &pvl->list);
 
 	vg_from->pv_count--;
 	vg_to->pv_count++;
@@ -100,7 +100,7 @@
 	struct logical_volume *lv;
 
 	lv = list_item(lvh, struct lv_list)->lv;
-	list_move(lvh, &vg_to->lvs);
+	list_move(&vg_to->lvs, lvh);
 	
 	if (lv->status & SNAPSHOT) {
 		vg_from->snapshot_count--;


