From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:43:12 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120312144312.28993.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:43:12

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Removing call of release_vg(NULL)
	
	Since we are in error path were vg must be always NULL,
	skip call of release_vg() like we do in other places.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.498&r2=1.499

--- LVM2/lib/metadata/metadata.c	2012/03/12 14:18:29	1.498
+++ LVM2/lib/metadata/metadata.c	2012/03/12 14:43:12	1.499
@@ -3021,7 +3021,6 @@
 		    (!use_precommitted &&
 		     !(vg = mda->ops->vg_read(fid, vgname, mda, 0)))) {
 			inconsistent = 1;
-			release_vg(vg);
 			continue;
 		}
 


