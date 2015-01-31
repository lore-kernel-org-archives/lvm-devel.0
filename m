From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:32 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - adjust __avoid_pvs_with_other_images_of_lv() to upstream
Message-ID: <20150131141032.DD1E6601E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc8fbe0a7f2832fc57899b4f40cc2f905fe94baa
Commit:        dc8fbe0a7f2832fc57899b4f40cc2f905fe94baa
Parent:        b8e9454601b32c6689045777db2c605084e27e74
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jan 22 19:26:52 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jan 22 19:26:52 2015 +0100

adjust __avoid_pvs_with_other_images_of_lv() to upstream

---
 lib/metadata/raid_manip.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e6367c4..220c751 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2765,7 +2765,7 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  */
 static void __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
-	(void) for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
 }
 
 /*
@@ -2874,7 +2874,11 @@ int lv_raid_replace(struct logical_volume *lv,
 	}
 
 	/* Prevent any PVs holding image components from being used for allocation */
-	__avoid_pvs_with_other_images_of_lv(lv, allocate_pvs);
+	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
+		log_error("Failed to prevent PVs holding image components "
+			  "from being used for allocation.");
+		return 0;
+	}
 
 	/*
 	 * Allocate the new image components first


