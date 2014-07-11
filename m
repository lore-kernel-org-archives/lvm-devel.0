From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:43 +0000 (UTC)
Subject: master - lvconvert: update help
Message-ID: <20140711113443.7558960701@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2988a917af8ca16814b067c1d73f899e871e1d4
Commit:        b2988a917af8ca16814b067c1d73f899e871e1d4
Parent:        970989655ff5cd9ca960bf3113b7bfdf6f575d78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:54:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:22 2014 +0200

lvconvert: update help

Extend help for lvconvert.
Use COMMON_OPTS for some common options.
---
 tools/commands.h |   68 ++++++++++++++++++-----------------------------------
 1 files changed, 23 insertions(+), 45 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 5fae835..1f9d03c 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -47,7 +47,6 @@ xx(devtypes,
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--unquoted]\n"
-   "\t[-v|--verbose]\n"
    "\t[--version]" "\n",
 
    aligned_ARG, binary_ARG, nameprefixes_ARG,
@@ -154,6 +153,10 @@ xx(lvchange,
    refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
    writebehind_ARG, writemostly_ARG, zero_ARG)
 
+#define COMMON_OPTS \
+	"\t[--commandprofile ProfileName] [-d|--debug] [-h|-?|--help]\n" \
+	"\t[--noudevsync] [-t|--test] [-v|--verbose] [--version] [-y|--yes]\n"
+
 xx(lvconvert,
    "Change logical volume layout",
    0,
@@ -165,88 +168,64 @@ xx(lvconvert,
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
-   "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
    "\t[--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t[--noudevsync]\n"
-   "\t[-v|--verbose]\n"
-   "\t[-y|--yes]\n"
-   "\t[--version]" "\n"
+   COMMON_OPTS
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
    "[--splitmirrors Images --trackchanges]\n"
-   "[--splitmirrors Images --name SplitLogicalVolumeName]\n"
-   "\t[--commandprofile ProfileName]\n"
+   "\t[--splitmirrors Images --name SplitLogicalVolumeName]\n"
+   COMMON_OPTS
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
    "--splitsnapshot\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--noudevsync]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   COMMON_OPTS
    "\tSnapshotLogicalVolume[Path]\n\n"
    
    "lvconvert "
-   "[-s|--snapshot]\n"
+   "[--type snapshot|-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--noudevsync]\n"
-   "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
-   "\t[--version]" "\n"
+   COMMON_OPTS
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
 
    "lvconvert "
    "--merge\n"
    "\t[-b|--background]\n"
    "\t[-i|--interval seconds]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[-v|--verbose]\n"
+   COMMON_OPTS
    "\tLogicalVolume[Path]\n\n"
 
    "lvconvert "
-   "--thinpool ThinPoolLogicalVolume[Path]\n"
+   "[--type thin[-pool]|-T|--thin]\n"
+   "\t[--thinpool ThinPoolLogicalVolume[Path]]\n"
    "\t[--chunksize size]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
+   "\t[--poolmetadataspare {y|n}]\n"
    "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
-   "\t [--poolmetadataspare {y|n}]\n"
    "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
-   "\t[-T|--thin ExternalLogicalVolume[Path]\n"
-   "\t [--originname NewExternalOriginVolumeName]]\n"
+   "\t[--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n\n"
+   COMMON_OPTS
+   "\t[ExternalOrigin|ThinDataPool]LogicalVolume[Path]\n\n"
 
    "lvconvert "
-   "--type cache-pool\n"
+   "[--type cache[-pool]|--cache]\n"
+   "\t[--cachepool CacheDataLogicalVolume[Path]]\n"
    "\t[--cachemode CacheMode]\n"
    "\t[--chunksize size]\n"
+   "\t[--poolmetadataspare {y|n}]]\n"
    "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
-   "\t [--poolmetadataspare {y|n}]]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\tCacheDataLogicalVolume[Path]\n\n"
+   COMMON_OPTS
+   "\t[Cache|CacheDataPool]LogicalVolume[Path]\n\n",
 
-   "lvconvert "
-   "--type cache\n"
-   "\t--cachepool CachePoolLogicalVolume[Path]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\tLogicalVolume[Path]\n\n",
-
-   alloc_ARG, background_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
+   alloc_ARG, background_ARG, cache_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
    corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
    mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
@@ -1278,4 +1257,3 @@ xx(version,
    "Display software and driver version information",
    PERMITTED_READ_ONLY,
    "version\n" )
-


