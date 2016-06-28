From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:30 +0000 (UTC)
Subject: master - lvmetad: two phase vg_remove
Message-ID: <20160628013330.A64E260C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff3c4ed1c0e2e554e9fb5f9b7ff20fdf5a835852
Commit:        ff3c4ed1c0e2e554e9fb5f9b7ff20fdf5a835852
Parent:        a7c45ddc59449fa8b1823bcab31e3fbb64fed97c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 8 16:02:45 2016 -0500
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:30:36 2016 +0100

lvmetad: two phase vg_remove

Apply the same idea as vg_update.
Before doing the VG remove on disk, invalidate
the VG in lvmetad.  After the VG is removed,
remove the VG in lvmetad.  If the command fails
after removing the VG on disk, but before removing
the VG metadata from lvmetad, then a subsequent
command will see the INVALID flag and not use the
stale metadata from lvmetad.
---
 lib/cache/lvmetad.c     |   36 ++++++++++++++++++++++++++++++++----
 lib/cache/lvmetad.h     |    6 ++++--
 lib/metadata/metadata.c |    8 ++++++--
 3 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 784a529..94059dd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -648,10 +648,9 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 		action = "set VG info";
 	else if (!strcmp(id, "vg_update"))
 		action = "update VG";
-	else if (!strcmp(id, "vg_remove")) {
+	else if (!strcmp(id, "vg_remove"))
 		action = "remove VG";
-		action_modifies = 1;
-	} else if (!strcmp(id, "pv_found")) {
+	else if (!strcmp(id, "pv_found")) {
 		action = "update PV";
 		action_modifies = 1;
 	} else if (!strcmp(id, "pv_gone")) {
@@ -1272,7 +1271,36 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 	return 1;
 }
 
-int lvmetad_vg_remove(struct volume_group *vg)
+int lvmetad_vg_remove_pending(struct volume_group *vg)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	daemon_reply reply;
+
+	if (!lvmetad_used() || test_mode())
+		return 1; /* fake it */
+
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
+	/* Sending version/seqno 0 in set_vg_info will set the INVALID flag. */
+
+	log_debug_lvmetad("Sending lvmetad pending remove VG %s", vg->name);
+	reply = _lvmetad_send(vg->cmd, "set_vg_info",
+			      "name = %s", vg->name,
+			      "uuid = %s", uuid,
+			      "version = %d", 0,
+			      NULL);
+
+	if (!_lvmetad_handle_reply(reply, "set_vg_info", vg->name, NULL)) {
+		daemon_reply_destroy(reply);
+		return_0;
+	}
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
+int lvmetad_vg_remove_finish(struct volume_group *vg)
 {
 	char uuid[64];
 	daemon_reply reply;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 9ee4e2d..d47ce41 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -86,7 +86,8 @@ int lvmetad_vg_update_finish(struct volume_group *vg);
  * only needed during vgremove, which does not wipe PV labels and therefore
  * cannot mark the PVs as gone.
  */
-int lvmetad_vg_remove(struct volume_group *vg);
+int lvmetad_vg_remove_pending(struct volume_group *vg);
+int lvmetad_vg_remove_finish(struct volume_group *vg);
 
 /*
  * Notify lvmetad that a PV has been found. It is not an error if the PV is
@@ -174,7 +175,8 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_update_pending(vg)	(1)
 #    define lvmetad_vg_update_finish(vg)	(1)
-#    define lvmetad_vg_remove(vg)	(1)
+#    define lvmetad_vg_remove_pending(vg)	(1)
+#    define lvmetad_vg_remove_finish(vg)	(1)
 #    define lvmetad_pv_found(cmd, pvid, dev, fmt, label_sector, vg, found_vgnames, changed_vgnames)	(1)
 #    define lvmetad_pv_gone(devno, pv_name)	(1)
 #    define lvmetad_pv_gone_by_dev(dev)	(1)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e100bc6..d8bb726 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -568,6 +568,11 @@ int vg_remove_direct(struct volume_group *vg)
 	struct pv_list *pvl;
 	int ret = 1;
 
+	if (!lvmetad_vg_remove_pending(vg)) {
+		log_error("Failed to update lvmetad for pending remove.");
+		return 0;
+	}
+
 	if (!vg_remove_mdas(vg)) {
 		log_error("vg_remove_mdas %s failed", vg->name);
 		return 0;
@@ -599,8 +604,7 @@ int vg_remove_direct(struct volume_group *vg)
 		}
 	}
 
-	/* FIXME Handle partial failures from above. */
-	if (!lvmetad_vg_remove(vg))
+	if (!lvmetad_vg_remove_finish(vg))
 		stack;
 
 	lockd_vg_update(vg);


