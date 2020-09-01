From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:06 +0000 (GMT)
Subject: master - cov: explicitely ignore function result
Message-ID: <20200901170206.7490D3951C26@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85e2c7e14dc888e54174222600fc38470ab035df
Commit:        85e2c7e14dc888e54174222600fc38470ab035df
Parent:        1705b439b1babfcae75b1d54d45eb7909cbccfb9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 17:53:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cov: explicitely ignore function result

---
 base/data-struct/radix-tree-adaptive.c | 2 +-
 lib/label/hints.c                      | 2 +-
 tools/command.c                        | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

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
diff --git a/lib/label/hints.c b/lib/label/hints.c
index c9d339861..55f55900d 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -966,7 +966,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 		 * detect when the devices on the system change, which
 		 * invalidates the existing hints.
 		 */
-		strncpy(devpath, dev_name(dev), PATH_MAX);
+		(void) dm_strncpy(devpath, dev_name(dev), sizeof(devpath));
 		hash = calc_crc(hash, (const uint8_t *)devpath, strlen(devpath));
 		count++;
 
diff --git a/tools/command.c b/tools/command.c
index 2d0184941..4fc55e2be 100644
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


