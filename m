From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Apr 2009 12:03:56 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20090424120356.23359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-24 12:03:56

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Fix pool leak in lvmcache_read_vg error path.
	(Introduced in previous patches.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/lib/cache/lvmcache.c	2009/02/17 18:56:41	1.64
+++ LVM2/lib/cache/lvmcache.c	2009/04/24 12:03:55	1.65
@@ -522,6 +522,7 @@
 	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
 	    !vg_validate(vg)) {
 		_free_cached_vgmetadata(vginfo);
+		vg_release(vg);
 		return_NULL;
 	}
 


