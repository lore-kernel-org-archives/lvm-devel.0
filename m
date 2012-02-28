From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:08:04 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120228110804.1864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:08:04

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Add stacktrace for init_lvmcache_orphans fail path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/cache/lvmcache.c	2012/02/28 10:10:07	1.129
+++ LVM2/lib/cache/lvmcache.c	2012/02/28 11:08:04	1.130
@@ -1628,7 +1628,8 @@
 	dm_list_init(&_vginfos);
 
 	if (retain_orphans)
-		init_lvmcache_orphans(cmd);
+		if (!init_lvmcache_orphans(cmd))
+			stack;
 }
 
 int lvmcache_pvid_is_locked(const char *pvid) {


