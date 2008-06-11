From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jun 2008 11:02:06 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20080611110206.31946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-11 11:02:05

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Fix tracking of validity of PVs with no mdas in lvmcache.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.896&r2=1.897
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2008/06/10 20:07:04	1.896
+++ LVM2/WHATS_NEW	2008/06/11 11:02:05	1.897
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Fix tracking of validity of PVs with no mdas in lvmcache.
   Fix return values for reporting commands when run with no PVs, LVs, or VGs.
   Add omitted unlock_vg() call when sigint_caught() during vg processing.
   Fix wrong free_count on imported vg from pool device
--- LVM2/lib/cache/lvmcache.c	2008/06/09 16:22:33	1.57
+++ LVM2/lib/cache/lvmcache.c	2008/06/11 11:02:05	1.58
@@ -1015,6 +1015,15 @@
 		vgid = vgname;
 	}
 
+	/* If PV without mdas is already in a real VG, don't make it orphan */
+	if (is_orphan_vg(vgname) && info->vginfo && !list_size(&info->mdas) &&
+	    !is_orphan_vg(info->vginfo->vgname) && memlock())
+		return 1;
+
+	/* If moving PV from orphan to real VG, always mark it valid */
+	if (!is_orphan_vg(vgname))
+		info->status &= ~CACHE_INVALID;
+
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgstatus,
 				     creation_host, info->fmt) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||


