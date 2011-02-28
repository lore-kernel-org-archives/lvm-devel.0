From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2011 17:05:49 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20110228170549.30458.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-28 17:05:48

Modified files:
	lib/format_text: format-text.c 

Log message:
	Use pv->vg_name directly instead of pv->vg->name in _text_pv_write.
	
	This also prevents a possible segfault during an automatic repair
	when the PV does not belong to a VG anymore and we call pv_write_orphan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171

--- LVM2/lib/format_text/format-text.c	2011/02/28 13:19:02	1.170
+++ LVM2/lib/format_text/format-text.c	2011/02/28 17:05:48	1.171
@@ -1273,8 +1273,7 @@
 
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
-		      pv->dev, pv->vg ? pv->vg->name : FMT_TEXT_ORPHAN_VG_NAME,
-		      NULL, 0)))
+				  pv->dev, pv->vg_name, NULL, 0)))
 		return_0;
 
 	label = info->label;


