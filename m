From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 23:18:01 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20111208231801.4000.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 23:18:00

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	When dropping the VG metadata from the cache during a VG revert, we must
	reset the 'precomitted' flag, just as we'd clear if we next did a 'commit'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/lib/cache/lvmcache.c	2011/10/11 09:09:00	1.119
+++ LVM2/lib/cache/lvmcache.c	2011/12/08 23:18:00	1.120
@@ -205,6 +205,10 @@
 			info->status |= CACHE_INVALID;
 
 	_free_cached_vgmetadata(vginfo);
+
+	/* VG revert */
+	if (drop_precommitted)
+		vginfo->precommitted = 0;
 }
 
 /*


