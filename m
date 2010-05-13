From: Milan Broz <mbroz@redhat.com>
Date: Thu, 13 May 2010 14:52:45 +0200
Subject: [PATCH] Do not merge old device cache after we run full scan.
Message-ID: <1273755165-12018-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Courrently if clvmd is running and user issues vgscan,
the device cache file is dumped both in vgscan and clvmd process.

Unfortunately, clvmd calls lvmcache_label_scan,
it properly destroys persistent filter, but during
persistent_filter_dump it merges old cache content back!

This causes that change in filters is not properly propagated
into device cache after vgscan on cluster.
(Only new devices are added.)

https://bugzilla.redhat.com/show_bug.cgi?id=591861

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c            |    2 +-
 lib/commands/toolcontext.c      |    2 +-
 lib/filters/filter-persistent.c |    4 ++--
 lib/filters/filter-persistent.h |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e31a4e..940c61f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -567,7 +567,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	 * device cache for the benefit of short-lived processes.
 	 */
 	if (full_scan == 2 && cmd->is_long_lived && cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
+		persistent_filter_dump(cmd->filter, 0);
 
 	r = 1;
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 69c79e7..c780d26 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1341,7 +1341,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 void destroy_toolcontext(struct cmd_context *cmd)
 {
 	if (cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
+		persistent_filter_dump(cmd->filter, 1);
 
 	archive_exit(cmd);
 	backup_exit(cmd);
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 9243a94..4cb0d7d 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -168,7 +168,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 		fprintf(fp, "\n\t]\n");
 }
 
-int persistent_filter_dump(struct dev_filter *f)
+int persistent_filter_dump(struct dev_filter *f, int merge_existing)
 {
 	struct pfilter *pf;
 	char *tmp_file;
@@ -220,7 +220,7 @@ int persistent_filter_dump(struct dev_filter *f)
 	/*
 	 * If file contents changed since we loaded it, merge new contents
 	 */
-	if (info.st_ctime != pf->ctime)
+	if (merge_existing && info.st_ctime != pf->ctime)
 		/* Keep cft open to avoid losing lock */
 		persistent_filter_load(f, &cft);
 
diff --git a/lib/filters/filter-persistent.h b/lib/filters/filter-persistent.h
index 4b0fc55..a7f1245 100644
--- a/lib/filters/filter-persistent.h
+++ b/lib/filters/filter-persistent.h
@@ -23,6 +23,6 @@ struct dev_filter *persistent_filter_create(struct dev_filter *f,
 
 int persistent_filter_wipe(struct dev_filter *f);
 int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out);
-int persistent_filter_dump(struct dev_filter *f);
+int persistent_filter_dump(struct dev_filter *f, int merge_existing);
 
 #endif
-- 
1.7.1


