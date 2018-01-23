From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Jan 2018 05:46:35 -0500
Subject: master - tests: update set of devices
Message-ID: <201801231046.w0NAkZco027228@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=102926ed9fb231fbe54d020dcc5873bf97c09e51
Commit:        102926ed9fb231fbe54d020dcc5873bf97c09e51
Parent:        6e9148e7ab8d073c448ed56c5e2e019751feff88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 23 10:21:58 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 23 11:45:18 2018 +0100

tests: update set of devices

Previous change added slighly more complex mapping so missed to update
few pieces.
---
 test/shell/pvmove-all-segtypes.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index f672290..38b5267 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -47,8 +47,8 @@ check lv_field $vg/${lv1}_foo seg_count 2
 check lv_field $vg/$lv1 seg_count 2
 check dev_md5sum $vg $lv1
 pvmove -n $lv1 "$dev5" "$dev4"
-check lv_tree_on $vg $lv1 "$dev4"
-check lv_tree_on $vg ${lv1}_foo "$dev5"
+check lv_tree_on $vg $lv1 "$dev3" "$dev4"
+check lv_tree_on $vg ${lv1}_foo "$dev2" "$dev5"
 check dev_md5sum $vg $lv1
 lvremove -ff $vg
 


