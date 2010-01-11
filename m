From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 11 Jan 2010 19:08:19 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20100111190819.25277.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-11 19:08:18

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Reset _vgs_locked in lvmcache_init()
	
	Upon successful fork(), _become_daemon() must assert that the locks that
	are currently held belong to the parent, not the child.  All of the
	child's internal state saying 'this process holds a lock' has to be
	reset.
	
	A proper lvmcache_locking_reset() should follow later.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/cache/lvmcache.c	2010/01/05 16:06:43	1.75
+++ LVM2/lib/cache/lvmcache.c	2010/01/11 19:08:18	1.76
@@ -39,6 +39,13 @@
 
 int lvmcache_init(void)
 {
+	/*
+	 * FIXME add a proper lvmcache_locking_reset() that
+	 * resets the cache so no previous locks are locked
+	 * - useful for reset_locking()
+	 */
+	_vgs_locked = 0;
+
 	dm_list_init(&_vginfos);
 
 	if (!(_vgname_hash = dm_hash_create(128)))


