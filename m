From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 May 2020 22:27:24 +0000 (GMT)
Subject: master - hints: free hint structs on exit
Message-ID: <20200513222724.C1E92385DC14@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c095400de2f84511726cc8178800d19657b814d
Commit:        5c095400de2f84511726cc8178800d19657b814d
Parent:        2f29765e7fd1135d070310683cf486f07d041c81
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 13 17:19:41 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 13 17:20:16 2020 -0500

hints: free hint structs on exit

and free on a couple error paths.
---
 lib/commands/toolcontext.c | 1 +
 lib/label/hints.c          | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2bd7fabd2..63b6811e5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1598,6 +1598,7 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
+	dm_list_init(&cmd->hints);
 	dm_list_init(&cmd->config_files);
 	label_init();
 
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 349d5aaef..9546f4880 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -351,6 +351,7 @@ static void _unlock_hints(struct cmd_context *cmd)
 
 void hints_exit(struct cmd_context *cmd)
 {
+	free_hints(&cmd->hints);
 	if (_hints_fd == -1)
 		return;
 	return _unlock_hints(cmd);
@@ -1321,6 +1322,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 */
 	if (!_read_hint_file(cmd, &hints_list, &needs_refresh)) {
 		log_debug("get_hints: read fail");
+		free_hints(&hints_list);
 		_unlock_hints(cmd);
 		return 0;
 	}
@@ -1333,6 +1335,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 */
 	if (needs_refresh) {
 		log_debug("get_hints: needs refresh");
+		free_hints(&hints_list);
 
 		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;


