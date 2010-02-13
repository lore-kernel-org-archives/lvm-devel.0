From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 19:51:48 -0500
Subject: [PATCH 1/3] Add a couple of lvmcache functions to aid in lookups by pvname.
In-Reply-To: <1266022310-19859-1-git-send-email-dwysocha@redhat.com>
References: <1266022310-19859-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1266022310-19859-2-git-send-email-dwysocha@redhat.com>
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

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h |    2 +
 2 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 35ee05b..074d591 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -499,6 +499,66 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 	return info;
 }
 
+struct lvmcache_info *info_from_pvname(const char *pvname, int valid_only)
+{
+	struct dm_hash_node *n;
+	struct lvmcache_info *info;
+	char *id;
+
+	if (!_pvid_hash | !pvname)
+		return_NULL;
+
+	/* FIXME: Might want to use another hash for PV names */
+	dm_hash_iterate(n, _pvid_hash) {
+		if (!dm_hash_get_data(_pvid_hash, n))
+			return_NULL;
+
+		id = dm_hash_get_key(_pvid_hash, n);
+		info = info_from_pvid(id, 1);
+
+		if (!strcmp(dev_name(info->dev), pvname)) {
+			if (valid_only && !_info_is_valid(info))
+				return NULL;
+			else
+				return info;
+		}
+	}
+
+	return NULL;
+}
+
+char *lvmcache_vgname_from_pvname(struct cmd_context *cmd, const char *pvname)
+{
+	struct dm_hash_node *n;
+	struct lvmcache_info *info;
+	char *id;
+	char *vgname;
+
+	if (!_pvid_hash | !pvname)
+		return_NULL;
+
+	/* FIXME: Might want to use another hash for PV names */
+	dm_hash_iterate(n, _pvid_hash) {
+		if (!dm_hash_get_data(_pvid_hash, n))
+			return_NULL;
+
+		id = dm_hash_get_key(_pvid_hash, n);
+		info = info_from_pvid(id, 1);
+
+		if (info->vginfo &&
+		    !strcmp(dev_name(info->dev), pvname)) {
+			if (!(vgname = dm_pool_alloc(cmd->mem, NAME_LEN+1))) {
+				log_errno(ENOMEM, "pvname allocation failed");
+				return NULL;
+			}
+			strncpy(vgname, info->vginfo->vgname, NAME_LEN);
+			return vgname;
+		}
+	}
+
+	return NULL;
+}
+
 static void _rescan_entry(struct lvmcache_info *info)
 {
 	struct label *label;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 2c14b6c..10d1b7f 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -94,6 +94,8 @@ struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid);
+char *lvmcache_vgname_from_pvname(struct cmd_context *cmd, const char *pvname);
+struct lvmcache_info *info_from_pvname(const char *pvname, int valid_only);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
-- 
1.6.0.6


