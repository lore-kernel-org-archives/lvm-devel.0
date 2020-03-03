From: David Teigland <teigland@sourceware.org>
Date: Tue, 3 Mar 2020 13:26:17 -0500
Subject: master - hints: free hint list in error exit path
Message-ID: <202003031826.023IQHu3010515@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f50e7ce76c0c6b2745d0ed2a766f46cea07f310c
Commit:        f50e7ce76c0c6b2745d0ed2a766f46cea07f310c
Parent:        c392ccaa470dbf1481cbf1c9e899ce9c59f2caea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 3 12:25:34 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 12:25:34 2020 -0600

hints: free hint list in error exit path

---
 lib/label/hints.c | 14 +++++++++++++-
 lib/label/hints.h |  2 ++
 lib/label/label.c | 12 +-----------
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index f1a1519..48fb661 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -356,6 +356,16 @@ void hints_exit(struct cmd_context *cmd)
 	return _unlock_hints(cmd);
 }
 
+void free_hints(struct dm_list *hints)
+{
+	struct hint *hint, *hint2;
+
+	dm_list_iterate_items_safe(hint, hint2, hints) {
+		dm_list_del(&hint->list);
+		free(hint);
+	}
+}
+
 static struct hint *_find_hint_name(struct dm_list *hints, const char *name)
 {
 	struct hint *hint;
@@ -787,8 +797,10 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	if (fclose(fp))
 		stack;
 
-	if (!ret)
+	if (!ret) {
+		free_hints(hints);
 		return 0;
+	}
 
 	if (!found)
 		return 1;
diff --git a/lib/label/hints.h b/lib/label/hints.h
index 7f47648..5114334 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -24,6 +24,8 @@ struct hint {
 	unsigned chosen:1; /* this hint's dev was chosen for scanning */
 };
 
+void free_hints(struct dm_list *hints);
+
 int write_hint_file(struct cmd_context *cmd, int newhints);
 
 void clear_hint_file(struct cmd_context *cmd);
diff --git a/lib/label/label.c b/lib/label/label.c
index 328e4e7..0458313 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -857,16 +857,6 @@ static int _setup_bcache(void)
 	return 1;
 }
 
-static void _free_hints(struct dm_list *hints)
-{
-	struct hint *hint, *hint2;
-
-	dm_list_iterate_items_safe(hint, hint2, hints) {
-		dm_list_del(&hint->list);
-		free(hint);
-	}
-}
-
 /*
  * We don't know how many of num_devs will be PVs that we need to
  * keep open, but if it's greater than the soft limit, then we'll
@@ -1165,7 +1155,7 @@ int label_scan(struct cmd_context *cmd)
 		if (!validate_hints(cmd, &hints_list)) {
 			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
 			_scan_list(cmd, cmd->filter, &all_devs, NULL);
-			_free_hints(&hints_list);
+			free_hints(&hints_list);
 			using_hints = 0;
 			create_hints = 0;
 		} else {



