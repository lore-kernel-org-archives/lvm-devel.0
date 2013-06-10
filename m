From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 20:51:13 +0000 (UTC)
Subject: master - format1: Fix snapshot reload in lv_remove.
Message-ID: <20130610205113.2772E60FB9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5a3bef276fe610b34b7ea6c53d332c429c31f01
Commit:        f5a3bef276fe610b34b7ea6c53d332c429c31f01
Parent:        7d644443e0f496f1cc34a5b2a9c66e96b3160b97
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jun 10 17:31:13 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 21:01:57 2013 +0200

format1: Fix snapshot reload in lv_remove.

The special suspend/resume code in lv_remove for LVM1 snapshots was interpsersed
with a vg_commit call. However, while with LVM1 metadata, vg_commit is
technically a no-op, the activation code relied on the ondisk and incore
metadata being the same, since on LVM1, a "commit" happens in vg_write
already. Since the "ondisk" metadata was previously not available with format1
(and incore was silently used instead, via lvmcache), the problem was masked.
---
 lib/metadata/lv_manip.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8f2f2ca..966b8fa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3557,20 +3557,18 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg))
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
 	/* format1 */
-	if (format1_reload_required && !suspend_lv(cmd, format1_origin))
-		log_error("Failed to refresh %s without snapshot.", format1_origin->name);
+	if (format1_reload_required) {
+		if (!suspend_lv(cmd, format1_origin))
+			log_error("Failed to refresh %s without snapshot.", format1_origin->name);
 
-	if (!vg_commit(vg))
-		return_0;
- 
-	/* format1 */
-	if (format1_reload_required && !resume_lv(cmd, format1_origin)) {
-		log_error("Failed to resume %s.", format1_origin->name);
-		return 0;
+		if (!resume_lv(cmd, format1_origin)) {
+			log_error("Failed to resume %s.", format1_origin->name);
+			return 0;
+		}
 	}
 
 	/* Release unneeded blocks in thin pool */


