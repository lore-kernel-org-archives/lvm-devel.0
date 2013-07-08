From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:58 +0200
Subject: [PATCH 6/7] thin: add lvconvert pool metadata spare
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <ff74fa968e49f9f845e74cba6ee873b4cdf69768.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support poolmetadataspare when convering volumes into thin pool.
Same rules applied as with lvcreate.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h  |  6 ++++--
 tools/lvconvert.c | 11 +++++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 3aec4bc..cb4ef44 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -168,6 +168,7 @@ xx(lvconvert,
    "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
    "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t [--poolmetadataspare {y|n}]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
@@ -178,8 +179,9 @@ xx(lvconvert,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    readahead_ARG, regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
-   chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
-   originname_ARG, thin_ARG, thinpool_ARG,
+   chunksize_ARG, discards_ARG, originname_ARG,
+   poolmetadata_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
+   thin_ARG, thinpool_ARG,
    use_policies_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3ea1987..7cbf3d4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -22,6 +22,7 @@ struct lvconvert_params {
 	int snapshot;
 	int merge;
 	int merge_mirror;
+	int poolmetadataspare;
 	int thin;
 	int yes;
 	int zero;
@@ -254,6 +255,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	} else if (arg_count(cmd, discards_ARG)) {
 		log_error("--discards is only valid with --thinpool.");
 		return 0;
+	} else if (arg_count(cmd, poolmetadataspare_ARG)) {
+		log_error("--poolmetadataspare is only valid with --thinpool.");
+		return 0;
 	}
 
 	/*
@@ -487,6 +491,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return_0;
 	}
 
+	/* TODO: default in lvm.conf ? */
+	lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
+					      DEFAULT_POOL_METADATA_SPARE);
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
@@ -2159,6 +2166,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!handle_pool_metadata_spare(pool_lv->vg, metadata_lv->le_count,
+					lp->pvh, lp->poolmetadataspare))
+		return_0;
+
 	old_name = data_lv->name; /* Use for pool name */
 	/*
 	 * Since we wish to have underlaying devs to match _tdata
-- 
1.8.3.1


