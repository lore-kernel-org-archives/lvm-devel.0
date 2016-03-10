From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:28 +0000 (UTC)
Subject: master - lvconvert: update --help
Message-ID: <20160310174028.0231D60DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f4451193b8db4bd9c894248f50da9319704293e
Commit:        9f4451193b8db4bd9c894248f50da9319704293e
Parent:        5bfc0edd12d1f4e31fcd3813edd8de99816ec6c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 5 21:02:30 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

lvconvert: update --help

Use  <>  around user entered option parameters to make it visually
different (just like we use Italic style in man page).

TODO:

In the future we should consistently provide such notation and
possibly generate it automagically from some internal data structures.

Preferably for man pages as well so we report actual set of supported
options.
---
 tools/commands.h |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index f676bbe..aba5b40 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -197,28 +197,28 @@ xx(lvchange,
    test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 #define COMMON_OPTS \
-	"\t[--commandprofile ProfileName] [-d|--debug] [-h|-?|--help]\n" \
+	"\t[--commandprofile <ProfileName>] [-d|--debug] [-h|-?|--help]\n" \
 	"\t[--noudevsync] [-t|--test] [-v|--verbose] [--version] [-y|--yes]\n"
 
 xx(lvconvert,
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
-   "\t[--type SegmentType]\n"
+   "[-m|--mirrors <Mirrors> [--mirrorlog {disk|core|mirrored}|--corelog]]\n"
+   "\t[--type <SegmentType>]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[--replace PhysicalVolume]\n"
-   "\t[-R|--regionsize MirrorLogRegionSize]\n"
-   "\t[--alloc AllocationPolicy]\n"
+   "\t[-R|--regionsize <MirrorLogRegionSize>]\n"
+   "\t[--alloc <AllocationPolicy>]\n"
    "\t[-b|--background]\n"
    "\t[-f|--force]\n"
-   "\t[-i|--interval seconds]\n"
-   "\t[--stripes Stripes [-I|--stripesize StripeSize]]\n"
+   "\t[-i|--interval <Seconds>]\n"
+   "\t[--stripes <Stripes> [-I|--stripesize <StripeSize>]]\n"
    COMMON_OPTS
    "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
-   "[--splitmirrors Images --trackchanges]\n"
+   "[--splitmirrors <Images> --trackchanges]\n"
    "\t[--splitmirrors Images --name SplitLogicalVolumeName]\n"
    COMMON_OPTS
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
@@ -246,7 +246,7 @@ xx(lvconvert,
 
    "lvconvert "
    "[--type snapshot|-s|--snapshot]\n"
-   "\t[-c|--chunksize]\n"
+   "\t[-c|--chunksize <ChunkSize>]\n"
    "\t[-Z|--zero {y|n}]\n"
    COMMON_OPTS
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
@@ -254,20 +254,20 @@ xx(lvconvert,
    "lvconvert "
    "--merge\n"
    "\t[-b|--background]\n"
-   "\t[-i|--interval seconds]\n"
+   "\t[-i|--interval <Seconds>]\n"
    COMMON_OPTS
    "\tLogicalVolume[Path]\n\n"
 
    "lvconvert "
    "[--type thin[-pool]|-T|--thin]\n"
    "\t[--thinpool ThinPoolLogicalVolume[Path]]\n"
-   "\t[--chunksize size]\n"
+   "\t[--chunksize <ChunkSize>]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--poolmetadataspare {y|n}]\n"
-   "\t[{--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
-   "\t --poolmetadatasize size}]\n"
-   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
-   "\t[--stripes Stripes [-I|--stripesize StripeSize]]]\n"
+   "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
+   "\t --poolmetadatasize <MetadataSize>]\n"
+   "\t[-r|--readahead <ReadAheadSectors>|auto|none]\n"
+   "\t[--stripes <Stripes> [-I|--stripesize <StripeSize>]]]\n"
    "\t[--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
    COMMON_OPTS
@@ -276,13 +276,13 @@ xx(lvconvert,
    "lvconvert "
    "[--type cache[-pool]|-H|--cache]\n"
    "\t[--cachepool CacheDataLogicalVolume[Path]]\n"
-   "\t[--cachemode CacheMode]\n"
-   "\t[--cachepolicy policy]\n"
-   "\t[--cachesettings key=value]\n"
-   "\t[--chunksize size]\n"
+   "\t[--cachemode <CacheMode>]\n"
+   "\t[--cachepolicy <CachePolicy>]\n"
+   "\t[--cachesettings <Key>=<Value>]\n"
+   "\t[--chunksize <ChunkSize>]\n"
+   "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
+   "\t --poolmetadatasize <MetadataSize>]\n"
    "\t[--poolmetadataspare {y|n}]]\n"
-   "\t[{--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
-   "\t --poolmetadatasize size}]\n"
    COMMON_OPTS
    "\t[Cache|CacheDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 


