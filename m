From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:25 +0200
Subject: [PATCH 07/11] Remove ACTIVATE_EXCL appearance from the code
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <a931c24e19dfa355bb4afcb879a1243b2a808899.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c          |    8 --------
 lib/format_text/flags.c          |    1 -
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.h          |    1 -
 4 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 58f623e..327cfa3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1222,14 +1222,6 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	/*
-	 * When targets are activated exclusively in a cluster, the
-	 * non-clustered target should be used.  This only happens
-	 * if ACTIVATE_EXCL is set in lv->status.
-	 */
-	if (laopts->exclusive)
-		lv->status |= ACTIVATE_EXCL;
-
 	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 0af4c89..7846ada 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -62,7 +62,6 @@ static const struct flag _lv_flags[] = {
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
 	{MERGING, NULL, 0},
-	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
 	{POSTORDER_FLAG, NULL, 0},
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 950a81d..cad1719 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -62,7 +62,6 @@
 #define MIRROR_LOG		0x00020000U	/* LV */
 #define MIRROR_IMAGE		0x00040000U	/* LV */
 #define LV_NOTSYNCED		0x00080000U	/* LV */
-//#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c348979..8a3ff1a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -71,7 +71,6 @@
 //#define MIRROR_LOG		0x00020000U	/* LV */
 //#define MIRROR_IMAGE		0x00040000U	/* LV */
 //#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
-#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 #define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 //#define CONVERTING		0x00400000U	/* LV */
 
-- 
1.7.5.2


