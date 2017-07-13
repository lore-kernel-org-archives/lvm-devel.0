From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 18:44:36 -0400
Subject: master - tests: skip test for non dirty cache
Message-ID: <201707132244.v6DMiap0013411@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a2448a4ed60deae8919e90edd6f4e94e450d19a
Commit:        8a2448a4ed60deae8919e90edd6f4e94e450d19a
Parent:        e682af78789b34bbcb1706c16f629dfd93915bf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 14 00:42:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 00:42:40 2017 +0200

tests: skip test for non dirty cache

Seems some cache LV can't be made dirty easily with older
cache policy implementations....
---
 test/shell/lvconvert-cache-abort.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 701a41d..e771947 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -40,7 +40,12 @@ done
 # Delay dev to ensure we have some time to 'capture' interrupt in flush
 aux delay_dev "$dev1" 100 0 "$(get first_extent_sector "$dev1"):"
 
-lvdisplay --maps $vg
+# TODO, how to make writeback cache dirty
+test "$(get lv_field $vg/$lv1 cache_dirty_blocks)" -gt 0 || {
+	lvdisplay --maps $vg
+	skip "Cannot make a dirty writeback cache LV."
+}
+
 sync
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
 


