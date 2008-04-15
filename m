From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Apr 2008 14:54:00 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20080415145400.23403.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-15 14:54:00

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	missing stack

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/cache/lvmcache.c	2008/04/15 14:46:18	1.45
+++ LVM2/lib/cache/lvmcache.c	2008/04/15 14:54:00	1.46
@@ -420,10 +420,10 @@
 	    (!precommitted && vginfo->precommitted))
 		return NULL;
 
-	fid =  vginfo->fmt->ops->create_instance(vginfo->fmt, vginfo->vgname,
-						 vgid, NULL);
-	if (!fid)
-		return NULL;
+	if (!(fid =  vginfo->fmt->ops->create_instance(vginfo->fmt,
+						       vginfo->vgname,
+						       vgid, NULL)))
+		return_NULL;
 
 	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
 	    !vg_validate(vg)) {


