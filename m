From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Thu, 2 Nov 2017 11:00:49 -0400
Subject: master - testsuite: Fix problem when checking RAID4/5/6 for mismatches.
Message-ID: <201711021500.vA2F0nup018024@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e8dec2f387d8eaf48195ef38ab7699d4a8385ed
Commit:        9e8dec2f387d8eaf48195ef38ab7699d4a8385ed
Parent:        50130328450d1f624d30438ca835d40e0d4f942d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Nov 2 09:49:35 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Nov 2 09:49:35 2017 -0500

testsuite:  Fix problem when checking RAID4/5/6 for mismatches.

The lvchange-raid[456].sh test checks that mismatches can be detected
properly.  It does this by writing garbage to the back half of one of
the legs directly.  When performing a "check" or "repair" of mismatches,
MD does a good job going directly to disk and bypassing any buffers that
may prevent it from seeing mismatches.  However, in the case of RAID4/5/6
we have the stripe cache to contend with and this is not bypassed.  Thus,
mismatches which have /just/ happened to an area that now populates the
stripe cache may be overlooked.  This isn't a serious issue, however,
because the stripe cache is short-lived and reasonably small.  So, while
there may be a small window of time between the disk changing underneath
the RAID array and when you run a "check"/"repair" - causing a mismatch
to be missed - that would be no worse than if a user had simply run a
"check" a few seconds before the disk changed.  IOW, it simply isn't worth
making a fuss over dropping the stripe cache before beginning a "check" or
"repair" (which we actually did attempt to do a while back).

So, to get the test running smoothly, we simply deactivate and reactivate
the LV to force the stripe cache to be dropped and then proceed.  We could
just as easily wait a few seconds for the stripe cache to empty also.
---
 test/shell/lvchange-raid.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 8c22481..604b7f7 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -43,6 +43,9 @@ run_writemostly_check() {
 
 	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
 		$vg $lv $segtype
+
+	# I've seen this sync fail.  when it does, it looks like sync
+	# thread has not been started... haven't repo'ed yet.
 	aux wait_for_sync $vg $lv
 
 	# No writemostly flag should be there yet.
@@ -169,6 +172,14 @@ run_syncaction_check() {
 	dd if=/dev/urandom of="$device" bs=1k count=$size seek=$seek
 	sync
 
+	# Cycle the LV so we don't grab stripe cache buffers instead
+	#  of reading disk.  This can happen with RAID 4/5/6.  You
+	#  may think this is bad because those buffers could prevent
+	#  us from seeing bad disk blocks, however, the stripe cache
+	#  is not long lived.  (RAID1/10 are immediately checked.)
+	lvchange -an $vg/$lv
+	lvchange -ay $vg/$lv
+
 	# "check" should find discrepancies but not change them
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv


