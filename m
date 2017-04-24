From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 24 Apr 2017 12:56:53 -0400
Subject: master - lvconvert: FIXME
Message-ID: <201704241656.v3OGurdA029428@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c534a7bcc98e936a456601e4be749a828d978e9e
Commit:        c534a7bcc98e936a456601e4be749a828d978e9e
Parent:        aa1d5d5c89873c0002628142fd9b2c7c4cc1da55
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Apr 24 18:56:36 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Apr 24 18:56:36 2017 +0200

lvconvert: FIXME

Add FIXME to move error path processing out of tool into library.

Related: rhbz1437653
---
 tools/lvconvert.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 22967e8..22555f3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -917,6 +917,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				    lp->stripes, lp->stripe_size,
 				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
+			/* FIXME: failure inside library -> move error path processing into library. */
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
 			    (lv_is_active(lv) && !deactivate_lv(cmd, layer_lv)) ||


