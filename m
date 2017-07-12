From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Jul 2017 12:19:29 -0400
Subject: master - tests: fix for new hardened bash
Message-ID: <201707121619.v6CGJTfB027932@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c838e79cd2e1dc3c6054e661e6a2f65c0d5c6144
Commit:        c838e79cd2e1dc3c6054e661e6a2f65c0d5c6144
Parent:        e329da173f51c6b1c2af1fc144a52a740955f445
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 18:03:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 18:05:56 2017 +0200

tests: fix for new hardened bash

Add missing get_devs.
When $7 is not given use empty string.
See if we can live with less RAM disk for PVs.
Drop limitation on single core as presence 1.12 should address this.
---
 test/shell/lvconvert-raid-reshape.sh |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 4f4f7c2..c93d79b 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -20,9 +20,11 @@ aux have_raid 1 12 0 || skip
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
+#aux have_multi_core || skip
+# dropping single-core limitation with  1.12 target
 
-aux prepare_pvs 65 64
+aux prepare_pvs 65 32
+get_devs
 
 vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
@@ -51,7 +53,7 @@ function _lvconvert
 	local stripes=$4
 	local vg=$5
 	local lv=$6
-	local region_size=$7
+	local region_size=${7-}
 	local wait_and_check=1
 	local R=""
 


