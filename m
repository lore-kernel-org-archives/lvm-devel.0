From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 May 2014 15:11:45 +0000 (UTC)
Subject: master - activate: cleanup lv_check_not_in_use
Message-ID: <20140527151145.782FB60E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae43d1afa205c53e0068cb23b386594e16bbb6a2
Commit:        ae43d1afa205c53e0068cb23b386594e16bbb6a2
Parent:        1569e7a4985776783fa0175ddfa6dd333a68b981
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 27 17:07:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 27 17:08:49 2014 +0200

activate: cleanup lv_check_not_in_use

Reindent lv_check_not_in_use to simplify internal loop code.
Also return always '0/1'  (drop -1) - since we only
check for failure (0) - and we don't really know
why  lv_info() has failed.
---
 lib/activate/activate.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6a9dd0a..7ad3654 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -719,21 +719,20 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
-	while (open_count_check_retries--) {
-		if (info->open_count > 0) {
-			if (open_count_check_retries) {
-				usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
-				log_debug_activation("Retrying open_count check for %s/%s.",
-						     lv->vg->name, lv->name);
-				if (!lv_info(cmd, lv, 0, info, 1, 0))
-					return -1;
-				continue;
-			}
+	while (info->open_count > 0 && open_count_check_retries--) {
+		if (!open_count_check_retries) {
 			log_error("Logical volume %s/%s in use.",
 				  lv->vg->name, lv->name);
 			return 0;
-		} else
+		}
+
+		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY * 4);
+		log_debug_activation("Retrying open_count check for %s/%s.",
+				     lv->vg->name, lv->name);
+		if (!lv_info(cmd, lv, 0, info, 1, 0)) {
+			stack; /* device dissappeared? */
 			break;
+		}
 	}
 
 	return 1;


