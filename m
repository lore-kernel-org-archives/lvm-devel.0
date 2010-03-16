From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 19:06:58 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20100316190658.1311.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 19:06:58

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	fix last checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/lib/cache/lvmcache.c	2010/03/16 17:30:01	1.80
+++ LVM2/lib/cache/lvmcache.c	2010/03/16 19:06:57	1.81
@@ -605,9 +605,9 @@
 	    (!precommitted && vginfo->precommitted && !memlock()))
 		return NULL;
 
-	if (!(fid =  vginfo->fmt->ops->create_instance(vginfo->fmt,
-						       vginfo->vgname,
-						       vgid, NULL)))
+	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
+						      vginfo->vgname,
+						      vgid, NULL)))
 		return_NULL;
 
 	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
@@ -733,7 +733,8 @@
 		return NULL;
 
 	lvmcache_label_scan(cmd, 2);
-	*scan_done_once = 1;
+	if (scan_done_once)
+		*scan_done_once = 1;
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid, 0))) {


