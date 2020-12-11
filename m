From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Dec 2020 22:26:08 +0000 (GMT)
Subject: main - partial flag for writecache and integrity
Message-ID: <20201211222608.7D09E3850425@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b84a9927b78727efffbb257a61e9e95a648cdfab
Commit:        b84a9927b78727efffbb257a61e9e95a648cdfab
Parent:        23ef67776210ad6c55f4dd7475b806337140c513
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 11 15:56:04 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 11 16:25:25 2020 -0600

partial flag for writecache and integrity

When a writecache sublv or an integrity metadata sublv
are partial (missing a dev), set the partial flag on
the upper level LV also, as is done for other sublvs.
---
 lib/metadata/metadata.c        |  4 ++++
 test/shell/writecache-split.sh | 10 ++++++++++
 2 files changed, 14 insertions(+)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d04b8d8ba..f4d07a4f7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1916,6 +1916,10 @@ static int _lv_each_dependency(struct logical_volume *lv,
 			return_0;
 		if (lvseg->metadata_lv && !fn(lvseg->metadata_lv, data))
 			return_0;
+		if (lvseg->writecache && !fn(lvseg->writecache, data))
+			return_0;
+		if (lvseg->integrity_meta_dev && !fn(lvseg->integrity_meta_dev, data))
+			return_0;
 		for (s = 0; s < lvseg->area_count; ++s) {
 			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
 				return_0;
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index d1b14bfd3..5723f7aab 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -99,6 +99,11 @@ lvchange -an $vg/$lv1
 
 aux disable_dev "$dev2"
 
+lvs -a -o+lv_health_status $vg |tee out
+grep $lv1 out | grep partial
+grep $lv2 out | grep partial
+check lv_attr_bit health $vg/$lv1 "p"
+
 not lvconvert --splitcache $vg/$lv1
 lvconvert --splitcache --force --yes $vg/$lv1
 
@@ -128,6 +133,11 @@ lvchange -an $vg/$lv1
 
 aux disable_dev "$dev3"
 
+lvs -a -o+lv_health_status $vg |tee out
+grep $lv1 out | grep partial
+grep $lv2 out | grep partial
+check lv_attr_bit health $vg/$lv1 "p"
+
 not lvconvert --splitcache $vg/$lv1
 lvconvert --splitcache --force --yes $vg/$lv1
 


