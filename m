From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:26 +0000 (UTC)
Subject: master - libdaemon: check for strdup result
Message-ID: <20121215162526.45625AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=788ac7fa547fb98f0edd38685d40b80609f298dc
Commit:        788ac7fa547fb98f0edd38685d40b80609f298dc
Parent:        ff5612c0c3208276763348e9f9afa9a09096fbe1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 01:00:36 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:26 2012 +0100

libdaemon: check for strdup result

Detect failure of dm_pool_strdup() and print error in fail path.
Save one extra strchr call - since we already know the distance
for the '=' character.

Drop stack trace from return after log_error().
---
 WHATS_NEW                      |    1 +
 libdaemon/client/config-util.c |   17 +++++++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fcb8897..e0ce819 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add check for key string duplication in config_make_nodes_v.
   Add check for created fid in _scan_file.
   Log output also to syslog when abort_on_internal_error is set.
   Add LV snapshot support to liblvm and python-lvm.
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 1c83134..34d755f 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -215,7 +215,8 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 	const char *next;
 	struct dm_config_node *first = NULL;
 	struct dm_config_node *cn;
-	const char *fmt, *key;
+	const char *fmt;
+	char *key;
 
 	while ((next = va_arg(ap, char *))) {
 		cn = NULL;
@@ -223,12 +224,16 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 
 		if (!fmt) {
 			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
-			return_NULL;
+			return NULL;
+		}
+
+		if (!(key = dm_pool_strdup(cft->mem, next))) {
+			log_error("Failed to duplicate node key.");
+			return NULL;
 		}
-		fmt += 2;
 
-		key = dm_pool_strdup(cft->mem, next);
-		*strchr(key, '=') = 0;
+		key[fmt - next] = '\0';
+		fmt += 2;
 
 		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
 			int64_t value = va_arg(ap, int64_t);
@@ -247,7 +252,7 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 			chain_node(cn, parent, pre_sib);
 		} else {
 			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
-			return_NULL;
+			return NULL;
 		}
 		if (!first)
 			first = cn;


