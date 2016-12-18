From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:06 +0000 (UTC)
Subject: master - validation: check external property is matching
Message-ID: <20161218185206.9466C60E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36f609e513262547aa4d92c2b55d98b1471ba2e2
Commit:        36f609e513262547aa4d92c2b55d98b1471ba2e2
Parent:        7db46c4a39fd945f295a5bd4191bd48828072d24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 21:58:35 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:17:59 2016 +0100

validation: check external property is matching

Detect if number of external_count is matching
referencing devices for  external_origin LV.
---
 WHATS_NEW            |    1 +
 lib/metadata/merge.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6d36890..5002308 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Extend metadata validation of external origin LV use count.
   Fix dm table when the last user of active external origin is removed.
   Improve reported lvs status for active external origin volume.
   Fix table load for splitted RAID LV and require explicit activation.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 6d52bc4..947513b 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -398,6 +398,18 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				inc_error_count;
 			}
 		}
+
+		if (lv_is_external_origin(lv)) {
+			seg_found = 0;
+			dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+				if (sl->seg->external_lv == lv)
+					seg_found++;
+			if (seg_found != lv->external_count) {
+				log_error("LV %s: external origin count does not match.",
+					  lv->name);
+				inc_error_count;
+			}
+		}
 	}
 
 	dm_list_iterate_items(seg, &lv->segments) {


