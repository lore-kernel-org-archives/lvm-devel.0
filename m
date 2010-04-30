From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Apr 2010 12:54:32 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20100430125432.30215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-30 12:54:31

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Initialise _vginfos list staticaly so there is no problem with using uninitialised
	variables in case, lvmcache_destory() is called without lvmcache_init().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/lib/cache/lvmcache.c	2010/04/01 10:34:09	1.84
+++ LVM2/lib/cache/lvmcache.c	2010/04/30 12:54:31	1.85
@@ -31,7 +31,7 @@
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
-static struct dm_list _vginfos;
+static DM_LIST_INIT(_vginfos);
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;


