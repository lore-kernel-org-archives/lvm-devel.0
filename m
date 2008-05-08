From: agk@sourceware.org <agk@sourceware.org>
Date: 8 May 2008 18:00:47 -0000
Subject: LVM2/lib/cache lvmcache.h
Message-ID: <20080508180047.12088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-08 18:00:47

Modified files:
	lib/cache      : lvmcache.h 

Log message:
	remove unused lvmcache_drop_vg prototype

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/cache/lvmcache.h	2008/04/15 14:46:18	1.22
+++ LVM2/lib/cache/lvmcache.h	2008/05/08 18:00:47	1.23
@@ -81,7 +81,6 @@
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *hostname);
 int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
-void lvmcache_drop_vg(const char *vgname);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);


