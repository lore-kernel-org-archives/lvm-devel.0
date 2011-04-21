From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Apr 2011 13:15:26 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20110421131526.21574.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-21 13:15:26

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Skip check for NULL before dm_free
	
	dm_free makes this test itself.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/lib/cache/lvmcache.c	2011/03/30 13:14:34	1.109
+++ LVM2/lib/cache/lvmcache.c	2011/04/21 13:15:26	1.110
@@ -857,11 +857,8 @@
 		}
  	while ((vginfo2 = vginfo2->next));
 
-	if (vginfo->vgname)
-		dm_free(vginfo->vgname);
-
-	if (vginfo->creation_host)
-		dm_free(vginfo->creation_host);
+	dm_free(vginfo->vgname);
+	dm_free(vginfo->creation_host);
 
 	if (*vginfo->vgid && _vgid_hash &&
 	    vginfo_from_vgid(vginfo->vgid) == vginfo)


