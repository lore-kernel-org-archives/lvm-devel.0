From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:08 -0400
Subject: master - tests: do not try to create 1K extents
Message-ID: <201805122139.w4CLd8HS005423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edede1d20f413a5baee5474e40cffd135c133bef
Commit:        edede1d20f413a5baee5474e40cffd135c133bef
Parent:        093428b067d751f9a6d645d430bfff6fd3031acd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 22:52:41 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 22:52:41 2018 +0200

tests: do not try to create 1K extents

---
 test/shell/vgcreate-usage.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index ee7dd99..40eb99b 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -73,10 +73,10 @@ not vgcreate $vg "$dev3"
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
 not vgcreate --physicalextentsize 0k $vg "$dev1" "$dev2"
-vgcreate --physicalextentsize 1k $vg "$dev1" "$dev2"
-check vg_field $vg vg_extent_size 1.00k
+vgcreate --physicalextentsize 4k $vg "$dev1" "$dev2"
+check vg_field $vg vg_extent_size 4.00k
 vgremove -ff $vg
-not vgcreate --physicalextentsize 3K $vg "$dev1" "$dev2"
+not vgcreate --physicalextentsize 7K $vg "$dev1" "$dev2"
 not vgcreate --physicalextentsize 1024t $vg "$dev1" "$dev2"
 #not vgcreate --physicalextentsize 1T $vg "$dev1" "$dev2"
 # FIXME: vgcreate allows physicalextentsize larger than pv size!


