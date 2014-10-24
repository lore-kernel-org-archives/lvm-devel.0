From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:30 +0000 (UTC)
Subject: master - cleanup: commands.h update descriptions
Message-ID: <20141024144030.872B060CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6456bd6390f6d99dd975f671c5730b0438c4c89
Commit:        c6456bd6390f6d99dd975f671c5730b0438c4c89
Parent:        df933c2ac92203c7352be2e7062ca8c01777cb51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 22:43:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: commands.h update descriptions

---
 tools/commands.h |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 524297d..eb0d248 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -121,7 +121,7 @@ xx(lvchange,
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
-   "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
+   "\t[-M|--persistent y|n] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[-P|--partial]\n"
    "\t[-p|--permission r|rw]\n"
@@ -221,25 +221,25 @@ xx(lvconvert,
    "\t[--chunksize size]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--poolmetadataspare {y|n}]\n"
-   "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
-   "\t [--poolmetadatasize size]\n"
-   "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
-   "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
+   "\t[{--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
+   "\t --poolmetadatasize size}]\n"
+   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t[--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
    COMMON_OPTS
-   "\t[ExternalOrigin|ThinDataPool]LogicalVolume[Path]\n\n"
+   "\t[ExternalOrigin|ThinDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n"
 
    "lvconvert "
-   "[--type cache[-pool]|--cache]\n"
+   "[--type cache[-pool]|-H|--cache]\n"
    "\t[--cachepool CacheDataLogicalVolume[Path]]\n"
    "\t[--cachemode CacheMode]\n"
    "\t[--chunksize size]\n"
    "\t[--poolmetadataspare {y|n}]]\n"
-   "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
-   "\t [--poolmetadatasize size]\n"
+   "\t[{--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
+   "\t --poolmetadatasize size}]\n"
    COMMON_OPTS
-   "\t[Cache|CacheDataPool]LogicalVolume[Path]\n\n",
+   "\t[Cache|CacheDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
    alloc_ARG, background_ARG, cache_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
    corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
@@ -273,9 +273,10 @@ xx(lvcreate,
    "\t[-K|--ignoreactivationskip]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
+   "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync]\n"
+   "\t  [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -283,7 +284,7 @@ xx(lvcreate,
    "\t[--poolmetadataspare {y|n}]]\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
    "\t[--[raid]maxrecoveryrate Rate]\n"
-   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t[-r|--readahead {ReadAheadSectors|auto|none}]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-T|--thin\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
@@ -319,7 +320,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
-   "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
+   "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
@@ -848,7 +849,7 @@ xx(pvscan,
    PERMITTED_READ_ONLY,
    "pvscan\n"
    "\t[-b|--background]\n"
-   "\t[--cache [-a|--activate ay] [ DevicePath | --major major --minor minor]...]\n"
+   "\t[--cache [-a|--activate ay] [ DevicePath | -j|--major major --minor minor]...]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t{-e|--exported | -n|--novolumegroup}\n"


