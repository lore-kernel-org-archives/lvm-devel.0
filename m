From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 20 Nov 2014 16:49:54 +0000 (UTC)
Subject: master - cleanup: drop unused vars
Message-ID: <20141120164954.9397D60E32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=089bdc0be479dce8a886a50606b4bbb108614fb2
Commit:        089bdc0be479dce8a886a50606b4bbb108614fb2
Parent:        71271cf9053bd4fb6d6dbf1c4240fcb105165084
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 20 17:49:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 20 17:49:32 2014 +0100

cleanup: drop unused vars

---
 libdm/libdm-config.c |    2 +-
 tools/toollib.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 93e2887..91aa970 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -522,7 +522,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 
-	struct dm_config_node *root, *n, *l = NULL;
+	struct dm_config_node *root, *n;
 	struct dm_config_value *value;
 	char *str;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 2015ca1..00512a3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1126,7 +1126,7 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 	const char *str;
 	struct arg_value_group_list *group;
 	struct dm_config_tree *result = NULL, *prev = NULL, *current = NULL;
-	struct dm_config_node *cn, *last = NULL;
+	struct dm_config_node *cn;
 	int ok = 0;
 
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {


