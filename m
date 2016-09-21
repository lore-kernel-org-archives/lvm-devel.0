From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 Sep 2016 16:18:54 +0000 (UTC)
Subject: master - config: add config_tree_from_string_without_dup_node_check to replace dm_config_from_string where needed
Message-ID: <20160921161854.2F7F360F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=045772aa30ba1c5ab9dff730ce25ca6346c7150a
Commit:        045772aa30ba1c5ab9dff730ce25ca6346c7150a
Parent:        e40fbd08c8e3da43d07aabe58bd5549105056908
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 14:42:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 18:18:15 2016 +0200

config: add config_tree_from_string_without_dup_node_check to replace dm_config_from_string where needed

---
 libdaemon/client/config-util.c |   15 +++++++++++++++
 libdaemon/client/config-util.h |    2 ++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index e262182..93f3d0a 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -161,6 +161,21 @@ void chain_node(struct dm_config_node *cn,
 
 }
 
+struct dm_config_tree *config_tree_from_string_without_dup_node_check(const char *config_settings)
+{
+	struct dm_config_tree *cft;
+
+	if (!(cft = dm_config_create()))
+		return_NULL;
+
+	if (!dm_config_parse_without_dup_node_check(cft, config_settings, config_settings + strlen(config_settings))) {
+		dm_config_destroy(cft);
+		return_NULL;
+	}
+
+	return cft;
+}
+
 struct dm_config_node *make_config_node(struct dm_config_tree *cft,
 					const char *key,
 					struct dm_config_node *parent,
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 38f36af..485161f 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -66,4 +66,6 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 					 struct dm_config_node *pre_sib,
 					 ...);
 
+struct dm_config_tree *config_tree_from_string_without_dup_node_check(const char *config_settings);
+
 #endif /* _LVM_DAEMON_CONFIG_UTIL_H */


