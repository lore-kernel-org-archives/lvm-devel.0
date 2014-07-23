From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Jul 2014 15:20:48 +0000 (UTC)
Subject: master - raid: Fix partial activation logic for non-raid.
Message-ID: <20140723152048.62CF360460@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52217f6ebd3dee25808344a9425fc085427075e4
Commit:        52217f6ebd3dee25808344a9425fc085427075e4
Parent:        25fa725b05a83dd67e907802d1938bf983ffaad8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 23 16:13:12 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 23 16:13:12 2014 +0100

raid: Fix partial activation logic for non-raid.

---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ebeaa79..1230c9a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2224,8 +2224,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV) && lv_is_raid_type(lv)) {
-		if (!partial_raid_lv_supports_degraded_activation(lv)) {
+	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
+		if (!lv_is_raid_type(lv) || !partial_raid_lv_supports_degraded_activation(lv)) {
 			log_error("Refusing activation of partial LV %s.  "
 				  "Use '--activationmode partial' to override.",
 				  display_lvname(lv));


