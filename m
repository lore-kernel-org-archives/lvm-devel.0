From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 26 Nov 2010 16:50:53 +0100
Subject: [PATCH] Scan also special metadata areas (like metadata/dirs) in fmt_from_vgname
Message-ID: <4CEFD75D.6060509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We reread labels and metadata from raw devices in fmt_from_vgname function,
but we forgot to read special metadata areas? (like dirs defined by metadata/dirs
config setting) Anyway, can someone remind me why we do scanning inside this fn
at all?

Without this patch, we will fail to find a VG when metadata/dirs is only
used and there are no other metadata areas (which is itself a strange situation,
but see also https://www.redhat.com/archives/linux-lvm/2010-November/msg00090.html)

Peter
---
 lib/cache/lvmcache.c    |   10 +++++++++-
 lib/cache/lvmcache.h    |    4 +++-
 lib/metadata/metadata.c |   14 +++++++-------
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 60edcec..eebaaea 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -366,7 +366,9 @@ struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname, const char *vgid)
 	return vginfo;
 }
 
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
+const struct format_type *fmt_from_vgname(struct cmd_context *cmd,
+					  const char *vgname,
+					  const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -375,6 +377,7 @@ const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
 	struct dm_list devs;
 	struct device_list *devl;
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
+	struct format_type *fmt;
 
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 		return NULL;
@@ -400,6 +403,11 @@ const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
 		dm_free(devl);
 	}
 
+	dm_list_iterate_items(fmt, &cmd->formats) {
+		if (fmt->ops->scan && !fmt->ops->scan(fmt))
+			return NULL;
+	}
+
 	/* If vginfo changed, caller needs to rescan */
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid_found)) ||
 	    strncmp(vginfo->vgid, vgid_found, ID_LEN))
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 28f8541..2faec88 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -88,7 +88,9 @@ void lvmcache_unlock_vgname(const char *vgname);
 int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid);
+const struct format_type *fmt_from_vgname(struct cmd_context *cmd,
+					  const char *vgname,
+					  const char *vgid);
 struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 780b806..d09c693 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2698,13 +2698,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!(fmt = fmt_from_vgname(vgname, vgid))) {
+	if (!(fmt = fmt_from_vgname(cmd, vgname, vgid))) {
 		lvmcache_label_scan(cmd, 0);
-		if (!(fmt = fmt_from_vgname(vgname, vgid))) {
+		if (!(fmt = fmt_from_vgname(cmd, vgname, vgid))) {
 			if (memlock())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
-			if (!(fmt = fmt_from_vgname(vgname, vgid)))
+			if (!(fmt = fmt_from_vgname(cmd, vgname, vgid)))
 				return_NULL;
 		}
 	}
@@ -2863,7 +2863,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (memlock())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
-		if (!(fmt = fmt_from_vgname(vgname, vgid)))
+		if (!(fmt = fmt_from_vgname(cmd, vgname, vgid)))
 			return_NULL;
 
 		if (precommitted && !(fmt->features & FMT_PRECOMMIT))
@@ -3788,9 +3788,9 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!fmt_from_vgname(vgname, NULL)) {
+	if (!fmt_from_vgname(cmd, vgname, NULL)) {
 		lvmcache_label_scan(cmd, 0);
-		if (!fmt_from_vgname(vgname, NULL)) {
+		if (!fmt_from_vgname(cmd, vgname, NULL)) {
 			if (memlock()) {
 				/*
 				 * FIXME: Disallow calling this function if
@@ -3800,7 +3800,7 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 				return FAILED_LOCKING;
 			}
 			lvmcache_label_scan(cmd, 2);
-			if (!fmt_from_vgname(vgname, NULL)) {
+			if (!fmt_from_vgname(cmd, vgname, NULL)) {
 				/* vgname not found after scanning */
 				return SUCCESS;
 			}


