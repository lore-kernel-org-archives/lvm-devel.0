From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  3 Jan 2017 13:56:13 +0000 (UTC)
Subject: master - cleanup: reuse existing code
Message-ID: <20170103135613.1197061010@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=377288fe0362dd41f2332a6634f8f1f7e6edccbb
Commit:        377288fe0362dd41f2332a6634f8f1f7e6edccbb
Parent:        95d5877f7af781c53c7865868745dc683d2b0413
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 24 23:10:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 3 14:55:16 2017 +0100

cleanup: reuse existing code

---
 lib/metadata/metadata.c |   34 ++++++++++++++--------------------
 1 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c636fe2..1289fec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5447,6 +5447,19 @@ int vg_flag_write_locked(struct volume_group *vg)
 	return 0;
 }
 
+static int _access_vg_clustered(struct cmd_context *cmd, const struct volume_group *vg)
+{
+	if (vg_is_clustered(vg) && !locking_is_clustered()) {
+		if (!cmd->ignore_clustered_vgs)
+			log_error("Skipping clustered volume group %s", vg->name);
+		else
+			log_verbose("Skipping clustered volume group %s", vg->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Performs a set of checks against a VG according to bits set in status
  * and returns FAILED_* bits for those that aren't acceptable.
@@ -5458,15 +5471,9 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 {
 	uint32_t failure = 0;
 
-	if ((status & CLUSTERED) &&
-	    (vg_is_clustered(vg)) && !locking_is_clustered()) {
-		if (!vg->cmd->ignore_clustered_vgs)
-			log_error("Skipping clustered volume group %s", vg->name);
-		else
-			log_verbose("Skipping clustered volume group %s", vg->name);
+	if ((status & CLUSTERED) && !_access_vg_clustered(vg->cmd, vg))
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
-	}
 
 	if ((status & EXPORTED_VG) &&
 	    vg_is_exported(vg)) {
@@ -5555,19 +5562,6 @@ static int _allow_extra_system_id(struct cmd_context *cmd, const char *system_id
 	return 0;
 }
 
-static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg)
-{
-	if (vg_is_clustered(vg) && !locking_is_clustered()) {
-		if (!cmd->ignore_clustered_vgs)
-			log_error("Skipping clustered volume group %s", vg->name);
-		else
-			log_verbose("Skipping clustered volume group %s", vg->name);
-		return 0;
-	}
-
-	return 1;
-}
-
 static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg,
 				uint32_t lockd_state, uint32_t *failure)
 {


