From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:30 +0000 (UTC)
Subject: master - report: fix report copy_percent value
Message-ID: <20160527134730.8A6226050D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9ee2cb6b6cf20893ab753d7129f759ba8faa931
Commit:        e9ee2cb6b6cf20893ab753d7129f759ba8faa931
Parent:        780424639afe3e9a91e85bf3f88142606833f310
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 13:48:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

report: fix report copy_percent value

When mirror/raid called copy_percent function to return,
when 100% was supposed to be returned, wrong float 100.0 value
could have been reported back instead of dm_percent_t DM_PERCENT_100.

There is broken API somewhere, since the function here rely on
actively being modifid VG content even when doing 'lvs' operation.
(extents_copies)
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa13ac8..2b6e0fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Correcting value in copy_percent() for 100%.
   Update vgreduce to use process_each_vg.
   Update lvconvert to use process_each_lv.
   Update pvscan to use process_each_vg for autoactivation.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6c2d4e5..b941979 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -872,7 +872,7 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 			numerator += seg->area_len;
 	}
 
-	return denominator ? dm_make_percent(numerator, denominator) : 100.0;
+	return denominator ? dm_make_percent(numerator, denominator) : DM_PERCENT_100;
 }
 
 /* Round up extents to next stripe boundary for number of stripes */


