From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:53:05 -0000
Subject: LVM2 ./WHATS_NEW lib/datastruct/str_list.c lib ...
Message-ID: <20120208125305.25429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:53:00

Modified files:
	.              : WHATS_NEW 
	lib/datastruct : str_list.c str_list.h 
	lib/metadata   : metadata.c mirror.c 
	tools          : toollib.c 

Log message:
	Switch to return void
	
	List delete cannot fail, so there is no reason to test for error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2269&r2=1.2270
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.475&r2=1.476
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239

--- LVM2/WHATS_NEW	2012/02/08 12:50:10	1.2269
+++ LVM2/WHATS_NEW	2012/02/08 12:52:58	1.2270
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Switch int to void return for str_list_del()
   Fix error path handling in _build_desc()
   Add range test for device number in _scan_proc_dev().
   Use signed long for sysconf() call in cmirrord.
--- LVM2/lib/datastruct/str_list.c	2010/11/11 12:32:33	1.14
+++ LVM2/lib/datastruct/str_list.c	2012/02/08 12:52:59	1.15
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -50,16 +50,13 @@
 	return 1;
 }
 
-int str_list_del(struct dm_list *sll, const char *str)
+void str_list_del(struct dm_list *sll, const char *str)
 {
 	struct dm_list *slh, *slht;
 
-	dm_list_iterate_safe(slh, slht, sll) {
+	dm_list_iterate_safe(slh, slht, sll)
 		if (!strcmp(str, dm_list_item(slh, struct str_list)->str))
 			 dm_list_del(slh);
-	}
-
-	return 1;
 }
 
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
--- LVM2/lib/datastruct/str_list.h	2010/11/11 12:32:33	1.11
+++ LVM2/lib/datastruct/str_list.h	2012/02/08 12:52:59	1.12
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,7 +18,7 @@
 
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
-int str_list_del(struct dm_list *sll, const char *str);
+void str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched);
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);
--- LVM2/lib/metadata/metadata.c	2012/01/25 08:50:10	1.475
+++ LVM2/lib/metadata/metadata.c	2012/02/08 12:52:59	1.476
@@ -770,13 +770,9 @@
 				  tag, lv->vg->name, lv->name);
 			return 0;
 		}
-	} else {
-		if (!str_list_del(&lv->tags, tag)) {
-			log_error("Failed to remove tag %s from %s/%s",
-				  tag, lv->vg->name, lv->name);
-			return 0;
-		}
-	}
+	} else
+		str_list_del(&lv->tags, tag);
+
 	return 1;
 }
 
@@ -800,13 +796,9 @@
 				  tag, vg->name);
 			return 0;
 		}
-	} else {
-		if (!str_list_del(&vg->tags, tag)) {
-			log_error("Failed to remove tag %s from volume group "
-				  "%s", tag, vg->name);
-			return 0;
-		}
-	}
+	} else
+		str_list_del(&vg->tags, tag);
+
 	return 1;
 }
 
--- LVM2/lib/metadata/mirror.c	2012/02/08 11:40:02	1.177
+++ LVM2/lib/metadata/mirror.c	2012/02/08 12:52:59	1.178
@@ -335,9 +335,7 @@
 
 	/* Remove the temporary tags */
 	dm_list_iterate_items(sl, tags)
-		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
-				  sl->str);
+		str_list_del(&log_lv->tags, sl->str);
 
 	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
@@ -374,9 +372,7 @@
 	log_lv->status = orig_status;
 
 	dm_list_iterate_items(sl, tags)
-		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
-				  sl->str);
+		str_list_del(&log_lv->tags, sl->str);
 
 	if (remove_on_failure && !lv_remove(log_lv)) {
 		log_error("Manual intervention may be required to remove "
--- LVM2/tools/toollib.c	2012/01/25 21:52:53	1.238
+++ LVM2/tools/toollib.c	2012/02/08 12:52:59	1.239
@@ -1594,11 +1594,8 @@
 				  tag, pv_dev_name(pv));
 			return 0;
 		}
-	} else if (!str_list_del(&pv->tags, tag)) {
-		log_error("Failed to remove tag %s from physical volume" "%s",
-			  tag,  pv_dev_name(pv));
-		return 0;
-	}
+	} else
+		str_list_del(&pv->tags, tag);
 
 	return 1;
 }


