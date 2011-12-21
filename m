From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:54:20 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/thin/thin.c t ...
Message-ID: <20111221125420.13645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:54:19

Modified files:
	lib/metadata   : lv_manip.c 
	lib/thin       : thin.c 
	tools          : lvcreate.c 

Log message:
	Thin rename internal thin pool segment
	
	Use matching name as kernel target - useful when function like
	_percent is using this for validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.339&r2=1.340
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.250&r2=1.251

--- LVM2/lib/metadata/lv_manip.c	2011/12/20 00:02:18	1.339
+++ LVM2/lib/metadata/lv_manip.c	2011/12/21 12:54:19	1.340
@@ -4450,7 +4450,7 @@
 	/* Create thin pool first if necessary */
 	if (lp->create_thin_pool) {
 		if (!seg_is_thin_pool(lp) &&
-		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin_pool")))
+		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool")))
 			return_0;
 
 		if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
--- LVM2/lib/thin/thin.c	2011/11/28 20:37:52	1.34
+++ LVM2/lib/thin/thin.c	2011/12/21 12:54:19	1.35
@@ -474,7 +474,7 @@
 		const char name[16];
 		uint32_t flags;
 	} reg_segtypes[] = {
-		{ &_thin_pool_ops, "thin_pool", SEG_THIN_POOL },
+		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL },
 		/* FIXME Maybe use SEG_THIN_VOLUME instead of SEG_VIRTUAL */
 		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL }
 	};
--- LVM2/tools/lvcreate.c	2011/11/10 12:43:05	1.250
+++ LVM2/tools/lvcreate.c	2011/12/21 12:54:19	1.251
@@ -371,7 +371,7 @@
 		}
 	} else {
 		/* No virtual size given, so no thin LV to create. */
-		if (seg_is_thin_volume(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin_pool")))
+		if (seg_is_thin_volume(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
 			return_0;
 
 		lp->thin = 0;


