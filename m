From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:52 +0200
Subject: [PATCH 1/7] Remove INCONSISTENG_VG flag
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <89143c73c9d1a1740e7974e2f0f69171a6d80ad1.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As this flag could not have been set - remove it from the code.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
NOTE: because of wrong code logic the call:

lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
			   (inconsistent ? INCONSISTENT_VG : 0));

used to always pass '0' - now with remove flag it's passing
PRECOMMITTED flag in - tests on my machine are passing  - but this
present functinal change in this patch.

To match original functionality - 0 had to be always passed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   11 +++--------
 lib/metadata/metadata.h |    1 -
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 842885f..d0255da 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2862,12 +2862,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * the missing PV logic below.
 	 */
 	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
-	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
-		if (!(correct_vg->status & INCONSISTENT_VG))
-			*consistent = 1;
-		else	/* Inconsistent but we can't repair it */
-			correct_vg->status &= ~INCONSISTENT_VG;
-
+	    (use_precommitted || !*consistent)) {
+		*consistent = 1;
 		return correct_vg;
 	} else {
 		free_vg(correct_vg);
@@ -3134,8 +3130,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * If there is no precommitted metadata, committed metadata
 	 * is read and stored in the cache even if use_precommitted is set
 	 */
-	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
-			   (inconsistent ? INCONSISTENT_VG : 0));
+	lvmcache_update_vg(correct_vg, (correct_vg->status & PRECOMMITTED));
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 56a224c..1ace8c1 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -75,7 +75,6 @@
 //#define CONVERTING		0x00400000U	/* LV */
 
 //#define MISSING_PV		0x00800000U	/* PV */
-#define INCONSISTENT_VG		0x00800000U	/* VG - internal use only */
 //#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
 //						   written out in metadata*/
 
-- 
1.7.6


