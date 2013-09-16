From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 13:41:21 +0000 (UTC)
Subject: master - tests: no activate LV
Message-ID: <20130916134121.8B33060D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61427af377891b011089b14154fe0c1d2845fd21
Commit:        61427af377891b011089b14154fe0c1d2845fd21
Parent:        2abaf87a9b36cff2f32398a8dfb26609c0f56e14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 15:38:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 15:38:42 2013 +0200

tests: no activate LV

Since our current vgcfgbackup/restore doesn't deal
with difference of active volumes between current and
restored set of volumes -  run test with inactive LVs.
---
 test/shell/vgcfgbackup-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index b04ac86..314ecdd 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -22,7 +22,7 @@ vgcfgbackup -f bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
 # increase seqno
-lvcreate -l1 $vg1
+lvcreate -an -Zn -l1 $vg1
 vgcfgrestore -f bak-$vg1 $vg1
 vgremove -ff $vg1 $vg2
 


