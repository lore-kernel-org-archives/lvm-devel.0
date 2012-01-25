From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:50:12 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120125085012.23030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:50:10

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Thin dependency scan support
	
	Go through pool_lv and metadata_lv LVs when doing recursive scan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.474&r2=1.475

--- LVM2/lib/metadata/metadata.c	2011/11/18 19:31:10	1.474
+++ LVM2/lib/metadata/metadata.c	2012/01/25 08:50:10	1.475
@@ -2056,6 +2056,10 @@
 			return_0;
 		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
 			return_0;
+		if (lvseg->pool_lv && !fn(lvseg->pool_lv, data))
+			return_0;
+		if (lvseg->metadata_lv && !fn(lvseg->metadata_lv, data))
+			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
 				return_0;


