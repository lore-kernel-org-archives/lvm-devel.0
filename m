From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Nov 2007 17:12:51 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20071105171251.10045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-05 17:12:50

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	fix inverted orphan test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/lib/cache/lvmcache.c	2007/11/02 13:06:41	1.32
+++ LVM2/lib/cache/lvmcache.c	2007/11/05 17:12:50	1.33
@@ -649,7 +649,7 @@
 	vginfo->fmt = info->fmt;
 
 	log_debug("lvmcache: %s: now %s%s%s%s%s", dev_name(info->dev),
-		  is_orphan_vg(vgname) ? "in VG " : "orphaned", vgname,
+		  !is_orphan_vg(vgname) ? "in VG " : "orphaned", vgname,
 		  vginfo->vgid[0] ? " (" : "",
 		  vginfo->vgid[0] ? vginfo->vgid : "",
 		  vginfo->vgid[0] ? ")" : "");


