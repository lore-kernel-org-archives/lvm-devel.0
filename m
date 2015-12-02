From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:17 +0000 (UTC)
Subject: master - vg_read: look up vgid from name
Message-ID: <20151202000817.EC82B60AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88cef47b18cd8b03b090b4b17220b1ddf45aba03
Commit:        88cef47b18cd8b03b090b4b17220b1ddf45aba03
Parent:        1e43ec15ce0a34ac29c82f232f21a2b0ea7f3a26
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 15:12:01 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:18:48 2015 -0600

vg_read: look up vgid from name

After recent changes to process_each, vg_read() is usually
given both the vgname and vgid for the intended VG.

However, in some cases vg_read() is given a vgid with
no vgname, or is given a vgname with no vgid.

When given a vgid with no vgname, vg_read() uses lvmcache
to look up the vgname using the vgid.  If the vgname is
not found, vg_read() fails.

When given a vgname with no vgid, vg_read() should also
use lvmcache to look up the vgid using the vgname.
If the vgid is not found, vg_read() fails.

If the lvmcache lookup finds multiple vgids for the
vgname, then the lookup fails, causing vg_read() to fail
because the intended VG is uncertain.

Usually, both vgname and vgid for the intended VG are passed
to vg_read(), which means the lvmcache translations
between vgname and vgid are not done.
---
 lib/cache/lvmcache.c    |   17 +++++++++++++++++
 lib/cache/lvmcache.h    |    1 +
 lib/metadata/metadata.c |   10 +++++++++-
 3 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 985ff43..e375388 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -614,6 +614,23 @@ const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid)
 	return vgname;
 }
 
+const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
+		return_NULL;
+
+	if (!vginfo->next)
+		return dm_pool_strdup(cmd->mem, vginfo->vgid);
+
+	/*
+	 * There are multiple VGs with this name to choose from.
+	 * Return an error because we don't know which VG is intended.
+	 */
+	return NULL;
+}
+
 static int _info_is_valid(struct lvmcache_info *info)
 {
 	if (info->status & CACHE_INVALID)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index b968a12..509cfd6 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -99,6 +99,7 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only);
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
+const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname);
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once, uint64_t *label_sector);
 const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bf030d3..ec645ae 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3617,8 +3617,16 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* Now determine the correct vgname if none was supplied */
-	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
+	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+		log_debug_metadata("Cache did not find VG name from vgid %.32s", vgid);
 		return_NULL;
+	}
+
+	/* Determine the correct vgid if none was supplied */
+	if (!vgid && !(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
+		log_debug_metadata("Cache did not find VG vgid from name %s", vgname);
+		return_NULL;
+	}
 
 	if (use_precommitted && !(fmt->features & FMT_PRECOMMIT))
 		use_precommitted = 0;


