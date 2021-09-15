From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:26 +0000 (GMT)
Subject: main - clang: keep final_opts_list initialized for all paths
Message-ID: <20210915132626.7A5953858413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a5c79d1d18cf887646edbdd7e798d93a2f9783f
Commit:        1a5c79d1d18cf887646edbdd7e798d93a2f9783f
Parent:        9c5d2874a73d884ede9bb3f0583b238f8764ab92
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 14 19:25:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

clang: keep final_opts_list initialized for all paths

Likely impossible path, but just keep always initilized.
---
 tools/reporter.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 9fb8b128c..54a538d04 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -828,7 +828,7 @@ static int _get_report_options(struct cmd_context *cmd,
 {
 	int action;
 	struct arg_value_group_list *current_group;
-	struct dm_list *final_opts_list[REPORT_IDX_COUNT];
+	struct dm_list *final_opts_list[REPORT_IDX_COUNT] = { NULL };
 	struct dm_list *opts_list = NULL;
 	struct dm_str_list *sl;
 	struct dm_pool *mem;


