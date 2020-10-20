From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:05 +0000 (GMT)
Subject: stable-2.02 - lv_manip: add space into message
Message-ID: <20201020212505.5DE983857C7D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8af590b1bbb5796d20c32d41b6e4dcb7d2441fb9
Commit:        8af590b1bbb5796d20c32d41b6e4dcb7d2441fb9
Parent:        aa4f1f117a355c7046a348fd217fdfab20242ae6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 10:28:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:41:34 2020 +0200

lv_manip: add space into message

---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4b1b4de61..42d18abb8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -904,7 +904,7 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 	/* Round up extents to stripe divisible amount */
 	if ((size_rest = extents % stripes)) {
 		new_extents += extend ? stripes - size_rest : -size_rest;
-		log_print_unless_silent("Rounding size %s (%u extents) %s to stripe boundary size %s(%u extents).",
+		log_print_unless_silent("Rounding size %s (%u extents) %s to stripe boundary size %s (%u extents).",
 					display_size(vg->cmd, (uint64_t) extents * vg->extent_size), extents,
 					new_extents < extents ? "down" : "up",
 					display_size(vg->cmd, (uint64_t) new_extents * vg->extent_size), new_extents);


