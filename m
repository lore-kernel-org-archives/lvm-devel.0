From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Feb 2016 09:32:44 +0000 (UTC)
Subject: master - refactor: add common _is_foreign_vg fn
Message-ID: <20160217093244.EF60A60797@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13f3e926326ae528d1a62d9786f462e7d7c73037
Commit:        13f3e926326ae528d1a62d9786f462e7d7c73037
Parent:        45be3c875f4605f4f950e8abfa12cf422526f5db
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 16 13:44:48 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 16 13:44:48 2016 +0100

refactor: add common _is_foreign_vg fn

---
 lib/metadata/metadata.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index eb50c0a..4dbe38b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3627,6 +3627,11 @@ static int _check_reappeared_pv(struct volume_group *correct_vg,
 	return rv;
 }
 
+static int _is_foreign_vg(struct volume_group *vg)
+{
+	return vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id);
+}
+
 static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 				   struct physical_volume *pv,
 				   int repair, int *inconsistent_pvs)
@@ -3678,7 +3683,7 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
 
 	/* Cannot write foreign VGs, the owner will repair it. */
-	if (vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id)) {
+	if (_is_foreign_vg(vg)) {
 		log_verbose("Skip metadata repair for foreign VG.");
 		return 0;
 	}
@@ -3718,7 +3723,7 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 	 * some PVs look outdated to us just because we're reading
 	 * the VG while it's only partially written out.
 	 */
-	if (cmd->system_id && strcmp(vg->system_id, cmd->system_id)) {
+	if (_is_foreign_vg(vg)) {
 		log_debug_metadata("Skip wiping outdated PVs for foreign VG.");
 		return 0;
 	}


