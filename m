From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 22:55:01 +0000 (UTC)
Subject: master - lvconvert: disallow test mode in shared VG
Message-ID: <20160118225501.1ACBD60C94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48f270970fc526f9f0ac7d074639e8ed90346586
Commit:        48f270970fc526f9f0ac7d074639e8ed90346586
Parent:        6b3e402298080a4b3e352ecee3a33cd916d18b6b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 18 16:53:14 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 16:53:14 2016 -0600

lvconvert: disallow test mode in shared VG

until test mode can be checked in all the necessary
locations related to lvmlockd to prevent making
actual changes.
---
 tools/lvconvert.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d480f6a..13fe6e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3434,6 +3434,13 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 		goto_out;
 	}
 
+	if (test_mode() && is_lockd_type(vg->lock_type)) {
+		log_error("Test mode is not yet supported with lock type %s",
+			  vg->lock_type);
+		unlock_and_release_vg(cmd, vg, lp->vg_name);
+		goto_out;
+	}
+
 	if (!(lv = find_lv(vg, lp->lv_name))) {
 		log_error("Can't find LV %s in VG %s", lp->lv_name, lp->vg_name);
 		unlock_and_release_vg(cmd, vg, lp->vg_name);


