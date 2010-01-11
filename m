From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 11 Jan 2010 19:12:26 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20100111191226.31491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-11 19:12:25

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	remove errant comment fragment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/lib/cache/lvmcache.c	2010/01/11 19:08:18	1.76
+++ LVM2/lib/cache/lvmcache.c	2010/01/11 19:12:25	1.77
@@ -42,7 +42,6 @@
 	/*
 	 * FIXME add a proper lvmcache_locking_reset() that
 	 * resets the cache so no previous locks are locked
-	 * - useful for reset_locking()
 	 */
 	_vgs_locked = 0;
 


