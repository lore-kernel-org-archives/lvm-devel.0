From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Jul 2015 16:41:24 +0000 (UTC)
Subject: master - lockd: fix error message after a failing to get lock
Message-ID: <20150714164124.1C6B760EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=681f779a3cb711c32663e594242a3b28a64e9f27
Commit:        681f779a3cb711c32663e594242a3b28a64e9f27
Parent:        ac3143c0936d00a0a1f4a865192040d3791afd66
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 14 11:36:04 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 14 11:36:04 2015 -0500

lockd: fix error message after a failing to get lock

There are two different failure conditions detected in
access_vg_lock_type() that should have different error
messages.  This adds another failure flag so the two
cases can be distinguished to avoid printing a misleading
error message.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    8 +++++---
 tools/toollib.c                  |   14 +++++++++++---
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 03f959d..80e3ca3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -181,6 +181,7 @@
 #define FAILED_RECOVERY		0x00000200U
 #define FAILED_SYSTEMID		0x00000400U
 #define FAILED_LOCK_TYPE	0x00000800U
+#define FAILED_LOCK_MODE	0x00001000U
 #define SUCCESS			0x00000000U
 
 #define VGMETADATACOPIES_ALL UINT32_MAX
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c4974de..3ebcc2d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4747,7 +4747,7 @@ static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg
 }
 
 static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg,
-				uint32_t lockd_state)
+				uint32_t lockd_state, uint32_t *failure)
 {
 	if (!is_real_vg(vg->name))
 		return 1;
@@ -4791,6 +4791,7 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 				  vg->name, vg->lock_type);
 		}
 
+		*failure |= FAILED_LOCK_TYPE;
 		return 0;
 	}
 
@@ -4804,6 +4805,7 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 	if (lockd_state & LDST_FAIL) {
 		if (lockd_state & LDST_EX) {
 			log_error("Cannot access VG %s due to failed lock.", vg->name);
+			*failure |= FAILED_LOCK_MODE;
 			return 0;
 		} else {
 			log_warn("Reading VG %s without a lock.", vg->name);
@@ -4904,8 +4906,8 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
 		return 0;
 	}
 
-	if (!_access_vg_lock_type(cmd, vg, lockd_state)) {
-		*failure |= FAILED_LOCK_TYPE;
+	if (!_access_vg_lock_type(cmd, vg, lockd_state, failure)) {
+		/* Either FAILED_LOCK_TYPE or FAILED_LOCK_MODE were set. */
 		return 0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index b0b2b01..76fc63d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -221,14 +221,22 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	/*
 	 * Accessing a lockd VG when lvmlockd is not used is similar
 	 * to accessing a foreign VG.
+	 * This is also the point where a command fails if it failed
+	 * to acquire the necessary lock from lvmlockd.
+	 * The two cases are distinguished by FAILED_LOCK_TYPE (the
+	 * VG lock_type requires lvmlockd), and FAILED_LOCK_MODE (the
+	 * command failed to acquire the necessary lock.)
 	 */
-	if (read_error & FAILED_LOCK_TYPE) {
+	if (read_error & (FAILED_LOCK_TYPE | FAILED_LOCK_MODE)) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Cannot access VG %s with lock_type %s that requires lvmlockd.",
-				  vg->name, vg->lock_type);
+			if (read_error & FAILED_LOCK_TYPE)
+				log_error("Cannot access VG %s with lock type %s that requires lvmlockd.",
+					  vg->name, vg->lock_type);
+			/* For FAILED_LOCK_MODE, the error is printed in vg_read. */
 			return 1;
 		} else {
 			read_error &= ~FAILED_LOCK_TYPE; /* Check for other errors */
+			read_error &= ~FAILED_LOCK_MODE;
 			log_verbose("Skipping volume group %s", vg_name);
 			*skip = 1;
 		}


