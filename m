From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Sep 2012 19:32:59 +0000 (UTC)
Subject: master - RAID: '--test' should not cause a valid create command to fail
Message-ID: <20120905193259.D25284A77@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b49b98d50c558a142d0a2ef55279eea00bd36eba
Commit:        b49b98d50c558a142d0a2ef55279eea00bd36eba
Parent:        c3eb3a76875ccf8c544c991bc52b6b3061bf8f58
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 5 14:32:06 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 5 14:32:06 2012 -0500

RAID: '--test' should not cause a valid create command to fail

It is necessary when creating a RAID LV to clear the new metadata areas.
Failure to do so could result in a prepopulated bitmap that would cause
the new array to skip syncing portions of the array.  It is a requirement
that the metadata LVs be activated and cleared in the process of creating.
However in test mode, this requirement should be lifted - no new LVs should
be created or written to.
---
 WHATS_NEW                 |    1 +
 lib/metadata/lv_manip.c   |    6 ++++++
 lib/metadata/raid_manip.c |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 28d1908..8718a0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix RAID LV creation with '--test' so valid commands do not fail.
   Add lvm_lv_rename() to lvm2api.
   Fix setvbuf code by closing and reopening stream before changing buffer.
   Disable private buffering when using liblvm.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 617d4b7..3702caf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2623,6 +2623,12 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 
 		for (s = 0; s < seg->area_count; s++) {
 			meta_lv = seg_metalv(seg, s);
+
+			if (test_mode()) {
+				lv_set_hidden(meta_lv);
+				continue;
+			}
+
 			if (!activate_lv(meta_lv->vg->cmd, meta_lv)) {
 				log_error("Failed to activate %s/%s for clearing",
 					  meta_lv->vg->name, meta_lv->name);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c786a7d..b5552cb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -304,6 +304,9 @@ static int _clear_lv(struct logical_volume *lv)
 {
 	int was_active = lv_is_active(lv);
 
+	if (test_mode())
+		return 1;
+
 	if (!was_active && !activate_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to activate %s for clearing",
 			  lv->name);


