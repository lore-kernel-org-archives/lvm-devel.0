From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:24 +0000 (UTC)
Subject: master - refactor: factor out common part of the code to open and read config files
Message-ID: <20130702133224.CA76B60DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d784753c08b24e02ea0e6c1423342b355037d86
Commit:        2d784753c08b24e02ea0e6c1423342b355037d86
Parent:        b31725d0ae0539f2d13a2454849de557fe91c4fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:25:23 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:19:08 2013 +0200

refactor: factor out common part of the code to open and read config files

---
 lib/commands/toolcontext.c |   26 ++------------------------
 lib/config/config.c        |   30 ++++++++++++++++++++++++++++++
 lib/config/config.h        |    1 +
 3 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 79c25a5..c7b2451 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -532,7 +532,6 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 {
 	static char config_file[PATH_MAX] = "";
 	const char *filler = "";
-	struct stat info;
 	struct config_tree_list *cfl;
 
 	if (*tag)
@@ -549,32 +548,11 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 		return 0;
 	}
 
-	if (!(cfl->cft = config_file_open(config_file, 0))) {
-		log_error("config_tree allocation failed");
-		return 0;
-	}
-
-	/* Is there a config file? */
-	if (stat(config_file, &info) == -1) {
-		if (errno == ENOENT) {
-			dm_list_add(&cmd->config_files, &cfl->list);
-			goto out;
-		}
-		log_sys_error("stat", config_file);
-		config_file_destroy(cfl->cft);
-		return 0;
-	}
-
-	log_very_verbose("Loading config file: %s", config_file);
-	if (!config_file_read(cfl->cft)) {
-		log_error("Failed to load config file %s", config_file);
-		config_file_destroy(cfl->cft);
-		return 0;
-	}
+	if (!(cfl->cft = config_file_open_and_read(config_file)))
+		return_0;
 
 	dm_list_add(&cmd->config_files, &cfl->list);
 
-      out:
 	if (*tag) {
 		if (!_init_tags(cmd, cfl->cft))
 			return_0;
diff --git a/lib/config/config.c b/lib/config/config.c
index 7b6ac7b..aec1588 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -170,6 +170,36 @@ void config_file_destroy(struct dm_config_tree *cft)
 	dm_config_destroy(cft);
 }
 
+struct dm_config_tree *config_file_open_and_read(const char *config_file)
+{
+	struct dm_config_tree *cft;
+	struct stat info;
+
+	if (!(cft = config_file_open(config_file, 0))) {
+		log_error("config_tree allocation failed");
+		return NULL;
+	}
+
+	/* Is there a config file? */
+	if (stat(config_file, &info) == -1) {
+		if (errno == ENOENT)
+			return cft;
+		log_sys_error("stat", config_file);
+		goto bad;
+	}
+
+	log_very_verbose("Loading config file: %s", config_file);
+	if (!config_file_read(cft)) {
+		log_error("Failed to load config file %s", config_file);
+		goto bad;
+	}
+
+	return cft;
+bad:
+	config_file_destroy(cft);
+	return NULL;
+}
+
 /*
  * Returns config tree if it was removed.
  */
diff --git a/lib/config/config.h b/lib/config/config.h
index 155d69a..0403924 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -120,6 +120,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
 int config_file_read(struct dm_config_tree *cft);
+struct dm_config_tree *config_file_open_and_read(const char *config_file);
 int config_write(struct dm_config_tree *cft,
 		 int withcomment, int withversion,
 		 const char *file, int argc, char **argv);


