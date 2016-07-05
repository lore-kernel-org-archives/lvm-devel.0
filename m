From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:17 +0000 (UTC)
Subject: master - dmstats: fix region deletion message
Message-ID: <20160705183517.A840561240@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3914229d603e903cb6b33b50aedf2cf8185e74e8
Commit:        3914229d603e903cb6b33b50aedf2cf8185e74e8
Parent:        e25c27e5c2bda1fc8b87e52bb921aed22204d1f2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 1 14:18:38 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

dmstats: fix region deletion message

Make the use of 64-bit format macros consistent with other usage
and end the message with a '.'.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4a37f2b..d003c3b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5034,7 +5034,7 @@ static int _stats_delete(CMD_ARGS)
 		} dm_stats_walk_while(dms);
 	} else {
 		dm_stats_delete_region(dms, region_id);
-		log_info("Deleted statistics region %" PRIu64, region_id);
+		log_info("Deleted statistics region " FMTu64 ".\n", region_id);
 	}
 
 	r = 1;


