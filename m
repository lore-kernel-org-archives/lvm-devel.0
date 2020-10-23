From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:27 +0000 (GMT)
Subject: master - lv_manip: add space into message
Message-ID: <20201023234327.7D06D3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9740e98cbdba114457dc20bf43ad4c4b8994876f
Commit:        9740e98cbdba114457dc20bf43ad4c4b8994876f
Parent:        be94410446d381ab0512d347421a921c7966a10e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 10:28:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

lv_manip: add space into message

Just add space between %s(.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 72c85914d..e66342022 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1022,7 +1022,7 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 	/* Round up extents to stripe divisible amount */
 	if ((size_rest = extents % stripes)) {
 		new_extents += extend ? stripes - size_rest : -size_rest;
-		log_print_unless_silent("Rounding size %s (%u extents) %s to stripe boundary size %s(%u extents).",
+		log_print_unless_silent("Rounding size %s (%u extents) %s to stripe boundary size %s (%u extents).",
 					display_size(vg->cmd, (uint64_t) extents * vg->extent_size), extents,
 					new_extents < extents ? "down" : "up",
 					display_size(vg->cmd, (uint64_t) new_extents * vg->extent_size), new_extents);


