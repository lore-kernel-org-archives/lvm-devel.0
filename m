From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Mar 2017 23:05:00 -0400
Subject: master - commands: fix combined thin pool and vol create defs
Message-ID: <201703220305.v2M3506K003517@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14c4d32247808fc0c32944a09ea06611244fdb3d
Commit:        14c4d32247808fc0c32944a09ea06611244fdb3d
Parent:        3be2e61c9fd775c03636937001a3f5e593096c85
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 20 21:48:22 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 21 22:04:01 2017 -0500

commands: fix combined thin pool and vol create defs

Fixes command defs related to creating a new thin pool and
then a new thin lv in the new pool.

1. lvcreate --size --virtualsize --thinpool
   Needs a cmd def, it was missing.
   The def is unique by the three required
   options: size, virtualsize and thinpool.

2. lvcreate --size --virtualsize --thinpool VG
   Needs a cmd def, it was missing.
   The def is unique by the three required
   options: size, virtualsize and thinpool,
   and one required positional arg: VG.

3. lvcreate --thin --virtualsize --size LV_new|VG
   This existing def should not accept an optional
   --type thin, which if used makes it indistinct
   from another def.

4. lvcreate --size --virtualsize VG
   This existing def should not accept an optional
   --type thin or --thin, which if used makes it
   indistinct from other defs (e.g. 3)
---
 tools/command-lines.in |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2fec553..f8a5e57 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1016,8 +1016,21 @@ DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named by the --thinpool arg.
 
 # alternate form of lvcreate --type thin
-lvcreate --thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
-OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_and_thinpool
+DESC: Create a thin LV, first creating a thin pool for it,
+DESC: where the new thin pool is named by the --thinpool arg
+DESC: (variant, infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+# same as prev but accepts VG pos arg
+# alternate form of lvcreate --type thin
+lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new VG
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 IO: --mirrors 0
@@ -1042,7 +1055,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
-OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+OO: OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 IO: --mirrors 0
@@ -1056,7 +1069,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --size SizeMB --virtualsize SizeMB VG
-OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+OO: --type snapshot, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 IO: --mirrors 0


