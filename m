From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 Sep 2016 16:18:56 +0000 (UTC)
Subject: master - config: use config_tree_from_string_without_dup_node_check throughout code to construct metadata trees
Message-ID: <20160921161856.4274060F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1cad4c7103ac0edc0b724217b50d062326deb43
Commit:        f1cad4c7103ac0edc0b724217b50d062326deb43
Parent:        045772aa30ba1c5ab9dff730ce25ca6346c7150a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 14:59:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 18:18:15 2016 +0200

config: use config_tree_from_string_without_dup_node_check throughout code to construct metadata trees

---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/lvmetad-core.c   |    2 +-
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 lib/cache/lvmcache.c             |    2 +-
 lib/format_text/export.c         |    3 ++-
 libdaemon/client/daemon-client.c |    2 +-
 libdaemon/server/daemon-server.c |    2 +-
 7 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f7b39b9..aedacee 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Use dm_config_parse_without_dup_node_check() to speedup metadata reading.
   Fix lvconvert --repair regression
   Fix reported origin lv field for cache volumes. (2.02.133)
   Always specify snapshot cow LV for monitoring not internal LV. (2.02.165)
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ebaca78..36a5cec 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -599,7 +599,7 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 
 	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
 	if (!outdated_pvs) {
-		if (!(outdated_pvs = dm_config_from_string("outdated_pvs/pv_list = []")) ||
+		if (!(outdated_pvs = config_tree_from_string_without_dup_node_check("outdated_pvs/pv_list = []")) ||
 		    !(cft_vgid = make_text_node(outdated_pvs, "vgid", dm_pool_strdup(outdated_pvs->mem, vgid),
 						outdated_pvs->root, NULL)))
 			abort();
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 8fcbdec..4d96e67 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4431,7 +4431,7 @@ static void client_recv_action(struct client *cl)
 		return;
 	}
 
-	req.cft = dm_config_from_string(req.buffer.mem);
+	req.cft = config_tree_from_string_without_dup_node_check(req.buffer.mem);
 	if (!req.cft) {
 		log_error("client recv %u config_from_string error", cl->id);
 		buffer_destroy(&req.buffer);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6ce778d..5e402f0 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1275,7 +1275,7 @@ struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname
 	/* Build config tree from vgmetadata, if not yet cached */
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
-	      dm_config_from_string(vginfo->vgmetadata)))
+	      config_tree_from_string_without_dup_node_check(vginfo->vgmetadata)))
 		goto_bad;
 
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 810c932..1ecc362 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -22,6 +22,7 @@
 #include "text_export.h"
 #include "lvm-version.h"
 #include "toolcontext.h"
+#include "config-util.h"
 
 #include <stdarg.h>
 #include <time.h>
@@ -1077,7 +1078,7 @@ struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
 		return_NULL;
 	}
 
-	if (!(vg_cft = dm_config_from_string(buf))) {
+	if (!(vg_cft = config_tree_from_string_without_dup_node_check(buf))) {
 		log_error("Error parsing metadata for VG %s.", vg->name);
 		dm_free(buf);
 		return_NULL;
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 413d757..5ce1fc0 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -120,7 +120,7 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 		reply.error = errno;
 
 	if (buffer_read(h.socket_fd, &reply.buffer)) {
-		reply.cft = dm_config_from_string(reply.buffer.mem);
+		reply.cft = config_tree_from_string_without_dup_node_check(reply.buffer.mem);
 		if (!reply.cft)
 			reply.error = EPROTO;
 	} else
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0e37dfb..6af6de9 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -444,7 +444,7 @@ static void *_client_thread(void *state)
 		if (!buffer_read(ts->client.socket_fd, &req.buffer))
 			goto fail;
 
-		req.cft = dm_config_from_string(req.buffer.mem);
+		req.cft = config_tree_from_string_without_dup_node_check(req.buffer.mem);
 
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer.mem);


