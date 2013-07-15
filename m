From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:40:52 +0000 (UTC)
Subject: master - tests: one missed automatic name
Message-ID: <20130715144052.C1DC960DEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=63d09b75f8e9a8790124f1ee0e2349a94e7a718d
Commit:        63d09b75f8e9a8790124f1ee0e2349a94e7a718d
Parent:        255db4c4e4d8e505bb5cf10892640cffd40ebed2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 16:38:55 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 16:38:55 2013 +0200

tests: one missed automatic name

Avoid depending on auto-names lvol%d.
---
 test/shell/lvcreate-thin.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index ed2631e..275c56f 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -140,11 +140,11 @@ lvcreate -K -s $vg/lv1 --name snap_lv1
 fsck -p $DM_DEV_DIR/$vg/snap_lv1
 lvcreate -s $vg/lv1 --name lv2
 lvcreate -s $vg/lv1 --name $vg/lv3
-lvcreate --type snapshot $vg/lv1
+lvcreate --type snapshot $vg/lv1 --name lv6
 lvcreate --type snapshot $vg/lv1 --name lv4
 lvcreate --type snapshot $vg/lv1 --name $vg/lv5
 
-check_lv_field_modules_ thin-pool lv1 snap_lv1 lv2 lv3 lvol1 lv4 lv5
+check_lv_field_modules_ thin-pool lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
 check vg_field $vg lv_count 8
 lvremove -ff $vg
 


