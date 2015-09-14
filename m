From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 18:20:46 +0000 (UTC)
Subject: master - tests: early check for snapshot-merge
Message-ID: <20150914182046.65C9060CF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cee9ed22441187a2a3a6290d1e07428df0171144
Commit:        cee9ed22441187a2a3a6290d1e07428df0171144
Parent:        e7e15631ddd9150fa7643ae2debac797dabc5d25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 11:02:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 20:18:54 2015 +0200

tests: early check for snapshot-merge

---
 test/shell/snapshot-merge.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 44d6c24..ff4f8d1 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -11,6 +11,9 @@
 
 . lib/inittest
 
+# test if snapshot-merge target is available
+aux target_at_least snapshot-merge 1 0 0 || skip
+
 which mkfs.ext3 || skip
 
 lvdev_() {
@@ -45,8 +48,6 @@ mkdir test_mnt
 
 # test full merge of a single LV
 setup_merge_ $vg $lv1
-# now that snapshot LV is created: test if snapshot-merge target is available
-aux target_at_least snapshot-merge 1 0 0 || skip
 
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge


