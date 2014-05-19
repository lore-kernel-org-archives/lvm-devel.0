From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 May 2014 13:43:51 +0000 (UTC)
Subject: master - config: add CONFIG_FILE_SPECIAL config source id
Message-ID: <20140519134351.1B4FD60CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff9d27a1c71785abd6aa71eddc7018dd56807517
Commit:        ff9d27a1c71785abd6aa71eddc7018dd56807517
Parent:        ecccb759048c143a4e9e2e1b96afb6b6178a9325
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 10:58:28 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 15:37:41 2014 +0200

config: add CONFIG_FILE_SPECIAL config source id

Add CONFIG_FILE_SPECIAL config source id to make a difference between
real configuration tree (like lvm.conf and tag configs) and special purpose
configuration tree (like LVM metadata, persistent filter).

This makes it easier to attach correct customized data to the config
tree that is created out of the source then.
---
 lib/config/config.c             |   29 ++++++++++++++++++++---------
 lib/config/config.h             |    3 ++-
 lib/filters/filter-persistent.c |    2 +-
 lib/format_text/import.c        |    4 ++--
 4 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 04f917d..b0880a6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -38,7 +38,8 @@ static const char *_config_source_names[] = {
 	[CONFIG_FILE] = "file",
 	[CONFIG_MERGED_FILES] = "merged files",
 	[CONFIG_STRING] = "string",
-	[CONFIG_PROFILE] = "profile"
+	[CONFIG_PROFILE] = "profile",
+	[CONFIG_FILE_SPECIAL] = "special purpose"
 };
 
 struct config_file {
@@ -100,7 +101,9 @@ struct dm_config_tree *config_open(config_source_t source,
 		goto fail;
 	}
 
-	if ((source == CONFIG_FILE) || (source == CONFIG_PROFILE)) {
+	if ((source == CONFIG_FILE) ||
+	    (source == CONFIG_FILE_SPECIAL) ||
+	    (source == CONFIG_PROFILE)) {
 		if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
 			log_error("Failed to allocate config file.");
 			goto fail;
@@ -133,9 +136,12 @@ int config_file_check(struct dm_config_tree *cft, const char **filename, struct
 	struct config_file *cf;
 	struct stat _info;
 
-	if ((cs->type != CONFIG_FILE) && (cs->type != CONFIG_PROFILE)) {
-		log_error(INTERNAL_ERROR "config_file_check: expected file or profile config source, "
-					 "found %s config source.", _config_source_names[cs->type]);
+	if ((cs->type != CONFIG_FILE) &&
+	    (cs->type != CONFIG_PROFILE) &&
+	    (cs->type != CONFIG_FILE_SPECIAL)) {
+		log_error(INTERNAL_ERROR "config_file_check: expected file, special file or "
+					 "profile config source, found %s config source.",
+					 _config_source_names[cs->type]);
 		return 0;
 	}
 
@@ -227,7 +233,9 @@ void config_destroy(struct dm_config_tree *cft)
 
 	cs = dm_config_get_custom(cft);
 
-	if ((cs->type == CONFIG_FILE) || (cs->type == CONFIG_PROFILE)) {
+	if ((cs->type == CONFIG_FILE) ||
+	    (cs->type == CONFIG_PROFILE) ||
+	    (cs->type == CONFIG_FILE_SPECIAL)) {
 		cf = cs->source.file;
 		if (cf && cf->dev)
 			if (!dev_close(cf->dev))
@@ -377,9 +385,12 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 	char *buf = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
 
-	if ((cs->type != CONFIG_FILE) && (cs->type != CONFIG_PROFILE)) {
-		log_error(INTERNAL_ERROR "config_file_read_fd: expected file or profile config source, "
-					 "found %s config source.", _config_source_names[cs->type]);
+	if ((cs->type != CONFIG_FILE) &&
+	    (cs->type != CONFIG_PROFILE) &&
+	    (cs->type != CONFIG_FILE_SPECIAL)) {
+		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
+					 "or profile config source, found %s config source.",
+					 _config_source_names[cs->type]);
 		return 0;
 	}
 
diff --git a/lib/config/config.h b/lib/config/config.h
index b258d55..d78ea43 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -30,7 +30,8 @@ typedef enum {
 	CONFIG_FILE,		/* one file config */
 	CONFIG_MERGED_FILES,	/* config that is a result of merging more config files */
 	CONFIG_STRING,		/* config string typed on cmdline using '--config' arg */
-	CONFIG_PROFILE		/* profile config */
+	CONFIG_PROFILE,		/* profile config */
+	CONFIG_FILE_SPECIAL	/* special purpose file config (e.g. metadata, persistent filter...) */
 } config_source_t;
 
 struct profile {
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 14a3480..7eaae71 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -114,7 +114,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 		return_0;
 	}
 
-	if (!(cft = config_open(CONFIG_FILE, pf->file, 1)))
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, pf->file, 1)))
 		return_0;
 
 	if (!config_file_read(cft))
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 6b7d589..1b1f332 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -46,7 +46,7 @@ const char *text_vgname_import(const struct format_type *fmt,
 
 	_init_text_import();
 
-	if (!(cft = config_open(CONFIG_FILE, NULL, 0)))
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
 		return_NULL;
 
 	if ((!dev && !config_file_read(cft)) ||
@@ -92,7 +92,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	*desc = NULL;
 	*when = 0;
 
-	if (!(cft = config_open(CONFIG_FILE, file, 0)))
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
 		return_NULL;
 
 	if ((!dev && !config_file_read(cft)) ||


