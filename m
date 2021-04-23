From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:51 +0000 (GMT)
Subject: main - cov: add explicit check for external not being null
Message-ID: <20210423210551.A905439450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cdcd8011d05a0cb7c6a07800dae2a0f99da8a5ee
Commit:        cdcd8011d05a0cb7c6a07800dae2a0f99da8a5ee
Parent:        d388b36da236e66dd42e59d7b5c9d596d6de1961
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 22:47:18 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: add explicit check for external not being null

Although the code should never evaluate for null external
add explict check for analyzer.
---
 tools/vgsplit.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 778e63d47..8a785bdbd 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -341,8 +341,9 @@ static int _move_thins(struct volume_group *vg_from,
 
 			if ((_lv_is_in_vg(vg_to, data_lv) ||
 			     _lv_is_in_vg(vg_to, seg->external_lv))) {
-				if (_lv_is_in_vg(vg_from, seg->external_lv) ||
-				    _lv_is_in_vg(vg_from, data_lv)) {
+				if (seg->external_lv &&
+				    (_lv_is_in_vg(vg_from, seg->external_lv) ||
+				     _lv_is_in_vg(vg_from, data_lv))) {
 					log_error("Can't split external origin %s "
 						  "and pool %s between two Volume Groups.",
 						  display_lvname(seg->external_lv),


