From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  5 Aug 2016 14:30:06 +0000 (UTC)
Subject: master - raid_manip: fix log print format from commit d2c3b23e6dc3
Message-ID: <20160805143006.B739760063@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f25ad6416ee6edb2648ddd207a39819a6f99c1e
Commit:        8f25ad6416ee6edb2648ddd207a39819a6f99c1e
Parent:        9aefe9aa7ace98fa2e1cb2867a8f895e9caf380d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 5 16:29:56 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 5 16:29:56 2016 +0200

raid_manip: fix log print format from commit d2c3b23e6dc3

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1e2f018..4498f2f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2970,7 +2970,7 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	}
 
 	if (!match_count) {
-		log_print_unless_silent("%s/%s does not contain devices specified"
+		log_print_unless_silent("%s does not contain devices specified"
 					" to %s", display_lvname(lv), action_str);
 		return 1;
 	} else if (match_count == raid_seg->area_count) {


