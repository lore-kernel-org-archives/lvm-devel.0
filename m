From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 15:29:00 +0000 (UTC)
Subject: master - lvmlockd: skip lockd removal check for non-lockd VGs
Message-ID: <20150827152900.9EF37603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3f1b1dccb4db799ccbb054ad15a825e3a3eccba
Commit:        e3f1b1dccb4db799ccbb054ad15a825e3a3eccba
Parent:        fd238f3c0eb0ec158ac402c224f8dc5641bc1d8f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 16:09:59 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 10:27:24 2015 -0500

lvmlockd: skip lockd removal check for non-lockd VGs

---
 lib/locking/lvmlockd.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 45159d2..394657c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -902,17 +902,21 @@ static int _lockd_all_lvs(struct cmd_context *cmd, struct volume_group *vg)
 int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg,
 			 int changing)
 {
+	int lock_type_num = get_lock_type_from_string(vg->lock_type);
+
 	/*
 	 * Check that no LVs are active on other hosts.
 	 * When removing (not changing), each LV is locked
 	 * when it is removed, they do not need checking here.
 	 */
-	if (changing && !_lockd_all_lvs(cmd, vg)) {
-		log_error("Cannot change VG %s with active LVs", vg->name);
-		return 0;
+	if (lock_type_num == LOCK_TYPE_DLM || lock_type_num == LOCK_TYPE_SANLOCK) {
+		if (changing && !_lockd_all_lvs(cmd, vg)) {
+			log_error("Cannot change VG %s with active LVs", vg->name);
+			return 0;
+		}
 	}
 
-	switch (get_lock_type_from_string(vg->lock_type)) {
+	switch (lock_type_num) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
 	case LOCK_TYPE_DLM:


