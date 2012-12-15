From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:04 +0000 (UTC)
Subject: master - cleanup: ignore errors
Message-ID: <20121215162504.A131AAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b05438fcbb27ba425c369c0b9d4e641ccc1b970
Commit:        1b05438fcbb27ba425c369c0b9d4e641ccc1b970
Parent:        8b8065a870591e743a79e9aa7f738d084d88bcad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 13 19:55:33 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: ignore errors

Since we are doing just dump and function doesn't report
any error, explicitely ignore return values from
dm_config_write_node and dm_asprintf.

Same applies for the logging function.
---
 daemons/lvmetad/lvmetad-core.c |    6 +++---
 libdaemon/server/daemon-log.c  |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0a1c884..e1cb583 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -950,7 +950,7 @@ static void _dump_cft(struct buffer *buf, struct dm_hash_table *ht, const char *
 		struct dm_config_tree *cft = dm_hash_get_data(ht, n);
 		const char *key_backup = cft->root->key;
 		cft->root->key = dm_config_find_str(cft->root, key_addr, "unknown");
-		dm_config_write_node(cft->root, buffer_line, buf);
+		(void) dm_config_write_node(cft->root, buffer_line, buf);
 		cft->root->key = key_backup;
 		n = dm_hash_get_next(ht, n);
 	}
@@ -969,9 +969,9 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 			   *val = dm_hash_get_data(ht, n);
 		buffer_append(buf, "    ");
 		if (int_key)
-			dm_asprintf(&append, "%d = \"%s\"", *(int*)key, val);
+			(void) dm_asprintf(&append, "%d = \"%s\"", *(int*)key, val);
 		else
-			dm_asprintf(&append, "%s = \"%s\"", key, val);
+			(void) dm_asprintf(&append, "%s = \"%s\"", key, val);
 		if (append)
 			buffer_append(buf, append);
 		buffer_append(buf, "\n");
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 6f5f4dc..c9e133c 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -98,7 +98,7 @@ void daemon_log_cft(log_state *s, int type, const char *prefix, const struct dm_
 	if (!_type_interesting(s, type))
 		return;
 
-	dm_config_write_node(n, &_log_line, &b);
+	(void) dm_config_write_node(n, &_log_line, &b);
 }
 
 void daemon_log_multi(log_state *s, int type, const char *prefix, const char *msg)


