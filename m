From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:26 +0000 (UTC)
Subject: master - cleanup: drop log_suppress(2) usage
Message-ID: <20151203172226.F34E360C8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7978c5ab68b1dabfa886fa437646edfcf270b82
Commit:        e7978c5ab68b1dabfa886fa437646edfcf270b82
Parent:        f40b3ba1e904f6c6a3e1264e6d734f558ec731d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 17:51:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:02:34 2015 +0100

cleanup: drop log_suppress(2) usage

No longer need to use  log_suppress(2) instance so dropped.
---
 WHATS_NEW                     |    1 +
 lib/format_text/import_vsn1.c |   31 ++++++++++++++++---------------
 lib/log/log.c                 |    3 ---
 3 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c39eae4..49d1dd6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Dropped internal usage of log_suppress(2).
   Cleaned logging code for buffer size usage.
   Added internal id_read_format_try() function to check and read valid UUID.
   Use dm_get_status_mirror() instead of individual parsers.
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 6aa227b..023c383 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1019,14 +1019,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 static void _read_desc(struct dm_pool *mem,
 		       const struct dm_config_tree *cft, time_t *when, char **desc)
 {
-	const char *d;
+	const char *str;
 	unsigned int u = 0u;
-	int old_suppress;
 
-	old_suppress = log_suppress(1);
-	d = dm_config_find_str_allow_empty(cft->root, "description", "");
-	log_suppress(old_suppress);
-	*desc = dm_pool_strdup(mem, d);
+	if (!dm_config_get_str(cft->root, "description", &str))
+		str = "";
+
+	*desc = dm_pool_strdup(mem, str);
 
 	(void) dm_config_get_uint32(cft->root, "creation_time", &u);
 	*when = u;
@@ -1043,12 +1042,12 @@ static int _read_vgname(const struct format_type *fmt, const struct dm_config_tr
 	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
 	const char *str;
-	int old_suppress;
 
-	old_suppress = log_suppress(2);
-	vgsummary->creation_host =
-	    dm_pool_strdup(mem, dm_config_find_str_allow_empty(cft->root, "creation_host", ""));
-	log_suppress(old_suppress);
+	if (!dm_config_get_str(cft->root, "creation_host", &str))
+		str = "";
+
+	if (!(vgsummary->creation_host = dm_pool_strdup(mem, str)))
+		return_0;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
@@ -1074,11 +1073,13 @@ static int _read_vgname(const struct format_type *fmt, const struct dm_config_tr
 		return 0;
 	}
 
-	if (dm_config_get_str(vgn, "system_id", &str))
-		vgsummary->system_id = dm_pool_strdup(mem, str);
+	if (dm_config_get_str(vgn, "system_id", &str) &&
+	    (!(vgsummary->system_id = dm_pool_strdup(mem, str))))
+		return_0;
 
-	if (dm_config_get_str(vgn, "lock_type", &str))
-		vgsummary->lock_type = dm_pool_strdup(mem, str);
+	if (dm_config_get_str(vgn, "lock_type", &str) &&
+	    (!(vgsummary->lock_type = dm_pool_strdup(mem, str))))
+		return_0;
 
 	return 1;
 }
diff --git a/lib/log/log.c b/lib/log/log.c
index fc52bdd..1c5ccd7 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -299,9 +299,6 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 		level = _LOG_FATAL;
 	}
 
-	if (_log_suppress == 2)
-		return;
-
 	if (level <= _LOG_ERR)
 		init_error_message_produced(1);
 


