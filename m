From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 24 Apr 2017 11:45:27 -0400
Subject: master - lvconvert: fix inactive mirror up converting regression
Message-ID: <201704241545.v3OFjRBW018310@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa1d5d5c89873c0002628142fd9b2c7c4cc1da55
Commit:        aa1d5d5c89873c0002628142fd9b2c7c4cc1da55
Parent:        8333d5a969042a321f00656271bd55a37c1ea179
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Apr 24 17:44:54 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Apr 24 17:44:54 2017 +0200

lvconvert: fix inactive mirror up converting regression

Up converting an inactive mirror with insufficient
devs results in an over concerned warning.

Resolves: rhbz1437653
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d5ca6d7..22967e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -919,7 +919,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
-			    !deactivate_lv(cmd, layer_lv) ||
+			    (lv_is_active(lv) && !deactivate_lv(cmd, layer_lv)) ||
 			    !lv_remove(layer_lv) ||
 			    !vg_write(lv->vg) || !vg_commit(lv->vg)) {
 				log_error("ABORTING: Failed to remove "


