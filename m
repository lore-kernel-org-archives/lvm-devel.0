From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:51 +0000 (UTC)
Subject: master - options: introduce pooldatasize option
Message-ID: <20141024144051.6C12F60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a330640063fed88616379e3c2e4e85b8e2e355b0
Commit:        a330640063fed88616379e3c2e4e85b8e2e355b0
Parent:        9a6758e953a83aeb1d384df97c6f18b542c569a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 18 10:58:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

options: introduce pooldatasize option

Introduce new option to specify pool data size.
This will be user to create i.e.  cache & cachepool at once.
And possible for thin external origin snapshot.

This is only very basic patch to enable options, the
real working code will come later.
---
 lib/metadata/metadata-exported.h |    2 ++
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 +++++--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cfc0ce2..3d656b7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -854,6 +854,8 @@ struct lvcreate_params {
 	uint64_t voriginsize; /* snapshot */
 	uint32_t pool_metadata_extents; /* pools */
 	uint64_t pool_metadata_size; /* pools */
+	uint32_t pool_data_extents; /* pools */
+	uint64_t pool_data_size; /* pools */
 	struct dm_list *pvh; /* all */
 
 	uint64_t permission; /* all */
diff --git a/tools/args.h b/tools/args.h
index 492eb28..4a4845f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -69,6 +69,7 @@ arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(originname_ARG, '\0', "originname", string_arg, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(pooldatasize_ARG, '\0', "pooldatasize", size_mb_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
 arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index eb0d248..d4473a4 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -280,6 +280,7 @@ xx(lvcreate,
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
+   "\t[--pooldatasize DataSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
    "\t[--poolmetadataspare {y|n}]]\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
@@ -319,6 +320,7 @@ xx(lvcreate,
    "\t[-K|--ignoreactivationskip]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
+   "\t[--pooldatasize DataVolumeSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
    "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
@@ -339,8 +341,9 @@ xx(lvcreate,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
    minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG, persistent_ARG, poolmetadatasize_ARG,
-   poolmetadataspare_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
+   noudevsync_ARG, permission_ARG, persistent_ARG,
+   pooldatasize_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
+   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
    readahead_ARG, regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG,
    stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
    virtualoriginsize_ARG, virtualsize_ARG, wipesignatures_ARG, zero_ARG)


