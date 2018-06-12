From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 10:38:12 -0400
Subject: 2018-06-01-stable - lvmlockd: skip repair lock upgrade for non shared vgs
Message-ID: <201806121438.w5CEcCkb022111@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3dcca639cca4662fea339c03c0971b380463f7e
Commit:        d3dcca639cca4662fea339c03c0971b380463f7e
Parent:        98eb9e57544df1cbdf27f3186f425299d6a71097
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 09:25:51 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 09:25:51 2018 -0500

lvmlockd: skip repair lock upgrade for non shared vgs

Only attempt lvmlockd lock upgrade for shared VGs.
---
 lib/metadata/metadata.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ab53bfa..67cf374 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5185,7 +5185,8 @@ int vg_check_status(const struct volume_group *vg, uint64_t status)
  * VG is left unlocked on failure
  */
 static struct volume_group *_recover_vg(struct cmd_context *cmd,
-			 const char *vg_name, const char *vgid, uint32_t lockd_state)
+			 const char *vg_name, const char *vgid,
+			 int is_shared, uint32_t lockd_state)
 {
 	int consistent = 1;
 	struct volume_group *vg;
@@ -5199,7 +5200,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	/*
 	 * Convert vg lock in lvmlockd from sh to ex.
 	 */
-	if (!(lockd_state & LDST_FAIL) && !(lockd_state & LDST_EX)) {
+	if (is_shared && !(lockd_state & LDST_FAIL) && !(lockd_state & LDST_EX)) {
 		log_debug("Upgrade lvmlockd lock to repair vg %s.", vg_name);
 		if (!lockd_vg(cmd, vg_name, "ex", 0, &state)) {
 			log_warn("Skip repair for shared VG without exclusive lock.");
@@ -5450,6 +5451,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	int consistent_in;
 	uint32_t failure = 0;
 	uint32_t warn_flags = 0;
+	int is_shared = 0;
 	int already_locked;
 
 	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE))
@@ -5498,8 +5500,9 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
+		is_shared = vg_is_shared(vg);
 		release_vg(vg);
-		if (!(vg = _recover_vg(cmd, vg_name, vgid, lockd_state))) {
+		if (!(vg = _recover_vg(cmd, vg_name, vgid, is_shared, lockd_state))) {
 			if (is_orphan_vg(vg_name))
 				log_error("Recovery of standalone physical volumes failed.");
 			else


