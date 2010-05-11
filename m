From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 May 2010 08:36:06 -0400
Subject: [PATCH 2/6] Add lvmcache function to lookup a vgname from a pvid.
In-Reply-To: <1273581370-13528-2-git-send-email-dwysocha@redhat.com>
References: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1273581370-13528-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   25 +++++++++++++++++++++++++
 lib/cache/lvmcache.h |    1 +
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2a5f2d7..bcff43d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -499,6 +499,31 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 	return info;
 }
 
+char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
+{
+	struct lvmcache_info *info;
+	char *vgname;
+
+	if (!device_from_pvid(cmd, pvid, NULL)) {
+		char buffer[64] __attribute((aligned(8)));
+
+		if (!id_write_format(pvid, buffer, sizeof(buffer)))
+			buffer[0] = '\0';
+		log_error("Couldn't find device with uuid %s.", buffer);
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
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 5b0ca73..55c2e7a 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -97,6 +97,7 @@ struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
 				unsigned *scan_done_once);
 const char *pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
+char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
-- 
1.6.0.6


