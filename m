From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Mar 2015 12:46:47 +0000 (UTC)
Subject: master - config: use timestamp with nanosecond precision
Message-ID: <20150318124647.58B1F60C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1260b86b2b76f5b1ab5fa6c0c324d8d6f3ba2173
Commit:        1260b86b2b76f5b1ab5fa6c0c324d8d6f3ba2173
Parent:        6606b1bff3fba90cc7af92dcda1c6eafdbf5e200
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 18 10:59:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 18 13:42:56 2015 +0100

config: use timestamp with nanosecond precision

Since kernel 2.6 we can use more precise timestamping,
so e.g. we could better recognize configs are slightly
older then generated .cache file.
---
 WHATS_NEW                       |    1 +
 lib/commands/toolcontext.c      |   14 +++++++++-----
 lib/config/config.c             |   13 ++++++++-----
 lib/config/config.h             |    2 +-
 lib/filters/filter-persistent.c |   10 ++++++----
 5 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0ce81fb..51307cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Measure configuration timestamps with nanoseconds when available.
   Disable lvchange of major and minor of pool LVs.
   Fix pvscan --cache to not scan and read ignored metadata areas on PVs.
   Add After=iscsi-shutdown.service to blk-availability.service systemd unit.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 25d9826..54dcf86 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1140,6 +1140,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	struct dev_filter *filter = NULL, *filter_components[2] = {0};
 	struct stat st;
 	const struct dm_config_node *cn;
+	struct timespec ts, cts;
 
 	cmd->dump_filter = 0;
 
@@ -1212,11 +1213,14 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	 */
 	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL) &&
 	    load_persistent_cache && !cmd->is_long_lived &&
-	    !stat(dev_cache, &st) &&
-	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
-	    !persistent_filter_load(cmd->filter, NULL))
-		log_verbose("Failed to load existing device cache from %s",
-			    dev_cache);
+	    !stat(dev_cache, &st)) {
+		lvm_stat_ctim(&ts, &st);
+		cts = config_file_timestamp(cmd->cft);
+		if (timespeccmp(&ts, &cts, >) &&
+		    !persistent_filter_load(cmd->filter, NULL))
+			log_verbose("Failed to load existing device cache from %s",
+				    dev_cache);
+	}
 
 	return 1;
 bad:
diff --git a/lib/config/config.c b/lib/config/config.c
index 5de6df6..b635654 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -53,7 +53,7 @@ struct config_file {
 
 struct config_source {
 	config_source_t type;
-	time_t timestamp;
+	struct timespec timestamp;
 	union {
 		struct config_file *file;
 		struct config_file *profile;
@@ -173,7 +173,7 @@ int config_file_check(struct dm_config_tree *cft, const char **filename, struct
 		return 0;
 	}
 
-	cs->timestamp = info->st_ctime;
+	lvm_stat_ctim(&cs->timestamp, info);
 	cf->exists = 1;
 	cf->st_size = info->st_size;
 
@@ -193,6 +193,7 @@ int config_file_changed(struct dm_config_tree *cft)
 	struct config_source *cs = dm_config_get_custom(cft);
 	struct config_file *cf;
 	struct stat info;
+	struct timespec ts;
 
 	if (cs->type != CONFIG_FILE) {
 		log_error(INTERNAL_ERROR "config_file_changed: expected file config source, "
@@ -226,7 +227,9 @@ int config_file_changed(struct dm_config_tree *cft)
 	}
 
 	/* Unchanged? */
-	if (cs->timestamp == info.st_ctime && cf->st_size == info.st_size)
+	lvm_stat_ctim(&ts, &info);
+	if ((timespeccmp(&cs->timestamp, &ts, ==)) &&
+	    cf->st_size == info.st_size)
 		return 0;
 
       reload:
@@ -594,7 +597,7 @@ int config_file_read(struct dm_config_tree *cft)
 	return r;
 }
 
-time_t config_file_timestamp(struct dm_config_tree *cft)
+struct timespec config_file_timestamp(struct dm_config_tree *cft)
 {
 	struct config_source *cs = dm_config_get_custom(cft);
 	return cs->timestamp;
@@ -1473,7 +1476,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	cs = dm_config_get_custom(cft);
 	csn = dm_config_get_custom(newdata);
 
-	if (cs && csn && (cs->timestamp < csn->timestamp))
+	if (cs && csn && timespeccmp(&cs->timestamp, &csn->timestamp, <))
 		cs->timestamp = csn->timestamp;
 
 	return 1;
diff --git a/lib/config/config.h b/lib/config/config.h
index 50ea361..5fe6a9f 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -215,7 +215,7 @@ int config_write(struct dm_config_tree *cft, struct config_def_tree_spec *tree_s
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
 void config_destroy(struct dm_config_tree *cft);
 
-time_t config_file_timestamp(struct dm_config_tree *cft);
+struct timespec config_file_timestamp(struct dm_config_tree *cft);
 int config_file_changed(struct dm_config_tree *cft);
 int config_file_check(struct dm_config_tree *cft, const char **filename, struct stat *info);
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index b4a7683..8c7b79f 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -22,7 +22,7 @@ struct pfilter {
 	char *file;
 	struct dm_hash_table *devices;
 	struct dev_filter *real;
-	time_t ctime;
+	struct timespec ctime;
 	struct dev_types *dt;
 };
 
@@ -106,7 +106,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	}
 
 	if (!stat(pf->file, &info))
-		pf->ctime = info.st_ctime;
+		lvm_stat_ctim(&pf->ctime, &info);
 	else {
 		log_very_verbose("%s: stat failed: %s", pf->file,
 				 strerror(errno));
@@ -177,6 +177,7 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 	struct pfilter *pf;
 	char *tmp_file;
 	struct stat info, info2;
+	struct timespec ts;
 	struct dm_config_tree *cft = NULL;
 	FILE *fp;
 	int lockfd;
@@ -227,7 +228,8 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 	/*
 	 * If file contents changed since we loaded it, merge new contents
 	 */
-	if (merge_existing && info.st_ctime != pf->ctime)
+	lvm_stat_ctim(&ts, &info);
+	if (merge_existing && timespeccmp(&ts, &pf->ctime, !=))
 		/* Keep cft open to avoid losing lock */
 		persistent_filter_load(f, &cft);
 
@@ -352,7 +354,7 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 
 	/* Only merge cache file before dumping it if it changed externally. */
 	if (!stat(pf->file, &info))
-		pf->ctime = info.st_ctime;
+		lvm_stat_ctim(&pf->ctime, &info);
 
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;


