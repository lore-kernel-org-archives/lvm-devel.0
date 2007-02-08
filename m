From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Feb 2007 17:31:03 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20070208173103.26558.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-08 17:31:03

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix loading of segment_libraries. [gentoo]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.570&r2=1.571
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2007/02/07 13:29:51	1.570
+++ LVM2/WHATS_NEW	2007/02/08 17:31:02	1.571
@@ -1,5 +1,6 @@
 Version 2.02.22 - 
 ===================================
+  Fix loading of segment_libraries.
   If a PV reappears after it was removed from its VG, make it an orphan.
   Don't update metadata automatically if VGIDs don't match.
   Fix some vgreduce --removemissing command line validation.
--- LVM2/lib/commands/toolcontext.c	2007/01/25 21:22:30	1.47
+++ LVM2/lib/commands/toolcontext.c	2007/02/08 17:31:02	1.48
@@ -754,7 +754,6 @@
 		struct config_value *cv;
 		struct segment_type *(*init_segtype_fn) (struct cmd_context *);
 		void *lib;
-		struct list *sgtl, *tmp;
 		struct segment_type *segtype2;
 
 		for (cv = cn->v; cv; cv = cv->next) {
@@ -781,18 +780,16 @@
 			segtype->library = lib;
 			list_add(&cmd->segtypes, &segtype->list);
 
-			list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
-				segtype2 = list_item(sgtl, struct segment_type);
-				if (!strcmp(segtype2->name, segtype->name)) {
-					log_error("Duplicate segment type %s: "
-						  "unloading shared library %s",
-						  segtype->name, cv->v.str);
-					list_del(&segtype->list);
-					segtype->ops->destroy(segtype);
-					dlclose(lib);
-					break;
-				}
-
+			list_iterate_items(segtype2, &cmd->segtypes) {
+				if ((segtype == segtype2) ||
+				     strcmp(segtype2->name, segtype->name))
+					continue;
+				log_error("Duplicate segment type %s: "
+					  "unloading shared library %s",
+					  segtype->name, cv->v.str);
+				list_del(&segtype->list);
+				segtype->ops->destroy(segtype);
+				dlclose(lib);
 			}
 		}
 	}


