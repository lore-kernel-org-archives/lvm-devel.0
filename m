From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 17 Sep 2014 02:32:05 +0000 (UTC)
Subject: master - clean-up: better macro usage
Message-ID: <20140917023205.DCF3B60D2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b87a7683e23c2c309f11929a488230570daf0dc0
Commit:        b87a7683e23c2c309f11929a488230570daf0dc0
Parent:        4a853361b01feda77031901eb2828c6ecabe760f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 16 21:24:14 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 16 21:24:14 2014 -0500

clean-up:  better macro usage

Use 'lv_is_mirror' instead of 'lv_is_mirrored && !lv_is_raid' - both
are the same as asking if the non-RAID mirror implementation is being
used.
---
 tools/lvconvert.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c252745..c7eb02d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2659,7 +2659,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 				  display_lvname(metadata_lv));
 			return 0;
 		}
-		if (lv_is_mirrored(metadata_lv) && !lv_is_raid_type(metadata_lv)) {
+		if (lv_is_mirror(metadata_lv)) {
 			log_error("Mirror logical volumes cannot be used "
 				  "for pool metadata.");
 			log_error("Try \"raid1\" segment type instead.");
@@ -2699,7 +2699,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
+	if (lv_is_mirror(pool_lv)) {
 		log_error("Mirror logical volumes cannot be used as pools.\n"
 			  "Try \"raid1\" segment type instead.");
 		return 0;


