From: Greg Price <price@MIT.EDU>
Date: Mon, 6 Apr 2009 23:55:15 -0400
Subject: [PATCH] When a resume_lv() fails, fail also in resume_lvs().
Message-ID: <20090407035514.GA21950@vinegar-pot.mit.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When a resume fails because device-mapper returns EINVAL to a reload
ioctl, this bug can cause pvmove to update an LV's metadata as if it
had been copied over, when in fact it has not.  This can lead to data
loss if not swiftly and manually noticed.

The corresponding code in suspend_lvs() attempts to resume any
successfully suspended LVs after an error.  It's possible resume_lvs()
should do likewise.  On the other hand, it's not clear what to do if
one of those attempts itself fails.  suspend_lvs() ignores further
errors in that case; presumably, like resume_lvs(), it was written
under the assumption that resume_lv() cannot fail.

Signed-off-by: Greg Price <price@mit.edu>
---
 lib/locking/locking.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 81cb992..0c225ed 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -369,8 +369,12 @@ int resume_lvs(struct cmd_context *cmd, struct list *lvs)
 {
 	struct lv_list *lvl;
 
-	list_iterate_items(lvl, lvs)
-		resume_lv(cmd, lvl->lv);
+	list_iterate_items(lvl, lvs) {
+		if (!resume_lv(cmd, lvl->lv)) {
+			log_error("Failed to resume %s", lvl->lv->name);
+			return 0;
+		}
+        }
 
 	return 1;
 }
-- 
1.5.2.2


