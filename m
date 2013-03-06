From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:31 +0000 (UTC)
Subject: master - libdevmapper: add dm_config_value_is_bool function
Message-ID: <20130306111531.6270AA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=296385c0f3fa5176704c42f92210e7c5d38996ad
Commit:        296385c0f3fa5176704c42f92210e7c5d38996ad
Parent:        386886f71c3da0945f47edf1a7063a04ba9b56d1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 17:10:30 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:14:33 2013 +0100

libdevmapper: add dm_config_value_is_bool function

Export this functionality from libdevmapper just for
convenience and general use when reading boolean values
which could be defined either in a numeric way with 0/1
or by using strings with "true"/"false", "yes"/"no",
"on"/"off", "y"/"n".
---
 libdm/libdevmapper.h |    1 +
 libdm/libdm-config.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b08a549..8c349c5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1555,6 +1555,7 @@ int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path,
  * off), (true, false).
  */
 int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail);
+int dm_config_value_is_bool(const struct dm_config_value *v);
 
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path, uint32_t *result);
 int dm_config_get_uint64(const struct dm_config_node *cn, const char *path, uint64_t *result);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index bd29d32..4705a1c 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -928,6 +928,20 @@ int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int f
 	return _find_config_bool(cn, _find_config_node, path, fail);
 }
 
+int dm_config_value_is_bool(const struct dm_config_value *v) {
+	if (!v)
+		return 0;
+
+	switch(v->type) {
+		case DM_CFG_INT:
+			return 1;
+		case DM_CFG_STRING:
+			return _str_to_bool(v->v.str, -1) != -1;
+		default:
+			return 0;
+	}
+}
+
 /***********************************
  * tree-based lookup
  **/


