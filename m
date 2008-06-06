From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 12:43:41 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20080606124341.15472.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 12:43:41

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	fix _free_vginfo not to remove a ref to a *different* vginfo from the vgid cache

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/lib/cache/lvmcache.c	2008/06/06 11:12:50	1.55
+++ LVM2/lib/cache/lvmcache.c	2008/06/06 12:43:40	1.56
@@ -651,7 +651,8 @@
 	if (vginfo->creation_host)
 		dm_free(vginfo->creation_host);
 
-	if (*vginfo->vgid && _vgid_hash)
+	if (*vginfo->vgid && _vgid_hash &&
+	    vginfo_from_vgid(vginfo->vgid) == vginfo)
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 
 	list_del(&vginfo->list);


