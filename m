From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Jun 2023 11:04:04 +0000 (GMT)
Subject: main - tests: simplify
Message-ID: <20230625110404.831EA3858C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa434a18373e42108aed319d3257c935f510f2c3
Commit:        fa434a18373e42108aed319d3257c935f510f2c3
Parent:        b8db2c0a4a4bbfc39338141cd7eee67c05b2b31d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 25 12:58:27 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 25 13:02:36 2023 +0200

tests: simplify

---
 test/shell/vgsplit-cache.sh | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgsplit-cache.sh b/test/shell/vgsplit-cache.sh
index 202e4b562..65a711f75 100644
--- a/test/shell/vgsplit-cache.sh
+++ b/test/shell/vgsplit-cache.sh
@@ -20,6 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 aux have_cache 1 3 0 || skip
 
 aux prepare_vg 7
+vgcfgbackup -f vgb $vg
 
 lvcreate -L5 -n $lv2 $vg "$dev2"
 lvcreate -L5 -n $lv3 $vg "$dev3"
@@ -78,7 +79,7 @@ vgremove -ff $vg1
 #
 # Check we handle pmspare for splitted VGs
 #
-aux prepare_vg 7
+vgcfgrestore -f vgb $vg
 
 # Create cache-pool and pmspare on single PV1
 lvcreate -L10 --type cache-pool $vg/cpool "$dev1"
@@ -100,7 +101,7 @@ vgremove $vg
 vgremove -f $vg1
 
 
-aux prepare_vg 7
+vgcfgrestore -f vgb $vg
 
 # Again - now with handling _pmspare by vgsplit
 lvcreate -L10 --type cache-pool $vg/cpool "$dev1"

