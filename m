From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:09 +0000 (UTC)
Subject: master - test: vgcfgbackup-usage
Message-ID: <20160506140109.8CF3060722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f194d5f169f6977eb0e4ffeb4924cdcb6c8dcf77
Commit:        f194d5f169f6977eb0e4ffeb4924cdcb6c8dcf77
Parent:        4c5ad5a04c2d28920e1f5abb72d88e3af49fb2f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 26 12:20:09 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: vgcfgbackup-usage

Split the lvm1 part into a separate test.
---
 test/shell/vgcfgbackup-usage.sh |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 31b0a6f..f923049 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -74,17 +74,3 @@ vgcfgrestore -f "backup.$$1" $vg
 vgchange -an $vg
 vgremove -f $vg
 
-
-# vgcfgbackup correctly stores metadata LVM1 with missing PVs
-# FIXME: clvmd seems to have problem with metadata format change here
-# fix it and remove this vgscan
-if test -n "$LVM_TEST_LVM1" ; then
-vgscan
-pvcreate -M1 $(cat DEVICES)
-vgcreate -M1 -c n $vg $(cat DEVICES)
-lvcreate -l1 -n $lv1 $vg "$dev1"
-pvremove -ff -y "$dev2"
-not lvcreate -l1 -n $lv1 $vg "$dev3"
-vgcfgbackup -f "backup.$$" $vg
-fi
-


