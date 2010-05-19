From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:52:08 -0000
Subject: LVM2/lib/cache lvmcache.c lvmcache.h
Message-ID: <20100519115208.24733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:52:08

Modified files:
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Add pvid_from_devname() lvmcache function.
	
	Add supporting function for mappings from devname -> pvid -> vgname.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/cache/lvmcache.c	2010/05/19 02:08:50	1.89
+++ LVM2/lib/cache/lvmcache.c	2010/05/19 11:52:07	1.90
@@ -757,6 +757,25 @@
 	return NULL;
 }
 
+const char *pvid_from_devname(struct cmd_context *cmd,
+			      const char *devname)
+{
+	struct device *dev;
+	struct label *label;
+
+	if (!(dev = dev_cache_get(devname, cmd->filter))) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  devname);
+		return NULL;
+	}
+
+	if (!(label_read(dev, &label, UINT64_C(0))))
+		return NULL;
+
+	return dev->pvid;
+}
+
+
 static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 {
 	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
--- LVM2/lib/cache/lvmcache.h	2010/05/19 02:36:33	1.31
+++ LVM2/lib/cache/lvmcache.h	2010/05/19 11:52:07	1.32
@@ -96,6 +96,8 @@
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
 				unsigned *scan_done_once);
+const char *pvid_from_devname(struct cmd_context *cmd,
+			      const char *dev_name);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 


