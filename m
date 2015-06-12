From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 15:10:22 +0000 (UTC)
Subject: master - metadata: When outdated PVs are wiped, notify lvmetad about the fact.
Message-ID: <20150612151022.A79DB60AAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=632dde0cbc98de9c04b4c2451d09e36d6299bbd6
Commit:        632dde0cbc98de9c04b4c2451d09e36d6299bbd6
Parent:        c78b6f18d4909dc4e5c873b3b1023c2053443046
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 10 16:27:12 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 10 16:27:12 2015 +0200

metadata: When outdated PVs are wiped, notify lvmetad about the fact.

---
 lib/cache/lvmetad.c     |   16 ++++++++++++++++
 lib/cache/lvmetad.h     |    3 +++
 lib/metadata/metadata.c |    4 +++-
 3 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 9aac6e9..92998bc 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1161,3 +1161,19 @@ int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handl
 {
 	return _lvmetad_pvscan_all_devs(cmd, handler, 1);
 }
+
+int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
+{
+	char uuid[64];
+	daemon_reply reply;
+	int result;
+
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
+	reply = _lvmetad_send("vg_clear_outdated_pvs", "vgid = %s", uuid, NULL);
+	result = _lvmetad_handle_reply(reply, "clear the list of outdated PVs", vg->name, NULL);
+	daemon_reply_destroy(reply);
+
+	return result;
+}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 395bc41..8224675 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -166,6 +166,8 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler);
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
 
+int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
+
 #  else		/* LVMETAD_SUPPORT */
 
 #    define lvmetad_init(cmd)	do { } while (0)
@@ -192,6 +194,7 @@ int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handl
 #    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
 #    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
+#    define lvmetad_vg_clear_outdated_pvs(vg)           (1)
 
 #  endif	/* LVMETAD_SUPPORT */
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8300eb6..75f3038 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3307,9 +3307,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				*consistent = _repair_inconsistent_vg(correct_vg);
 			else
 				*consistent = !reappeared;
-			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated))
+			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated)) {
 				/* clear the list */
 				dm_list_init(&correct_vg->pvs_outdated);
+				lvmetad_vg_clear_outdated_pvs(correct_vg);
+                        }
 		}
 		return correct_vg;
 	}


