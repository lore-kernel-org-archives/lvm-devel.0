From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:05 +0000 (UTC)
Subject: master - unknown: add_target_line is not needed
Message-ID: <20140430082805.7DBAF60D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b56aef1915c5cf5eddb8b415d204843fc1192812
Commit:        b56aef1915c5cf5eddb8b415d204843fc1192812
Parent:        1756bf6c63a69dfc48fc294352978b7f07627536
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 23:38:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:30 2014 +0200

unknown: add_target_line is not needed

Leave addition of unknown segment to table as internal error.
Do not replace unknown segment with error device.
---
 lib/unknown/unknown.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 9e433cf..2ce2f9d 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -53,20 +53,6 @@ static int _unknown_text_export(const struct lv_segment *seg, struct formatter *
 	return out_config_node(f, cn);
 }
 
-#ifdef DEVMAPPER_SUPPORT
-static int _unknown_add_target_line(struct dev_manager *dm __attribute__((unused)),
-				struct dm_pool *mem __attribute__((unused)),
-				struct cmd_context *cmd __attribute__((unused)),
-				void **target_state __attribute__((unused)),
-				struct lv_segment *seg __attribute__((unused)),
-				const struct lv_activate_opts *laopts __attribute__((unused)),
-				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count __attribute__((unused)))
-{
-	return dm_tree_node_add_error_target(node, len);
-}
-#endif
-
 static void _unknown_destroy(struct segment_type *segtype)
 {
 	dm_free(segtype);
@@ -76,9 +62,6 @@ static struct segtype_handler _unknown_ops = {
 	.name = _unknown_name,
 	.text_import = _unknown_text_import,
 	.text_export = _unknown_text_export,
-#ifdef DEVMAPPER_SUPPORT
-	.add_target_line = _unknown_add_target_line,
-#endif
 	.destroy = _unknown_destroy,
 };
 


