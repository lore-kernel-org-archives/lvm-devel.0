From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:39 +0000 (UTC)
Subject: dev-peter-config-profiles - refactor: factor out common part of the code to open and read config files
Message-ID: <20130626145539.DF6D261131@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e09cffe14e6710ba3bb3598a6719ff3b2d70a440
Commit:        e09cffe14e6710ba3bb3598a6719ff3b2d70a440
Parent:        9233e6d0bb5b3b21cc67fd0baae3fb4cb099bdcb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:25:23 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:49 2013 +0200

refactor: factor out common part of the code to open and read config files

---
 lib/commands/toolcontext.c |   57 +++++++++++++++++++++++++------------------
 1 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 79c25a5..e0da663 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -528,11 +528,41 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	return 1;
 }
 
+static struct dm_config_tree *_open_and_read_config_file(const char *config_file)
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
+
 static int _load_config_file(struct cmd_context *cmd, const char *tag)
 {
 	static char config_file[PATH_MAX] = "";
 	const char *filler = "";
-	struct stat info;
 	struct config_tree_list *cfl;
 
 	if (*tag)
@@ -549,32 +579,11 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
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
+	if (!(cfl->cft = _open_and_read_config_file(config_file)))
+		return_0;
 
 	dm_list_add(&cmd->config_files, &cfl->list);
 
-      out:
 	if (*tag) {
 		if (!_init_tags(cmd, cfl->cft))
 			return_0;


