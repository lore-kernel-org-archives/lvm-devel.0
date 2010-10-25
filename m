From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:02:28 -0000
Subject: LVM2/lib/cache lvmcache.c lvmcache.h
Message-ID: <20101025130228.7836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:02:26

Modified files:
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Use 'const' struct id *pvid for device_from_pvid()
	
	Update interface for device_from_pvid and use const pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/cache/lvmcache.c	2010/09/30 21:06:51	1.95
+++ LVM2/lib/cache/lvmcache.c	2010/10/25 13:02:26	1.96
@@ -733,7 +733,7 @@
 	return pvids;
 }
 
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once)
 {
 	struct label *label;
--- LVM2/lib/cache/lvmcache.h	2010/05/19 11:52:21	1.33
+++ LVM2/lib/cache/lvmcache.h	2010/10/25 13:02:26	1.34
@@ -94,7 +94,7 @@
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once);
 const char *pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);


