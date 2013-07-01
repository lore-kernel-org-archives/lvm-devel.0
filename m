From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:27 +0000 (UTC)
Subject: master - archiver: do not archive vg more then once
Message-ID: <20130701211327.BF63E610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e30028004b45a962c525685824e25dad80b7fbcf
Commit:        e30028004b45a962c525685824e25dad80b7fbcf
Parent:        afea2bf5982f9a060766c1b67cbbc97ea4ecba2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 18:01:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:09:26 2013 +0200

archiver: do not archive vg more then once

Do not keep multiple archives for the executed command.
Reuse the ALLOCATABLE_PV from pv status for
ARCHIVED_VG vg status. Mark VG with the bit with the
first archivation.
---
 WHATS_NEW                        |    1 +
 lib/format_text/archiver.c       |    5 +++++
 lib/format_text/flags.c          |    1 +
 lib/metadata/metadata-exported.h |    3 +++
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c24f576..b501121 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid creation of multiple archives for one command.
   Use mirror_segtype_default if type not specified for linear->mirror upconvert.
   Fix use of too big chunks of memory when communication with lvmetad.
   Fix vgcfgrestore crash when specified incorrect vg name.
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 8599e3b..c012c8f 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -110,6 +110,9 @@ static int __archive(struct volume_group *vg)
 
 int archive(struct volume_group *vg)
 {
+	if (vg_is_archived(vg))
+		return 1; /* VG has been already archived */
+
 	if (!vg->cmd->archive_params->enabled || !vg->cmd->archive_params->dir)
 		return 1;
 
@@ -134,6 +137,8 @@ int archive(struct volume_group *vg)
 		return 0;
 	}
 
+	vg->status |= ARCHIVED_VG;
+
 	return 1;
 }
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 28a7dc4..cbccdfd 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -38,6 +38,7 @@ static const struct flag _vg_flags[] = {
 	{SHARED, "SHARED", STATUS_FLAG},
 	{PARTIAL_VG, NULL, 0},
 	{PRECOMMITTED, NULL, 0},
+	{ARCHIVED_VG, NULL, 0},
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6fa0c5b..98216d4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -48,6 +48,7 @@
 
 /* May any free extents on this PV be used or must they be left free? */
 #define ALLOCATABLE_PV		UINT64_C(0x00000008)	/* PV */
+#define ARCHIVED_VG		ALLOCATABLE_PV		/* VG, reuse same bit */
 
 //#define SPINDOWN_LV		UINT64_C(0x00000010)	/* LV */
 //#define BADBLOCK_ON		UINT64_C(0x00000020)	/* LV */
@@ -140,6 +141,8 @@
 #define VGMETADATACOPIES_ALL UINT32_MAX
 #define VGMETADATACOPIES_UNMANAGED 0
 
+#define vg_is_archived(vg)	(((vg)->status & ARCHIVED_VG) ? 1 : 0)
+
 #define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)
 #define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
 #define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)


