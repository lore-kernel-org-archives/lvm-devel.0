From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:06 +0200
Subject: [PATCH 6/6] thin: unfinished lvconvert
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <9f3caa7b7c89a4fcdee0e94e042410d7d1cba2f8.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

begining of lvconvert support for spare LV.
will match what can be made in lvcreate.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h  | 3 ++-
 tools/lvconvert.c | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/commands.h b/tools/commands.h
index d1cef36..b1e5544 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -166,6 +166,7 @@ xx(lvconvert,
    "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
    "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t [--spare {y|n}]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
@@ -177,7 +178,7 @@ xx(lvconvert,
    readahead_ARG, regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
-   originname_ARG, thin_ARG, thinpool_ARG,
+   originname_ARG, spare_ARG, thin_ARG, thinpool_ARG,
    use_policies_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index be6b55f..7ee3d4b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -22,6 +22,7 @@ struct lvconvert_params {
 	int snapshot;
 	int merge;
 	int merge_mirror;
+	int spare;
 	int thin;
 	int yes;
 	int zero;
@@ -495,6 +496,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return_0;
 	}
 
+	lp->spare = arg_uint_value(cmd, spare_ARG, 0);
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
 
-- 
1.8.2.1


