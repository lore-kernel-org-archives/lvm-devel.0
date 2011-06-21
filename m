From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Jun 2011 20:07:22 +0200
Subject: [PATCH] Fail allocation if number of extents not divisible by area count
Message-ID: <1308679642-14694-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allocation should fail early if this condition is not met.

Quick fix for https://bugzilla.redhat.com/show_bug.cgi?id=707779
---
 lib/metadata/lv_manip.c    |    7 +++++++
 test/t-lvconvert-mirror.sh |    5 +++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3f36077..6cbb132 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1716,6 +1716,13 @@ static int _allocate(struct alloc_handle *ah,
 		return 1;
 	}
 
+        if (ah->area_multiple > 1 &&
+            (ah->new_extents - alloc_state.allocated) % ah->area_count) {
+		log_error("Number of extents requested (%d) needs to be divisible by %d.",
+			  ah->new_extents - alloc_state.allocated, ah->area_count);
+		return 0;
+	}
+
 	alloc_state.log_area_count_still_needed = ah->log_area_count;
 
 	if (ah->alloc == ALLOC_CONTIGUOUS)
diff --git a/test/t-lvconvert-mirror.sh b/test/t-lvconvert-mirror.sh
index 64c407b..ee986e4 100644
--- a/test/t-lvconvert-mirror.sh
+++ b/test/t-lvconvert-mirror.sh
@@ -248,3 +248,8 @@ lvconvert -m1 -i1 $vg/$lv1
 lvreduce -f -l1 $vg/$lv1
 lvextend -f -l10 $vg/$lv1
 lvremove -ff $vg/$lv1
+
+# extents must be divisible
+lvcreate -l15 -n $lv1 $vg
+not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
+lvremove -ff $vg/$lv1
-- 
1.7.5.4


