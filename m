From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:54 -0500
Subject: master - vdo: complete matching with thin syntax
Message-ID: <201901282140.x0SLes44002455@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87864f09f6a394b408329ce695e6c93cbee15bbd
Commit:        87864f09f6a394b408329ce695e6c93cbee15bbd
Parent:        b64021ee5f7dfb25ca99921992fef3aa89ce7c4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 20:32:42 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:18:17 2019 +0100

vdo: complete matching with thin syntax

Just like we support for thin-pool syntax:

lvcreate --thinpool new_tpoolname -L Size vg

add same support logic with for vdo-poo:

lvcreate --vdopool new_vpoolname -L Size vg

Also move description of syntax bellow thin-pool, so it's
correctly ordered in generated man page.
---
 tools/command-lines.in |   53 +++++++++++++++++++++++++----------------------
 tools/lvcreate.c       |    3 +-
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b06acec..eaa71ea 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -769,31 +769,6 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvcreate --type vdo --size SizeMB VG
-OO: --vdo, OO_LVCREATE, OO_LVCREATE_VDO, --virtualsize SizeMB, --stripes Number, --stripesize SizeKB,
-OP: PV ...
-IO: --mirrors 0
-ID: lvcreate_vdo_vol
-DESC: Create an LV that returns VDO when used.
-
-lvcreate --vdo --size SizeMB VG
-OO: OO_LVCREATE, OO_LVCREATE_VDO, --virtualsize SizeMB, --stripes Number, --stripesize SizeKB
-OP: PV ...
-IO: --mirrors 0
-ID: lvcreate_vdo_vol
-DESC: Create an VDO LV with VDO pool.
-FLAGS: SECONDARY_SYNTAX
-
-lvcreate --vdopool LV --virtualsize SizeMB VG
-OO: --vdo, --type vdo
-OP: PV ...
-IO: --mirrors 0
-ID: lvcreate_vdo_vol
-DESC: Create an VDO LV using existing VDO pool.
-FLAGS: SECONDARY_SYNTAX
-
----
-
 lvcreate --type zero --size SizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_zero_vol
@@ -1068,6 +1043,34 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
+lvcreate --type vdo --size SizeMB VG
+OO: --vdo, --vdopool LV_new, OO_LVCREATE, OO_LVCREATE_VDO,
+--virtualsize SizeMB, --stripes Number, --stripesize SizeKB,
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create a LV that returns VDO when used.
+
+lvcreate --vdo --size SizeMB VG
+OO: --vdopool LV_new, OO_LVCREATE, OO_LVCREATE_VDO,
+--virtualsize SizeMB, --stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create a VDO LV with VDO pool.
+FLAGS: SECONDARY_SYNTAX
+
+lvcreate --vdopool LV_new --size SizeMB VG
+OO: --vdo, --type vdo, OO_LVCREATE, OO_LVCREATE_VDO,
+--virtualsize SizeMB, --stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create a VDO LV with VDO pool.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
 # stripes option is not intuitive when creating a thin LV,
 # but here it applies to creating the new thin pool that
 # is used for the thin LV
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ebe51d9..ebe6c9f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -773,7 +773,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		segtype_str = SEG_TYPE_NAME_CACHE;
 	else if (arg_is_set(cmd, thin_ARG) || arg_is_set(cmd, thinpool_ARG))
 		segtype_str = SEG_TYPE_NAME_THIN;
-	else if (arg_is_set(cmd, vdo_ARG))
+	else if (arg_is_set(cmd, vdo_ARG) || arg_is_set(cmd, vdopool_ARG))
 		segtype_str = SEG_TYPE_NAME_VDO;
 	else if (arg_is_set(cmd, virtualsize_ARG)) {
 		if (arg_is_set(cmd, virtualoriginsize_ARG))
@@ -862,6 +862,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	thinpool_ARG
 
 #define VDO_POOL_ARGS \
+	vdopool_ARG,\
 	compression_ARG,\
 	deduplication_ARG
 


