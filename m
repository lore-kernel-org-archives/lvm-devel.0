From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2007 18:24:09 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20071119182409.11118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-19 18:24:09

Modified files:
	tools          : vgreduce.c 

Log message:
	note pvmove breakage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/tools/vgreduce.c	2007/11/15 21:30:52	1.71
+++ LVM2/tools/vgreduce.c	2007/11/19 18:24:08	1.72
@@ -182,7 +182,7 @@
 				if (seg_type(seg, s) != AREA_PV)
 					continue;
 
-				/* FIXME Also check for segs on deleted LVs */
+				/* FIXME Also check for segs on deleted LVs (incl pvmove) */
 
 				pv = seg_pv(seg, s);
 				if (!pv || !pv_dev(pv)) {


