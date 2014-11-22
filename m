From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 23:50:53 +0000 (UTC)
Subject: master - cleanup: add missing error path check
Message-ID: <20141122235053.E4ACD60F68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6a7a3a074692a66d065d19e58e6e170233ab9e9
Commit:        a6a7a3a074692a66d065d19e58e6e170233ab9e9
Parent:        ccdea661fa2aab07fbd73bfd7f8fe5273acd71c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 22:39:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 23 00:49:04 2014 +0100

cleanup: add missing error path check

New code misses error path check.
---
 tools/toollib.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 00512a3..ddf2dcf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1149,7 +1149,8 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 			goto_out;
 	}
 
-	result = dm_config_flatten(current);
+	if (!(result = dm_config_flatten(current)))
+		goto_out;
 
 	if (!(cn = dm_config_create_node(result, "policy_settings")))
 		goto_out;


