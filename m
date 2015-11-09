From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:02 +0000 (UTC)
Subject: master - cleanup: use 64bit multiply for print
Message-ID: <20151109092902.34BC960F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b9b5d0ea23baf043d0a936662f0741d769cee04
Commit:        9b9b5d0ea23baf043d0a936662f0741d769cee04
Parent:        f6d2528f648b2cfad0d516fc6f0444a2570579f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 17:16:49 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: use 64bit multiply for print

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 74b574a..4e4a025 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -965,8 +965,8 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 	if ((size_rest = extents % stripes)) {
 		new_extents += extend ? stripes - size_rest : -size_rest;
 		log_print_unless_silent("Rounding size %s (%d extents) up to stripe boundary size %s (%d extents).",
-					display_size(vg->cmd, extents * vg->extent_size), extents,
-					display_size(vg->cmd, new_extents * vg->extent_size), new_extents);
+					display_size(vg->cmd, (uint64_t) extents * vg->extent_size), extents,
+					display_size(vg->cmd, (uint64_t) new_extents * vg->extent_size), new_extents);
 	}
 
 	return new_extents;


