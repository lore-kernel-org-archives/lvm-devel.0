From: David Teigland <teigland@sourceware.org>
Date: Mon,  1 Nov 2021 21:02:31 +0000 (GMT)
Subject: main - hints: remove the cmd hints list
Message-ID: <20211101210231.9B9FE385801F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d0964d127ea62da480cafc91fefe403dda86870
Commit:        5d0964d127ea62da480cafc91fefe403dda86870
Parent:        b65a2c3f3a76739fb75a4a3a868cc9f143740052
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 1 16:01:09 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 1 16:01:45 2021 -0500

hints: remove the cmd hints list

which is no longer used after commit
"toollib: remove all devices list from process_each_pv"
---
 lib/commands/toolcontext.c | 2 --
 lib/commands/toolcontext.h | 1 -
 lib/label/hints.c          | 1 -
 lib/label/label.c          | 8 ++------
 4 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 105aecd5d..1b7170de1 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1605,7 +1605,6 @@ struct cmd_context *create_config_context(void)
 
 	dm_list_init(&cmd->config_files);
 	dm_list_init(&cmd->tags);
-	dm_list_init(&cmd->hints);
 
 	if (!_init_lvm_conf(cmd))
 		goto_out;
@@ -1670,7 +1669,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
-	dm_list_init(&cmd->hints);
 	dm_list_init(&cmd->config_files);
 	label_init();
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 701b7a739..356c79f8a 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -206,7 +206,6 @@ struct cmd_context {
 	 * Devices and filtering.
 	 */
 	struct dev_filter *filter;
-	struct dm_list hints;
 	struct dm_list use_devices;		/* struct dev_use for each entry in devices file */
 	const char *md_component_checks;
 	const char *search_for_devnames;	/* config file setting */
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 3dba9f8ec..e444a0c82 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -365,7 +365,6 @@ static void _unlock_hints(struct cmd_context *cmd)
 
 void hints_exit(struct cmd_context *cmd)
 {
-	free_hints(&cmd->hints);
 	if (_hints_fd == -1)
 		return;
 	_unlock_hints(cmd);
diff --git a/lib/label/label.c b/lib/label/label.c
index 3cd912270..479a5037a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1207,8 +1207,6 @@ int label_scan(struct cmd_context *cmd)
 			 (unsigned long long)want_size_kb);
 	}
 
-	dm_list_init(&cmd->hints);
-
 	/*
 	 * If we're using hints to limit which devs we scanned, verify
 	 * that those hints were valid, and if not we need to scan the
@@ -1220,18 +1218,16 @@ int label_scan(struct cmd_context *cmd)
 			_scan_list(cmd, cmd->filter, &all_devs, 0, NULL);
 			/* scan_devs are the devs that have been scanned */
 			dm_list_splice(&scan_devs, &all_devs);
-			free_hints(&hints_list);
 			using_hints = 0;
 			create_hints = 0;
 			/* invalid hints means a new dev probably appeared and
 			   we should search for any missing pvids again. */
 			unlink_searched_devnames(cmd);
-		} else {
-			/* The hints may be used by another device iteration. */
-			dm_list_splice(&cmd->hints, &hints_list);
 		}
 	}
 
+	free_hints(&hints_list);
+
 	/*
 	 * Check if the devices_file content is up to date and
 	 * if not update it.


