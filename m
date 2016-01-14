From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:14 +0000 (UTC)
Subject: master - lvresize: check for poolmetadatasize arg earlier
Message-ID: <20160114103514.6A40160D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43897239b3cdd9ed9c1c7b795e171d9565d13116
Commit:        43897239b3cdd9ed9c1c7b795e171d9565d13116
Parent:        526297296fb05bd8aea58f8b3d08a14045bf74e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 16 11:23:45 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:04 2016 +0100

lvresize: check for poolmetadatasize arg earlier

Since we check for poolmetadatasize, we need to detect it before
actual test.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |   19 ++++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 885226a..018b955 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Eval poolmetadatasize arg earlier in lvresize.
   Fix vgcfgrestore to respect allocatable attribute of PVs.
   Add report/mark_hidden_devices to lvm.conf.
   Use brackets consistently in report fields to mark hidden devices.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index da97205..93ad068 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -46,6 +46,16 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * then metadata will be extended there.
 		 */
 		lp->sizeargs = arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG);
+
+		if (arg_count(cmd, poolmetadatasize_ARG)) {
+			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
+			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
+			if (lp->poolmetadatasign == SIGN_MINUS) {
+				log_error("Can't reduce pool metadata size.");
+				return 0;
+			}
+		}
+
 		if ((lp->sizeargs == 0) && (argc >= 2)) {
 			lp->extents = 100;
 			lp->percent = PERCENT_PVS;
@@ -71,15 +81,6 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
 			lp->percent = PERCENT_NONE;
 		}
-
-		if (arg_count(cmd, poolmetadatasize_ARG)) {
-			lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
-			lp->poolmetadatasign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
-			if (lp->poolmetadatasign == SIGN_MINUS) {
-				log_error("Can't reduce pool metadata size.");
-				return 0;
-			}
-		}
 	}
 
 	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {


