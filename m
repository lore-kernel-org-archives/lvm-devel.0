From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:46 -0500
Subject: master - tests: rounding for pools changed to power of 2
Message-ID: <201901282140.x0SLekVJ002429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab1fd0cb37b75311e1ec4e13bbaea4a214b43285
Commit:        ab1fd0cb37b75311e1ec4e13bbaea4a214b43285
Parent:        78dd9d820da44c6b9907b481231745590e94613d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 22:05:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:17:27 2019 +0100

tests: rounding for pools changed to power of 2

Even with 64K chunk support, lvm2 will target power-of-2 chunks.
---
 test/shell/lvcreate-thin-big.sh |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 0625a59..595b8a9 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -75,12 +75,10 @@ check lv_field $vg/pool1_tmeta size "2.50m"
 check lv_field $vg/pool2_tmeta size "3.75m"
 lvremove -ff $vg
 
-# Block size of multiple 64KB needs >= 1.4
-if aux have_thin 1 4 0 ; then
-# Test chunk size is rounded to 64KB boundary
+# Test chunk size is rounded to power-of-2
 lvcreate -L10G --poolmetadatasize 4M -T $vg/pool
-check lv_field $vg/pool chunk_size "192.00k"
-fi
+check lv_field $vg/pool chunk_size "256.00k"
+
 # Old thinpool target required rounding to power of 2
 aux lvmconf "global/thin_disabled_features = [ \"block_size\" ]"
 lvcreate -L10G --poolmetadatasize 4M -T $vg/pool_old


