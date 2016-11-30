From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 30 Nov 2016 23:00:25 +0000 (UTC)
Subject: master - raid: fix sync percent on large RaidLVs
Message-ID: <20161130230025.0D1C56025E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=745250073cf9902a561c116e89e535c86aab231e
Commit:        745250073cf9902a561c116e89e535c86aab231e
Parent:        c9848bb7eaa73c9ac92c47062981f0111d30204a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Dec 1 00:00:02 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Dec 1 00:00:02 2016 +0100

raid: fix sync percent on large RaidLVs

Resolves: rhbz1400301
---
 WHATS_NEW       |    1 +
 lib/raid/raid.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c35a85b..8df3565 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Display correct sync_percent on large RaidLVs
   lvmdbusd --blackboxsize <n> added, used to override default size of 16
   Allow a transiently failed RaidLV to be refreshed
   Use lv_update_and_reload() inside mirror code where it applies.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 80af61e..21fad92 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -342,7 +342,7 @@ static int _raid_target_percent(void **target_state,
 	*total_denominator += denominator;
 
 	if (seg)
-		seg->extents_copied = seg->area_len * numerator / denominator;
+		seg->extents_copied = (uint64_t) seg->area_len * dm_make_percent(numerator, denominator) / DM_PERCENT_100;
 
 	*percent = dm_make_percent(numerator, denominator);
 


