From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:51 +0000 (UTC)
Subject: master - lvcreate: support --cache and --cachepool
Message-ID: <20141006133251.64242609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68bf974769ff2491f90620d15fd76c42244190a1
Commit:        68bf974769ff2491f90620d15fd76c42244190a1
Parent:        fc77e4291bdae39e1ea9dfdf0c8ef9af493df9cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 30 21:46:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

lvcreate: support --cache and --cachepool

Enable in cmdline options for cache and cachepool.
---
 tools/commands.h |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 1e3677e..ed911fa 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -241,7 +241,10 @@ xx(lvcreate,
    "\t[-a|--activate [a|e|l]{y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
-   "\t[--cachemode CacheMode]\n"
+   "\t[-H|--cache\n"
+   "\t  [-c|--chunksize ChunkSize]\n"
+   "\t  [--cachemode {writeback|writethrough}]\n"
+   "\t[--cachepool CachePoolLogicalVolume{Name|Path}]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -263,10 +266,11 @@ xx(lvcreate,
    "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
-   "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
+   "\t[-T|--thin\n"
+   "\t  [-c|--chunksize ChunkSize]\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
-   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
-   "\t  [--poolmetadataspare {y|n}]\n"
+   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
+   "\t  [--poolmetadataspare {y|n}]]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -312,7 +316,8 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   cachemode_ARG, chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
+   cache_ARG, cachemode_ARG, cachepool_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
    minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,


