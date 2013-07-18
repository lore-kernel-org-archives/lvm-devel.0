From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:56 +0000 (UTC)
Subject: master - thin: add lvconvert pool metadata spare
Message-ID: <20130718162656.7403561019@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aab53f46eedda64ca8cd73b25eaac9aea7894957
Commit:        aab53f46eedda64ca8cd73b25eaac9aea7894957
Parent:        307578495511e35398e0f9ef3f796641dfa5038e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 13:35:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:44 2013 +0200

thin: add lvconvert pool metadata spare

Support poolmetadataspare when convering volumes into thin pool.
Same rules applied as with lvcreate.
---
 tools/commands.h  |    6 ++++--
 tools/lvconvert.c |   11 +++++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 3c9ed82..fc4f7ef 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -170,6 +170,7 @@ xx(lvconvert,
    "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
    "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t [--poolmetadataspare {y|n}]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
@@ -180,8 +181,9 @@ xx(lvconvert,
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
index 5e7484e..97ef7e4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -21,6 +21,7 @@ struct lvconvert_params {
 	int snapshot;
 	int merge;
 	int merge_mirror;
+	int poolmetadataspare;
 	int thin;
 	int yes;
 	int zero;
@@ -253,6 +254,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	} else if (arg_count(cmd, discards_ARG)) {
 		log_error("--discards is only valid with --thinpool.");
 		return 0;
+	} else if (arg_count(cmd, poolmetadataspare_ARG)) {
+		log_error("--poolmetadataspare is only valid with --thinpool.");
+		return 0;
 	}
 
 	/*
@@ -486,6 +490,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return_0;
 	}
 
+	/* TODO: default in lvm.conf ? */
+	lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
+					      DEFAULT_POOL_METADATA_SPARE);
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
@@ -2158,6 +2165,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!handle_pool_metadata_spare(pool_lv->vg, metadata_lv->le_count,
+					lp->pvh, lp->poolmetadataspare))
+		return_0;
+
 	old_name = data_lv->name; /* Use for pool name */
 	/*
 	 * Since we wish to have underlaying devs to match _tdata


