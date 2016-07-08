From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 11:31:38 +0000 (UTC)
Subject: master - dmstats: ensure dm_stats_delete_region() return is checked
Message-ID: <20160708113138.A505560F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=005adb0a0a5bfbe3ffbf94a41b1619001d8576b3
Commit:        005adb0a0a5bfbe3ffbf94a41b1619001d8576b3
Parent:        cc4f036d36a89a57f60dc87acfca5046f74c3f7d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 11:46:13 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 12:26:34 2016 +0100

dmstats: ensure dm_stats_delete_region() return is checked

---
 tools/dmsetup.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b675625..83d45da 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5040,7 +5040,10 @@ static int _stats_delete(CMD_ARGS)
 			log_info("Deleted statistics region %" PRIu64, region_id);
 		}
 	} else {
-		dm_stats_delete_region(dms, region_id);
+		if (!dm_stats_delete_region(dms, region_id)) {
+			log_error("Could not delete statistics region");
+			goto out;
+		}
 		log_info("Deleted statistics region " FMTu64 ".\n", region_id);
 	}
 


