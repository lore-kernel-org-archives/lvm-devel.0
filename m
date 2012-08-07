From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:40 +0000 (UTC)
Subject: master - thin: tidy commands.h arg lists
Message-ID: <20120807203040.4575B3454@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ca813083f34082dd32ceab6e125ef379769e21e
Commit:        1ca813083f34082dd32ceab6e125ef379769e21e
Parent:        b51241a346be6f31a525c1d547bed12ba2df34a3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 20:10:06 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 20:10:06 2012 +0100

thin: tidy commands.h arg lists

args are listed alphabetically.
lvconvert -T is covered in the second section not the first.
It could be tidied further or split out.
---
 tools/commands.h |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 88c170a..47b540e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -90,11 +90,11 @@ xx(lvchange,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
-   force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG,
-   minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
-   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG,
-   addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG,
-   discard_ARG, zero_ARG)
+   discard_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
+   major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
+   permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
+   refresh_ARG, addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG,
+   zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -180,10 +180,6 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
-   "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
-   "\t  [--discard {ignore|nopassdown|passdown}]\n"
-   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
-   "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -202,6 +198,7 @@ xx(lvcreate,
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
+   "\t[--discard {ignore|nopassdown|passdown}]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
@@ -215,14 +212,14 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
-   "\t[--thinpool] PoolLogicalVolume\n"
+   "\t[--thinpool ThinPoolLogicalVolume[Path]]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
 
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, extents_ARG, discard_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, discard_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
    persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,


