From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Oct 2012 10:17:09 +0000 (UTC)
Subject: master - report: call snapshot percent with cow only
Message-ID: <20121008101709.758B3337B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff13206c7e6f8a4246afb562338aaba879d579ad
Commit:        ff13206c7e6f8a4246afb562338aaba879d579ad
Parent:        5b07bd3f9116ade9bb5931485eaa260f5141db6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 8 12:06:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 8 12:16:53 2012 +0200

report: call snapshot percent with cow only

Ensure lv_snapshot_percent is used only with snapshot LVs.
---
 WHATS_NEW               |    1 +
 lib/report/properties.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e39a36e..004f8b1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Report invalid percentage for property snap_percent of non-snaphot LVs.
   Disallow convertion of thins to mirrors.
   Fix lvm2api data_percent reporting for thin volumes.
   Do not allow RAID LVs in a clustered volume group.
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 4129b01..c4f6ab9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -95,8 +95,10 @@ static percent_t _copy_percent(const struct logical_volume *lv) {
 
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
-	if (!lv_snapshot_percent(lv, &perc))
+
+	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &perc))
 		perc = PERCENT_INVALID;
+
 	return perc;
 }
 


