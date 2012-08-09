From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Aug 2012 14:26:50 +0000 (UTC)
Subject: master - thin: lvcreate --discards
Message-ID: <20120809142650.027821857@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54c24193f535660478e88af76340eef40dc3223c
Commit:        54c24193f535660478e88af76340eef40dc3223c
Parent:        80bf4eb03546903d88affbb866c9c3750bfa08e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 9 12:20:47 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 9 16:25:52 2012 +0200

thin: lvcreate --discards

---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    1 +
 lib/metadata/metadata-exported.h |    1 +
 tools/commands.h                 |    6 +++++-
 tools/lvcreate.c                 |    7 +++++++
 5 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a2a9285..dcd51ff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -3,6 +3,7 @@ Version 2.02.98
   Use 'ignore' discards for thin metadata created with older versions.
   Use proper condition to check for unsupported discards settings.
   Update lvs manpage with discards (2.02.97).
+  Add support for lvcreate --discards.
 
 Version 2.02.97 - 7th August 2012
 =================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index daa90da..70b984e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4423,6 +4423,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	if (seg_is_thin_pool(lp)) {
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
 		first_seg(lv)->chunk_size = lp->chunk_size;
+		first_seg(lv)->discards = lp->discards;
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
 		first_seg(lv)->low_water_mark = 0;
 	} else if (seg_is_thin_volume(lp)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 74edb58..f46fccc 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -592,6 +592,7 @@ struct lvcreate_params {
 	int log_count; /* mirror */
 	int nosync; /* mirror */
 	activation_change_t activate; /* non-snapshot, non-mirror */
+	thin_discards_t discards;     /* thin */
 
 	const char *origin; /* snap */
 	const char *pool;   /* thin */
diff --git a/tools/commands.h b/tools/commands.h
index 2a4404e..602fe81 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -180,6 +180,10 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
+   "\t  [--discards {ignore|nopassdown|passdown}]\n"
+   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
+   "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index da2b925..6aecf1d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -797,6 +797,13 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_raid_params(lp, cmd))
 		return_0;
 
+	if (lp->create_thin_pool) {
+		lp->discards = arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+	} else if (arg_count(cmd, discards_ARG)) {
+		log_error("--discards is only available for thin pool creation.");
+		return 0;
+	}
+
 	if (lp->snapshot && lp->thin && arg_count(cmd, chunksize_ARG))
 		log_warn("WARNING: Ignoring --chunksize with thin snapshots.");
 	else if (lp->thin && !lp->create_thin_pool) {


