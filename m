From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:05 +0000 (UTC)
Subject: master - libdm-config: Implement dm_config_remove_node.
Message-ID: <20141120155305.1F28460794@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de2c5ab2ac0100c1d2f0648b9fec5304371a1ae5
Commit:        de2c5ab2ac0100c1d2f0648b9fec5304371a1ae5
Parent:        8bc996676345bdaa69e0bdaaebb490a9da5a7d4b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 20 12:05:09 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

libdm-config: Implement dm_config_remove_node.

---
 libdm/libdevmapper.h |    1 +
 libdm/libdm-config.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3400c28..895ad48 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1879,6 +1879,7 @@ int dm_config_write_one_node_out(const struct dm_config_node *cn, const struct d
 
 struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
+int dm_config_remove_node(struct dm_config_node *parent, struct dm_config_node *remove);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
 const char *dm_config_find_str_allow_empty(const struct dm_config_node *cn, const char *path, const char *fail);
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 1bc88e1..e99ae26 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1380,3 +1380,20 @@ struct dm_config_tree *dm_config_flatten(struct dm_config_tree *cft)
 
 	return res;
 }
+
+int dm_config_remove_node(struct dm_config_node *parent, struct dm_config_node *remove)
+{
+	struct dm_config_node *cn = parent->child, *last = NULL;
+	while (cn) {
+		if (cn == remove) {
+			if (last)
+				last->sib = cn->sib;
+			else
+				parent->child = cn->sib;
+			return 1;
+		}
+		last = cn;
+		cn = cn->sib;
+	}
+	return 0;
+}


