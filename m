From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:14 -0500
Subject: [PATCH 3/6] Mirror: Make 'get_pv_list_for_lv' work with mirrors
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-4-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We need to consider the possible mirror log when assembling the
list of PVs for a mirror logical volume.

This is a prerequisite for having pvmove work on mirrors.
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d835411..be40c30 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -175,6 +175,7 @@ int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
  *  - linear
  *  - stripe
  *  - raid
+ *  - mirror
  * It is up to the caller to free the pv_list when they are finished
  * with it.
  *
@@ -192,6 +193,10 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 			   lv->vg->name, lv->name);
 
 	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg->log_lv && /* Mirror logs */
+		    !get_pv_list_for_lv(mem, seg->log_lv, pvs))
+			return_0;
+
 		for (s = 0; s < seg->area_count; s++) {
 			dup_found = 0;
 
-- 
1.7.7.6


