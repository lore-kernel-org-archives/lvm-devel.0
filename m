From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:36:12 +0000 (UTC)
Subject: master - cache: enable setting cachepolicy in lvconvert
Message-ID: <20150821133612.F29A960DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45f3e8bbef54b5541714010eb96da767e7856f62
Commit:        45f3e8bbef54b5541714010eb96da767e7856f62
Parent:        1fae121b222927584a7a88cd3f4f1ba2aadb4931
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 21 13:00:13 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:35:45 2015 +0200

cache: enable setting cachepolicy in lvconvert

---
 tools/commands.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 0ab578d..4505d18 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -275,6 +275,8 @@ xx(lvconvert,
    "[--type cache[-pool]|-H|--cache]\n"
    "\t[--cachepool CacheDataLogicalVolume[Path]]\n"
    "\t[--cachemode CacheMode]\n"
+   "\t[--cachepolicy policy]\n"
+   "\t[--cachesettings key=value]\n"
    "\t[--chunksize size]\n"
    "\t[--poolmetadataspare {y|n}]]\n"
    "\t[{--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
@@ -282,7 +284,8 @@ xx(lvconvert,
    COMMON_OPTS
    "\t[Cache|CacheDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
-   alloc_ARG, background_ARG, cache_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
+   alloc_ARG, background_ARG, cache_ARG, cachemode_ARG,
+   cachepool_ARG, cachepolicy_ARG, cachesettings_ARG, chunksize_ARG,
    corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
    mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
@@ -301,6 +304,8 @@ xx(lvcreate,
    "\t[--alloc AllocationPolicy]\n"
    "\t[-H|--cache\n"
    "\t  [--cachemode {writeback|writethrough}]\n"
+   "\t  [--cachepolicy policy]\n"
+   "\t  [--cachesettings key=value]\n"
    "\t[--cachepool CachePoolLogicalVolume{Name|Path}]\n"
    "\t[-c|--chunksize ChunkSize]\n"
    "\t[-C|--contiguous {y|n}]\n"


