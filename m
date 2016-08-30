From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Aug 2016 11:04:46 +0000 (UTC)
Subject: master - raid10: Fix #stripes in lvcreate msg when too many.
Message-ID: <20160830110446.5D19160EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be85c22f6591435f27380e944f4770612b3b6d3c
Commit:        be85c22f6591435f27380e944f4770612b3b6d3c
Parent:        7412690dd2ca55d0a790ba50a3425565758130ce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 30 12:04:23 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 30 12:04:23 2016 +0100

raid10: Fix #stripes in lvcreate msg when too many.

---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6980e17..ad3d174 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Fix number of stripes shown in lvcreate raid10 message when too many.
   Do not monitor cache-pool metadata when LV is just being cleared.
   Add allocation/cache_pool_max_chunks to prevent misuse of cache target.
   Give error not segfault in lvconvert --splitmirrors when PV lies outside LV.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 33664c5..387c8d4 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -591,7 +591,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 	/* FIMXE: raid10 check has to change once we support data copies and odd numbers of stripes */
 	if (seg_is_raid10(lp) && lp->mirrors * lp->stripes > max_images) {
 		log_error("Only up to %u stripes in %s supported currently.",
-			  max_images, lp->segtype->name);
+			  max_images / lp->mirrors, lp->segtype->name);
 		return 0;
 	} else if (seg_is_mirrored(lp)) {
 		if (lp->mirrors > max_images) {


