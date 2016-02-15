From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:12 +0000 (UTC)
Subject: master - format: add FMT_PV_FLAGS to indicate format supports PV flags
Message-ID: <20160215120812.D590760C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a522af93b7365d183fd7f82ac65cc7f3bed2423a
Commit:        a522af93b7365d183fd7f82ac65cc7f3bed2423a
Parent:        4361543f3eb037237438c32f1c8a558f4d695e93
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 12:58:59 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

format: add FMT_PV_FLAGS to indicate format supports PV flags

---
 lib/format_text/format-text.c    |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b1e2ebf..f290619 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2466,7 +2466,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
 			FMT_UNLIMITED_STRIPESIZE | FMT_BAS | FMT_CONFIG_PROFILE |
-			FMT_NON_POWER2_EXTENTS;
+			FMT_NON_POWER2_EXTENTS | FMT_PV_FLAGS;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b9363f1..5cf7c88 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -150,6 +150,7 @@
 #define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
 #define FMT_NON_POWER2_EXTENTS	0x000002000U	/* Non-power-of-2 extent sizes? */
 #define FMT_SYSTEMID_ON_PVS	0x000004000U	/* System ID is stored on PVs not VG */
+#define FMT_PV_FLAGS		0x000008000U	/* Supports PV flags */
 
 #define systemid_on_pvs(vg)	((vg)->fid->fmt->features & FMT_SYSTEMID_ON_PVS)
 


