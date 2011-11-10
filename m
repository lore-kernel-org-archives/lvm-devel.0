From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:39:47 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20111110123947.6449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:39:46

Modified files:
	tools          : lvcreate.c 

Log message:
	Thin create normal (old) snapshot when size is specified

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.247&r2=1.248

--- LVM2/tools/lvcreate.c	2011/11/07 11:03:48	1.247
+++ LVM2/tools/lvcreate.c	2011/11/10 12:39:46	1.248
@@ -204,7 +204,12 @@
 		return 0;
 	}
 
-	if (lv_is_thin_volume(lvl->lv)) {
+	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
+		if (!lv_is_thin_volume(lvl->lv)) {
+			log_error("Please specify either size or extents with snapshots.");
+			return 0;
+		}
+
 		lp->thin = 1;
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 			return_0;
@@ -212,11 +217,6 @@
 		lp->pool = first_seg(lvl->lv)->pool_lv->name;
 	}
 
-	if (!lp->thin && !arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
-		log_error("Please specify either size or extents with snapshots.");
-		return 0;
-	}
-
 	return 1;
 }
 


