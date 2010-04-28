From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 28 Apr 2010 11:55:39 -0400
Subject: [PATCH 2/5] Add lvmcache function to lookup a vgname from a pvid.
In-Reply-To: <1272470142-13843-2-git-send-email-dwysocha@redhat.com>
References: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
	<1272470142-13843-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1272470142-13843-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   17 +++++++++++++++++
 lib/cache/lvmcache.h |    1 +
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f53b4c3..653b13e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -499,6 +499,23 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 	return info;
 }
 
+char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
+{
+	struct lvmcache_info *info;
+	char *vgname;
+
+	info = info_from_pvid(pvid, 0);
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


