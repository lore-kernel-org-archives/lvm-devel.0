From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Oct 2017 08:06:02 -0400
Subject: master - tests: better clustering support
Message-ID: <201710261206.v9QC62Yr008102@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b765288bf242bbbdc93ef2f76ae4d3f7bdeb5868
Commit:        b765288bf242bbbdc93ef2f76ae4d3f7bdeb5868
Parent:        1e80ec892615f9da897da518cb3c55261d2bd51e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 26 14:00:44 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 26 14:04:58 2017 +0200

tests: better clustering support

Use exclusive activation for snapshot conversion since we can only
convert exclusively active volumes.
---
 test/shell/lvconvert-snapshot-cache.sh  |    2 +-
 test/shell/lvconvert-snapshot-mirror.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-snapshot-cache.sh b/test/shell/lvconvert-snapshot-cache.sh
index 396f431..0d9c9c6 100644
--- a/test/shell/lvconvert-snapshot-cache.sh
+++ b/test/shell/lvconvert-snapshot-cache.sh
@@ -28,7 +28,7 @@ vgchange -s 16k $vg
 lvcreate -L1 -n cow $vg
 
 # Thin and snapshot conversion
-lvcreate -L1 -n ch $vg
+lvcreate -aey -L1 -n ch $vg
 lvcreate -H -L1 -n cpool $vg/ch
 
 # Cannot create snapshot of cpool
diff --git a/test/shell/lvconvert-snapshot-mirror.sh b/test/shell/lvconvert-snapshot-mirror.sh
index 8af9e25..01c19d9 100644
--- a/test/shell/lvconvert-snapshot-mirror.sh
+++ b/test/shell/lvconvert-snapshot-mirror.sh
@@ -24,7 +24,7 @@ vgchange -s 16k $vg
 lvcreate -L1 -n cow $vg
 
 # Mirror and snapshot conversion
-lvcreate --type mirror -L1 -m1 -n mir $vg
+lvcreate -aye --type mirror -L1 -m1 -n mir $vg
 
 # Cannot create snapshot of mirror leg
 not lvcreate -s -L1 $vg/mir_mimage_0 2>&1 | tee err


