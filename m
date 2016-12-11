From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:06 +0000 (UTC)
Subject: master - tests: remove some leaking device
Message-ID: <20161211223506.6248060C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b902fd08f688c823937fec612a0ea72848289e56
Commit:        b902fd08f688c823937fec612a0ea72848289e56
Parent:        bcf59a1b185c07a3f7e10f9de13e83501f9a852b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 10:24:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

tests: remove some leaking device

These tests leaks devices (known bugs).
Remove them via dmsetup.

TODO: fix actual commands
---
 test/shell/lvconvert-repair-cache.sh |    4 ++++
 test/shell/lvcreate-repair.sh        |    3 +++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 565ebf4..f709813 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -132,3 +132,7 @@ not "$FSCK" -n "$DM_DEV_DIR/$vg/$lv1"
 aux enable_dev "$dev1"
 
 vgremove -ff $vg
+
+# FIXME - device should not be here
+should not dmsetup remove ${vg}-cpool_cmeta-missing_0_0
+should not dmsetup remove ${vg}-cpool_cdata-missing_0_0
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 53a6fc1..f3be28a 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -100,3 +100,6 @@ vgreduce --removemissing --force $vg
 # Failed to activate new LV.
 
 should lvcreate -l1 $vg "$dev1"
+should not dmsetup remove ${vg}-lvol0
+
+vgremove -ff $vg


