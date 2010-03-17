From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 11:51:46 -0400
Subject: [PATCH 1/3] Add a couple of lvmcache functions to aid in lookups by pvname.
In-Reply-To: <1268841108-19327-1-git-send-email-dwysocha@redhat.com>
References: <1268841108-19327-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1268841108-19327-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It would be nice to clean up some of the pv handling and move away from
the pv as a standalone object.  To this end, I introduce a couple helper
functions from lvmcache which allow us to lookup a vgname from a pvname
and an info struct from a pvname.  These functions will be used later
in a library function that we will export and will aid in cleaning
up the pv handling.

Note: Inside lvmcache, we cannot handle the case of the PV with no mdas
that is in a VG.  The reason is the lvmcache 'info' only gets updated
by calling higher-level _vg_read() function, which calls
lvmcache_update_vg().  I did not think it was a good design to parse
per-format metadata inside lvmcache, or call vg_read() from inside
lvmcache.  It seems clear to me the proper place for the additional
scanning calls is at an upper layer, which will be the next patch.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   40 ++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h |    3 +++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 35ee05b..40dc2a1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -499,6 +499,46 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 	return info;
 }
 
+struct lvmcache_info *info_from_pvname(struct cmd_context *cmd,
+				       const char *pvname)
+{
+	struct lvmcache_info *info;
+	struct device *dev;
+	struct label *label;
+
+	if (!(dev = dev_cache_get(pvname, cmd->filter))) {
+		log_error("%s: Couldn't find device.  "
+			  "Check your filters?", pvname);
+		return NULL;
+	}
+	if (dev->pvid[0] == '\0')
+		label_read(dev, &label, UINT64_C(0));
+
+	info = info_from_pvid(dev->pvid, 0);
+	if (!info || dev != info->dev) {
+		log_error("Couldn't find %s in lvmcache.", pvname);
+		return NULL;
+	}
+	return info;
+}
+
+char *lvmcache_vgname_from_pvname(struct cmd_context *cmd, const char *pvname)
+{
+	struct lvmcache_info *info;
+	char *vgname;
+
+	info = info_from_pvname(cmd, pvname);
+	if (!info)
+		return_NULL;
+
+	if (!(vgname = dm_pool_alloc(cmd->mem, NAME_LEN+1))) {
+		log_errno(ENOMEM, "vgname allocation failed");
+		return NULL;
+	}
+	strncpy(vgname, info->vginfo->vgname, NAME_LEN);
+	return vgname;
+}
+
 static void _rescan_entry(struct lvmcache_info *info)
 {
 	struct label *label;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 2c14b6c..ba620ba 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -94,6 +94,9 @@ struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid);
+char *lvmcache_vgname_from_pvname(struct cmd_context *cmd, const char *pvname);
+struct lvmcache_info *info_from_pvname(struct cmd_context *cmd,
+				       const char *pvname);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
-- 
1.6.0.6


