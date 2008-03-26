From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 26 Mar 2008 14:34:22 -0400 (EDT)
Subject: [PATCH] lvconvert should not allow creating a snapshot of a mirror
Message-ID: <Pine.LNX.4.64.0803261404400.15040@porkchop.devel.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

lvconvert allows creating snapshots of mirrors --- and it shouldn't.

lvconvert -s vg1/mirror vg1/snap
will create snapshot of a mirrored image. It should fail.

lvconvert -s vg1/lv vg1/mirror
writes "Logical volume mirror converted." and does nothing. It should 
return an error.

This patch fixes both scenarios.

Mikulas
-------------- next part --------------
This patch fixes bugs in lvconvert regarding mixing snapshots and mirrors.

Assume that you have two independent LVs: vg1/lv and vg1/lv_mirror.
vg1/lv is a simple linear storage, vg1/lv_mirror is a mirror.

1. lvconvert -s vg1/lv vg1/lv_mirror writes this output:
	vg1/lv_mirror: Converted: 100.0%
	Logical volume lv_mirror converted.
and it really does nothing. It should write an error message.

2. lvconvert -s vg1/lv_mirror vg1/lv creates a snapshot of a mirrored volume,
which is unsupported and may cause problems with other tools.
(lvcreate doesn't allow creating snapshots of mirrors)
lvconvert should fail with an error message in this situation.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 tools/lvconvert.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

Index: LVM2.2.02.33/tools/lvconvert.c
===================================================================
--- LVM2.2.02.33.orig/tools/lvconvert.c	2008-03-26 18:57:29.000000000 +0100
+++ LVM2.2.02.33/tools/lvconvert.c	2008-03-26 19:03:13.000000000 +0100
@@ -627,10 +627,12 @@ static int lvconvert_snapshot(struct cmd
 		return 0;
 	}
 
-	if (org->status & (LOCKED|PVMOVE) || lv_is_cow(org)) {
+	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
 		log_error("Unable to create a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
-			  org->status & PVMOVE ? "pvmove" : "snapshot");
+			  org->status & PVMOVE ? "pvmove" :
+			  org->status & MIRRORED ? "mirrored" :
+			  "snapshot");
 		return 0;
 	}
 
@@ -705,15 +707,19 @@ static int lvconvert_single(struct cmd_c
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
+	if (lp->snapshot) {
+		if (lv->status & MIRRORED) {
+			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
+			return ECMD_FAILED;
+		}
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-		if (!lvconvert_mirrors(cmd, lv, lp))
+		if (!lvconvert_snapshot(cmd, lv, lp))
 			return ECMD_FAILED;
-	} else if (lp->snapshot) {
+	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-		if (!lvconvert_snapshot(cmd, lv, lp))
+		if (!lvconvert_mirrors(cmd, lv, lp))
 			return ECMD_FAILED;
 	}
 
