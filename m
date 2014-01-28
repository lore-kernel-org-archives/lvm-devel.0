From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Jan 2014 09:41:11 +0000 (UTC)
Subject: master - tests: check for mkfs
Message-ID: <20140128094111.8A633610D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc5f40ee1c7c409c17f85a55f6a8b2606067e76e
Commit:        bc5f40ee1c7c409c17f85a55f6a8b2606067e76e
Parent:        c0bd436dcb45849aff2e953432e5b40e55e0f712
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 28 09:54:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 28 10:40:08 2014 +0100

tests: check for mkfs

Test mkfs.ext3 presence for test.
Test also on singlenode cluster.
Speed up a bit slowed down device.
---
 test/shell/lock-parallel.sh |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index f8e72c3..4820129 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -14,19 +14,20 @@
 
 . lib/test
 
+which mkfs.ext3 || skip
+
 aux prepare_vg
-test -e LOCAL_CLVMD && skip
 
 lvcreate -L10 -n $lv1 $vg
 lvcreate -l1 -n $lv2 $vg
-mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext3 "$DM_DEV_DIR/$vg/$lv1"
 
 # Slowdown PV for resized LV
-aux delay_dev "$dev1" 40 40
+aux delay_dev "$dev1" 20 20
 
 lvresize -L-5 -r $vg/$lv1 &
 
-# Let's wait till resize start
+# Let's wait till resize starts
 sleep 2
 
 lvremove -f $vg/$lv2


