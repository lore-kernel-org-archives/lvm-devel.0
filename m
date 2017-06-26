From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:53 -0400
Subject: master - debug: use display_lvname
Message-ID: <201706262229.v5QMTrss010323@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72c5598658764e1b0054c0cb40e6a4770c11f660
Commit:        72c5598658764e1b0054c0cb40e6a4770c11f660
Parent:        a567ec65a9d22e49208d42a08a4d7531219166d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:58:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

debug: use display_lvname

---
 tools/vgsplit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index e2ba6f7..da9b7b1 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -341,8 +341,8 @@ static int _move_thins(struct volume_group *vg_from,
 				    _lv_is_in_vg(vg_from, data_lv)) {
 					log_error("Can't split external origin %s "
 						  "and pool %s between two Volume Groups.",
-						  seg->external_lv->name,
-						  seg->pool_lv->name);
+						  display_lvname(seg->external_lv),
+						  display_lvname(seg->pool_lv));
 					return 0;
 				}
 				if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))


