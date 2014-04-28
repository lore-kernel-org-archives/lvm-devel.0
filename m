From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:51 +0000 (UTC)
Subject: master - tests: improve coverage
Message-ID: <20140428104351.C823660269@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26989e0cd7fab4768f46803cd25bfc7499ab488e
Commit:        26989e0cd7fab4768f46803cd25bfc7499ab488e
Parent:        d8214cb1546f942cc7cbcfb4849b4549132d74a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:57:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:42:57 2014 +0200

tests: improve coverage

Test more code paths for lvscan & lvdisplay
---
 test/shell/listings.sh |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index d46ee7f..7d9c37e 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -61,10 +61,19 @@ dmsetup ls | grep "$PREFIX" | grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
-lvcreate -aey -l4 --type mirror -m2 -n $lv3 $vg
+lvcreate -aey -l2 --type mirror -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls|grep "$PREFIX"|grep -v "LVMTEST.*pv."
+lvcreate -l2 -s $vg/$lv3
+lvcreate -l1 -s -n inval $vg/$lv3
+lvcreate -l4 -I4 -i2 -n stripe $vg
+lvcreate -T $vg/pool -I4 -i2 -l5 -V1P -n thin
+# Invalidate snapshot
+not dd if=/dev/zero of="$DM_DEV_DIR/$vg/inval" bs=4K
+invalid lvscan "$dev1"
+lvdisplay --maps
+not lvscan --all
 
 #COMM vgs with options from pvs still treats arguments as VGs (bz193543)
 vgs -o pv_name,vg_name $vg


