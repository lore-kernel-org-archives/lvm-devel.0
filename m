From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:58:55 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120301215855.20579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:58:55

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Check pointer before deref in debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/lib/cache/lvmcache.c	2012/03/01 21:57:43	1.132
+++ LVM2/lib/cache/lvmcache.c	2012/03/01 21:58:55	1.133
@@ -1110,8 +1110,8 @@
 
 	if (!is_orphan_vg(vginfo->vgname))
 		log_debug("lvmcache: %s: setting %s VGID to %s",
-			  dev_name(info->dev), vginfo->vgname,
-			  vginfo->vgid);
+			  (info) ? dev_name(info->dev) : "",
+			  vginfo->vgname, vginfo->vgid);
 
 	return 1;
 }


