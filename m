From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jan 2008 16:18:39 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20080130161839.11764.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-30 16:18:38

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	only read labels once between each lock event

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/lib/cache/lvmcache.c	2008/01/30 13:59:58	1.36
+++ LVM2/lib/cache/lvmcache.c	2008/01/30 16:18:37	1.37
@@ -225,6 +225,16 @@
 	if (info->status & CACHE_INVALID)
 		return 0;
 
+	/*
+	 * The caller must hold the VG lock to manipulate metadata.
+	 * In a cluster, remote nodes sometimes read metadata in the
+	 * knowledge that the controlling node is holding the lock.
+	 * So if the VG appears to be unlocked here, it should be safe
+	 * to use the cached value.
+	 */
+	if (info->vginfo && !vgname_is_locked(info->vginfo->vgname))
+		return 1;
+
 	if (!(info->status & CACHE_LOCKED))
 		return 0;
 


