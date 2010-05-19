From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:52:21 -0000
Subject: LVM2/lib/cache lvmcache.c lvmcache.h
Message-ID: <20100519115221.24898.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:52:21

Modified files:
	lib/cache      : lvmcache.c lvmcache.h 

Log message:
	Add lvmcache_vgname_from_pvid().
	
	Add lvmcache function to lookup a vgname from a pvid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/lib/cache/lvmcache.c	2010/05/19 11:52:07	1.90
+++ LVM2/lib/cache/lvmcache.c	2010/05/19 11:52:21	1.91
@@ -509,6 +509,27 @@
 	return info;
 }
 
+char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
+{
+	struct lvmcache_info *info;
+	char *vgname;
+
+	if (!device_from_pvid(cmd, (struct id *)pvid, NULL)) {
+		log_error("Couldn't find device with uuid %s.", pvid);
+		return NULL;
+	}
+
+	info = info_from_pvid(pvid, 0);
+	if (!info)
+		return_NULL;
+
+	if (!(vgname = dm_pool_strdup(cmd->mem, info->vginfo->vgname))) {
+		log_errno(ENOMEM, "vgname allocation failed");
+		return NULL;
+	}
+	return vgname;
+}
+
 static void _rescan_entry(struct lvmcache_info *info)
 {
 	struct label *label;
--- LVM2/lib/cache/lvmcache.h	2010/05/19 11:52:07	1.32
+++ LVM2/lib/cache/lvmcache.h	2010/05/19 11:52:21	1.33
@@ -98,6 +98,7 @@
 				unsigned *scan_done_once);
 const char *pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
+char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 


