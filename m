From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 19:47:18 +0000 (GMT)
Subject: main - fix empty mem pool leak
Message-ID: <20210603194718.DF7F2386FC05@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c43f2f8ae08ed0555a300764c8644ea56f4f41e2
Commit:        c43f2f8ae08ed0555a300764c8644ea56f4f41e2
Parent:        fe05828e7e4c78a1ed4430ce4057c785d0b898a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 3 14:44:55 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 14:46:33 2021 -0500

fix empty mem pool leak

of "config" when LVM_SYSTEM_DIR=""
---
 lib/commands/toolcontext.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 296618686..e2be89d0f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -966,8 +966,8 @@ static void _destroy_config(struct cmd_context *cmd)
 	/* CONFIG_FILE/CONFIG_MERGED_FILES */
 	if ((cft = remove_config_tree_by_source(cmd, CONFIG_MERGED_FILES)))
 		config_destroy(cft);
-	else
-		remove_config_tree_by_source(cmd, CONFIG_FILE);
+	else if ((cft = remove_config_tree_by_source(cmd, CONFIG_FILE)))
+		config_destroy(cft);
 
 	dm_list_iterate_items(cfl, &cmd->config_files)
 		config_destroy(cfl->cft);


