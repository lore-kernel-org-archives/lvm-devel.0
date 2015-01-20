From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:03:08 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20150120140308.2EFFD617B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b78d5237ddc7dc8d328bd1b16628c5a61454826
Commit:        3b78d5237ddc7dc8d328bd1b16628c5a61454826
Parent:        3cef00c4ca25237ed045ae5def506128f8678e21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 12:43:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 15:02:19 2015 +0100

cleanup: indent

---
 lib/activate/activate.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 20c7c98..424786c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -749,8 +749,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	 * we need to acquire info and status separately!
 	 */
 	return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
-	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg,
-			&status->seg_status, 0, 0);
+	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, &status->seg_status, 0, 0);
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25


