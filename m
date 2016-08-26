From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 26 Aug 2016 00:28:34 +0000 (UTC)
Subject: master - lvconvert: Fix --splitmirrors segfault with incorrect PV.
Message-ID: <20160826002834.236366055C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fde4399a01a002437d6d882c7faa59221aca93e
Commit:        2fde4399a01a002437d6d882c7faa59221aca93e
Parent:        fc93f10892187e20f9553b2d0c953cc420fd379d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 26 01:21:01 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 26 01:21:01 2016 +0100

lvconvert: Fix --splitmirrors segfault with incorrect PV.

Commit 9ee071705b2c35e1132f39f5731861c831a1bb6b misunderstood integer
promotion, but it's simpler to detect -1 more directly.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99d31be..1c0bcf4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Give error not segfault in lvconvert --splitmirrors when PV lies outside LV.
   Fix typo in report/columns_as_rows config option name recognition (2.02.99).
   Avoid PV tags when checking allocation against parallel PVs.
   Disallow mirror conversions of raid10 volumes.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d0934f4..e5fdf4f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1497,7 +1497,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		break;
 	}
 
-	if (s >= (int) seg->area_count) {
+	if (s < 0) {
 		log_error("Unable to find image to satisfy request");
 		return 0;
 	}


