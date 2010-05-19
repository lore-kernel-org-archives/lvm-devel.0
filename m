From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:52:38 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20100519115238.25069.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:52:38

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add find_vgname_from_{pvname|pvid} functions.
	
	Some commands start with a pvname, but we'd like to force users to
	start with a vg handle to obtain a pv handle.  Our best option seems
	to be providing a way to look up the vgname from the pvname, and then
	require them to use vg_read/vg_open.
	
	In addition to the pvname lookup function, this patch also provides a
	lookup by pvid.  The lookup by pvid can be used in conjunction with
	lvmcache_get_pvids to process all pvs in the system.
	
	The pvid find function first calls lvmcache_vgname_from_pvid, which may
	cause the label to be read if it is not in the cache.  If the vgname is
	returned is an orphan, we then check to see if there are metadata areas,
	and if not, we scan every PV on the system by calling scan_vgs_for_pvs().
	In most cases we should not need to do this, and by using the info->mdas
	count, we avoid calling pv_read() as prior code did.  So this patch is a
	bit cleaner and should allow us to refactor more of the pv code.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.342&r2=1.343

--- LVM2/lib/metadata/metadata-exported.h	2010/05/19 02:08:51	1.145
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/19 11:52:37	1.146
@@ -625,6 +625,10 @@
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name);
 
+const char *find_vgname_from_pvname(struct cmd_context *cmd,
+				    const char *pvname);
+const char *find_vgname_from_pvid(struct cmd_context *cmd,
+				  const char *pvid);
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
 
--- LVM2/lib/metadata/metadata.c	2010/05/19 02:36:33	1.342
+++ LVM2/lib/metadata/metadata.c	2010/05/19 11:52:37	1.343
@@ -3110,6 +3110,52 @@
 	return NULL;
 }
 
+
+const char *find_vgname_from_pvid(struct cmd_context *cmd,
+				  const char *pvid)
+{
+	char *vgname;
+	struct lvmcache_info *info;
+
+	vgname = lvmcache_vgname_from_pvid(cmd, pvid);
+
+	if (is_orphan_vg(vgname)) {
+		if (!(info = info_from_pvid(pvid, 0))) {
+			return_NULL;
+		}
+		/*
+		 * If an orphan PV has no MDAs it may appear to be an
+		 * orphan until the metadata is read off another PV in
+		 * the same VG.  Detecting this means checking every VG
+		 * by scanning every PV on the system.
+		 */
+		if (!dm_list_size(&info->mdas)) {
+			if (!scan_vgs_for_pvs(cmd)) {
+				log_error("Rescan for PVs without "
+					  "metadata areas failed.");
+				return NULL;
+			}
+		}
+		/* Ask lvmcache again - we may have a non-orphan name now */
+		vgname = lvmcache_vgname_from_pvid(cmd, pvid);
+	}
+	return vgname;
+}
+
+
+const char *find_vgname_from_pvname(struct cmd_context *cmd,
+				    const char *pvname)
+{
+	const char *pvid;
+
+	pvid = pvid_from_devname(cmd, pvname);
+	if (!pvid)
+		/* Not a PV */
+		return NULL;
+
+	return find_vgname_from_pvid(cmd, pvid);
+}
+
 /**
  * pv_read - read and return a handle to a physical volume
  * @cmd: LVM command initiating the pv_read


