From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:38 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: clear write to /tmp
Message-ID: <20130605120538.8BB5860E50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20868482dd12ab2bc77ba57d6c159fb80ad56a94
Commit:        20868482dd12ab2bc77ba57d6c159fb80ad56a94
Parent:        8c6f3006e742b738545e7c8d89f0c12b7eb436ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 2 00:27:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: clear write to /tmp

---
 test/shell/lvresize-rounding.sh |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index ad8d9c0..26dfb49 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -28,10 +28,6 @@ lvresize -l+64 -i3 -I64 $vg/$lv1
 lvresize -l+64 -i3 -I128 $vg/$lv1
 
 #lvcreate -l100%FREE -i3 -I64 --alloc anywhere $vg
-
-dmsetup table
-
-vgcfgbackup -f /tmp/vg $vg
 vgremove -f $vg
 
 # 15 extents
@@ -52,7 +48,6 @@ check vg_field $vg vg_free_count 2
 lvreduce -f -l50%LV $vg/$lv1
 vgremove -f $vg
 
-
 vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
 
 # Expect to play with 15 extents


