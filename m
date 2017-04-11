From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 15:19:31 -0400
Subject: master - raid_manip: fix typo warning message
Message-ID: <201704111919.v3BJJV0u028185@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69c3543855a98fcbb644bec0c7816913369c3892
Commit:        69c3543855a98fcbb644bec0c7816913369c3892
Parent:        1dfb4a2dae05679d0e5f1de1f2f7ded53606b7ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 14:18:57 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 14:18:57 2017 -0500

raid_manip: fix typo warning message

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 93c3c30..06a92b3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1891,7 +1891,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		log_print_unless_silent("If that leaves the logical volume larger than %llu extents due to stripe rounding,",
 					(unsigned long long) extend_le_count);
 		log_print_unless_silent("you may want to grow the content afterwards (filesystem etc.)");
-		log_warn("WARNING: too remove freed stripes after the conversion has finished, you have to run \"lvconvert --stripes %u %s\"",
+		log_warn("WARNING: to remove freed stripes after the conversion has finished, you have to run \"lvconvert --stripes %u %s\"",
 			 new_stripes, display_lvname(lv));
 
 		if (!force) {


