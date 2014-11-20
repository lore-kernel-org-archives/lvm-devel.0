From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:00 +0000 (UTC)
Subject: master - libdm-config: Implement dm_config_flatten.
Message-ID: <20141120155300.E5A6460612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=274a7a68b80fdce9e9398ffbe45e788b13b04642
Commit:        274a7a68b80fdce9e9398ffbe45e788b13b04642
Parent:        956c19284195f3200a1370166bd8847e5d159588
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:37:31 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

libdm-config: Implement dm_config_flatten.

---
 libdm/libdevmapper.h |    5 ++++
 libdm/libdm-config.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 6e237c0..3400c28 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1848,6 +1848,11 @@ struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *fir
  */
 struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft);
 
+/*
+ * Create a new, uncascaded config tree equivalent to the input cascade.
+ */
+struct dm_config_tree *dm_config_flatten(struct dm_config_tree *cft);
+
 void dm_config_destroy(struct dm_config_tree *cft);
 
 /* Simple output line by line. */
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index c026385..e6b2b90 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1315,3 +1315,56 @@ struct dm_pool *dm_config_memory(struct dm_config_tree *cft)
 {
 	return cft->mem;
 }
+
+static int _override_path(const char *path, struct dm_config_node *node, void *baton)
+{
+	struct dm_config_tree *cft = baton;
+	struct dm_config_node dummy, *target;
+	dummy.child = cft->root;
+	if (!(target = _find_or_make_node(cft->mem, &dummy, path)))
+		return_0;
+	if (!(target->v = _clone_config_value(cft->mem, node->v)))
+		return_0;
+	cft->root = dummy.child;
+	return 1;
+}
+
+static int _enumerate(const char *path, struct dm_config_node *cn, int (*cb)(const char *, struct dm_config_node *, void *), void *baton)
+{
+	char *sub = NULL;
+
+	while (cn) {
+		if (dm_asprintf(&sub, "%s/%s", path, cn->key) < 0)
+			return_0;
+		if (cn->child) {
+			if (!_enumerate(sub, cn->child, cb, baton))
+				goto_bad;
+		} else
+			if (!cb(sub, cn, baton))
+				goto_bad;
+		dm_free(sub);
+		cn = cn->sib;
+	}
+	return 1;
+bad:
+	dm_free(sub);
+	return 0;
+}
+
+struct dm_config_tree *dm_config_flatten(struct dm_config_tree *cft)
+{
+	struct dm_config_tree *res = dm_config_create(), *done = NULL, *current = NULL;
+
+	if (!res)
+		return_NULL;
+
+	while (done != cft) {
+		current = cft;
+		while (current->cascade != done)
+			current = current->cascade;
+		_enumerate("", current->root, _override_path, res);
+		done = current;
+	}
+
+	return res;
+}


