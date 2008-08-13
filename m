From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Aug 2008 13:42:36 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20080813134236.18449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-13 13:42:36

Modified files:
	lib/metadata   : metadata.c 

Log message:
	get lv_list properly from vg->lst and fix compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186

--- LVM2/lib/metadata/metadata.c	2008/08/05 12:05:25	1.185
+++ LVM2/lib/metadata/metadata.c	2008/08/13 13:42:35	1.186
@@ -296,11 +296,14 @@
 			    struct volume_group *vg,
 			    force_t force)
 {
+	struct list *lst;
 	struct lv_list *lvl;
 
-        while ((lvl = list_first(&vg->lvs)))
+	while ((lst = list_first(&vg->lvs))) {
+		lvl = list_item(lst, struct lv_list);
 		if (!lv_remove_with_dependencies(cmd, lvl->lv, force))
-			return 0;
+		    return 0;
+	}
 
 	return 1;
 }


