From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 11:51:47 -0400
Subject: [PATCH 2/3] Add find_vgname_from_pvname() function using lvmcache functions.
In-Reply-To: <1268841108-19327-2-git-send-email-dwysocha@redhat.com>
References: <1268841108-19327-1-git-send-email-dwysocha@redhat.com>
	<1268841108-19327-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1268841108-19327-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Some commands start with a pvname, but we'd like to force users to
start with a vg handle to obtain a pv handle.  Our best option seems
to be providing a way to look up the vgname from the pvname, and then
requiring them to use vg_read/vg_open.  Similarly, we could hide the
vgname lookup function inside a higher level API such as 'pv_open()',
which would take a pvname or pvid, and do the necessary lookups to
find the vgname, then do a vg_open(), and return the proper pv handle
attached to the VG.  In any case, we need this supporting function.

This find function first does an intial scan, then asks lvmcache for
the vgname.  If the vgname is an orphan, we then check to see if
there are metadata areas, and if not, we scan every PV on the system by
calling scan_vgs_for_pvs().  In most cases we should not need to do
this, and by using the info->mdas count, we avoid calling pv_read()
as prior code did.  So this patch is a bit cleaner IMO and should
allow us to refactor more of the pv code.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   42 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9540285..eb2576c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -609,6 +609,7 @@ struct logical_volume *find_lv(const struct volume_group *vg,
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name);
 
+char *find_vgname_from_pvname(struct cmd_context *cmd, const char *pvname);
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f1b90a7..5d98091 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3031,6 +3031,48 @@ out:
 	return NULL;
 }
 
+
+char *find_vgname_from_pvname(struct cmd_context *cmd, const char *pvname)
+{
+	char *vgname;
+	struct lvmcache_info *info;
+
+	/*
+	 * Initially, all we have is a pv name - we don't know the VG name.
+	 * Try to look the name up in lvmcache.
+	 */
+	lvmcache_label_scan(cmd, 0);
+	vgname = lvmcache_vgname_from_pvname(cmd, pvname);
+
+	if (is_orphan_vg(vgname)) {
+		/*
+		 * If it's an orphan though, we need to do more work,
+		 * if there's no mdas.
+		 */
+		if (!(info = info_from_pvname(cmd, pvname))) {
+			return_NULL;
+		}
+		/*
+		 * If a PV has no MDAs it may appear to be an
+		 * orphan until the metadata is read off
+		 * another PV in the same VG.  Detecting this
+		 * means checking every VG by scanning every
+		 * PV on the system.
+		 */
+		if (!dm_list_size(&info->mdas)) {
+			if (!scan_vgs_for_pvs(cmd)) {
+				log_error("Rescan for PVs without "
+					  "metadata areas failed.");
+				return NULL;
+			}
+		}
+		/* Ask lvmcache again - we may have a non-orphan name now */
+		vgname = lvmcache_vgname_from_pvname(cmd, pvname);
+	}
+
+	return vgname;
+}
+
 /**
  * pv_read - read and return a handle to a physical volume
  * @cmd: LVM command initiating the pv_read
-- 
1.6.0.6


