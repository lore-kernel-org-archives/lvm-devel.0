From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:00 +0000 (GMT)
Subject: stable-2.02 - cov: explicitely ignore function result
Message-ID: <20201016191100.BF9AE3857824@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c80bf4daa569c994073eb525b8550df614eed19
Commit:        7c80bf4daa569c994073eb525b8550df614eed19
Parent:        29436d6da9f219002e0fe650fde66ab8f86c7b43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 17:53:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

cov: explicitely ignore function result

---
 base/data-struct/radix-tree-adaptive.c | 2 +-
 tools/command.c                        | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index 3a46cc14b..121a2910c 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -1032,7 +1032,7 @@ void radix_tree_iterate(struct radix_tree *rt, uint8_t *kb, uint8_t *ke,
 {
 	struct lookup_result lr = _lookup_prefix(&rt->root, kb, ke);
 	if (lr.kb == ke || _prefix_chain_matches(&lr, ke))
-        	_iterate(lr.v, it);
+		(void) _iterate(lr.v, it);
 }
 
 //----------------------------------------------------------------
diff --git a/tools/command.c b/tools/command.c
index 2fef6a7a9..acb79c9c1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -367,7 +367,7 @@ static int _opt_str_to_num(struct command *cmd, char *str)
 	int i;
 	int first = 0, last = ARG_COUNT - 1, middle;
 
-	dm_strncpy(long_name, str, sizeof(long_name));
+	(void) dm_strncpy(long_name, str, sizeof(long_name));
 
 	if ((p = strstr(long_name, "_long")))
 		/*
@@ -802,7 +802,7 @@ static char *_get_oo_line(const char *str)
 	char str2[OO_NAME_LEN];
 	int i;
 
-	dm_strncpy(str2, str, sizeof(str2));
+	(void) dm_strncpy(str2, str, sizeof(str2));
 	if ((end = strchr(str2, ':')))
 		*end = '\0';
 	if ((end = strchr(str2, ',')))


