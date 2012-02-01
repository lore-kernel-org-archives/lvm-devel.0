From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Feb 2012 01:54:21 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20120201015421.27883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-01 01:54:20

Modified files:
	tools          : lvcreate.c 

Log message:
	lp.pool may be (null) too

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.252&r2=1.253

--- LVM2/tools/lvcreate.c	2012/01/05 15:38:19	1.252
+++ LVM2/tools/lvcreate.c	2012/02/01 01:54:20	1.253
@@ -1017,7 +1017,8 @@
 	if (lp.thin)
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
 			    lp.lv_name ? : "with generated name",
-			    lp.pool, lp.vg_name, lp.snapshot ? " as snapshot of " : "",
+			    lp.pool ? : "with generated name", lp.vg_name,
+			    lp.snapshot ? " as snapshot of " : "",
 			    lp.snapshot ? lp.origin : "", lp.segtype->name);
 
 	if (!lv_create_single(vg, &lp)) {


