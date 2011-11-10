From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:42:37 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111110124237.7522.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:42:36

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin test min thin_pool size for at least 1 chunk

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.328&r2=1.329

--- LVM2/lib/metadata/lv_manip.c	2011/11/10 12:42:15	1.328
+++ LVM2/lib/metadata/lv_manip.c	2011/11/10 12:42:36	1.329
@@ -4102,6 +4102,12 @@
 		return NULL;
 	}
 
+	if (seg_is_thin_pool(lp) &&
+	    (lp->extents * vg->extent_size < lp->chunk_size)) {
+		log_error("Unable to create thin pool smaller than 1 chunk.");
+		return NULL;
+	}
+
 	if (lp->snapshot && !lp->thin && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
 		log_error("Unable to create a snapshot smaller than 2 chunks.");
 		return NULL;


