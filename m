From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 20 Jul 2012 13:55:04 +0000 (UTC)
Subject: master - config: fix one-node dumpconfig, add dm_config_write_one_node
Message-ID: <20120720135504.7BFDD550@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e36b86c46f04eddae2d4b1f826e1f24995b3636
Commit:        5e36b86c46f04eddae2d4b1f826e1f24995b3636
Parent:        8d5ae472e5226f87175d51722fb5942c531bb8bb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 20 15:53:04 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 20 15:53:04 2012 +0200

config: fix one-node dumpconfig, add dm_config_write_one_node

A regression introduced in 2.02.89 (11e520256b3005ed813ce83f8770aaab74edef3f)
caused the lvm dumpconfig <node> to print out
the node as well as its subsequent siblings.
The information about "only_one" mode got lost.

Before this patch (just an example node):
  # lvm dumpconfig global/use_lvmetad
  use_lvmetad=1
  thin_check_executable="/usr/sbin/thin_check"
  thin_check_options="-q"
  (...all nodes to the end of the section)

With this patch applied:
   # lvm dumpconfig global/use_lvmetad
   use_lvmetad=1
---
 WHATS_NEW            |    1 +
 WHATS_NEW_DM         |    1 +
 lib/config/config.c  |    2 +-
 libdm/libdevmapper.h |    3 +++
 libdm/libdm-config.c |   15 +++++++++++++--
 5 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4f23c39..aa26622 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix dumpconfig <node> to print only <node> without its siblings (2.02.89).
   Do not issue "Failed to handle a client connection" error if lvmetad killed.
   Support changing of discard and zeroing for thin pool.
   Report used discard for thin pool and volume.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 416beca..0bfd016 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.76 - 
 ===============================
+  Add dm_config_write_one_node to libdevmapper.
   Add support for thin pool message release/reserve_metadata_snap.
   Add support for thin pool discard and external origin.
   Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
diff --git a/lib/config/config.c b/lib/config/config.c
index 67a8b04..60ae6c8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -473,7 +473,7 @@ int config_write(struct dm_config_tree *cft, const char *file,
 		}
 	} else while (argc--) {
 		if ((cn = dm_config_find_node(cft->root, *argv))) {
-			if (!dm_config_write_node(cn, _putline_fn, fp)) {
+			if (!dm_config_write_one_node(cn, _putline_fn, fp)) {
 				log_error("Failure while writing to %s", file);
 				r = 0;
 			}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 549a635..02bf421 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1488,7 +1488,10 @@ struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft
 void dm_config_destroy(struct dm_config_tree *cft);
 
 typedef int (*dm_putline_fn)(const char *line, void *baton);
+/* Write the node and any subsequent siblings it has. */
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
+/* Write given node only without subsequent siblings. */
+int dm_config_write_one_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
 
 struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index d9d3882..8457497 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -331,14 +331,15 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 	return 1;
 }
 
-int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
+static int _write_node(const struct dm_config_node *cn, int only_one,
+		       dm_putline_fn putline, void *baton)
 {
 	struct output_line outline;
 	if (!(outline.mem = dm_pool_create("config_line", 1024)))
 		return_0;
 	outline.putline = putline;
 	outline.putline_baton = baton;
-	if (!_write_config(cn, 0, &outline, 0)) {
+	if (!_write_config(cn, only_one, &outline, 0)) {
 		dm_pool_destroy(outline.mem);
 		return_0;
 	}
@@ -346,6 +347,16 @@ int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline,
 	return 1;
 }
 
+int dm_config_write_one_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
+{
+	return _write_node(cn, 1, putline, baton);
+}
+
+int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
+{
+	return _write_node(cn, 0, putline, baton);
+}
+
 
 /*
  * parser


