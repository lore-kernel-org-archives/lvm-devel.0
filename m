From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:31:14 -0400
Subject: stable-2.02 - tests: rounding for pools changed to power of 2
Message-ID: <201904301131.x3UBVEeb020506@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=057d8668890367525fc830d7a08413eefe0243af
Commit:        057d8668890367525fc830d7a08413eefe0243af
Parent:        e79e092f8bd41d3d589be0a10ac5addeaa8a3126
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 22:05:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 13:14:27 2019 +0200

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


