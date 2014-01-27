From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 27 Jan 2014 22:21:39 +0000 (UTC)
Subject: master - Misc: New function for reading lvm config file fields
Message-ID: <20140127222139.76E5A61171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94377dfd5ee7bbbdeb8836eeeea2198bc32c07f5
Commit:        94377dfd5ee7bbbdeb8836eeeea2198bc32c07f5
Parent:        6b73d21ba940804ebe91641343ee76f52d6a138e
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jan 27 05:26:19 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jan 27 05:26:19 2014 -0600

Misc: New function for reading lvm config file fields

Introduce 'dm_config_get_int', which will be used by the upcoming
cachepool segment type.
---
 libdm/libdevmapper.h |    1 +
 libdm/libdm-config.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index adfbb76..3bf8bd6 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1661,6 +1661,7 @@ int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path,
 int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail);
 int dm_config_value_is_bool(const struct dm_config_value *v);
 
+int dm_config_get_int(const struct dm_config_node *cn, const char *path, int *result);
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path, uint32_t *result);
 int dm_config_get_uint64(const struct dm_config_node *cn, const char *path, uint64_t *result);
 int dm_config_get_str(const struct dm_config_node *cn, const char *path, const char **result);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index ea1af2f..3297621 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1047,6 +1047,20 @@ int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path,
 
 /************************************/
 
+int dm_config_get_int(const struct dm_config_node *cn, const char *path,
+		      int *result)
+{
+	const struct dm_config_node *n;
+
+	n = _find_config_node(cn, path);
+
+	if (!n || !n->v || n->v->type != DM_CFG_INT)
+		return 0;
+
+	if (result)
+		*result = n->v->v.i;
+	return 1;
+}
 
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
 			 uint32_t *result)


