From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:29 +0000 (UTC)
Subject: master - thin: enhance logging
Message-ID: <20151013140329.511BC60E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86b04ebd193c9db09ee5f03a2de4997aa2ab52c3
Commit:        86b04ebd193c9db09ee5f03a2de4997aa2ab52c3
Parent:        7e1c08bb6a90acdbf56e362ee017bd48de13a535
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:35:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:38:52 2015 +0200

thin: enhance logging

Add debug message with more details about threshold overflow.
---
 lib/metadata/thin_manip.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 24c68a8..37bf4cb 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -224,15 +224,27 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
 		return_0;
 
-	if (percent >= threshold)
+	if (percent >= threshold) {
+		log_debug("Threshold configured for free data space in "
+			  "thin pool %s has been reached (%.2f%% >= %.2f%%).",
+			  display_lvname(pool_seg->lv),
+			  dm_percent_to_float(percent),
+			  dm_percent_to_float(threshold));
 		return 0;
+	}
 
 	/* Metadata */
 	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
 		return_0;
 
-	if (percent >= threshold)
+	if (percent >= threshold) {
+		log_debug("Threshold configured for free metadata space in "
+			  "thin pool %s has been reached (%.2f%% > %.2f%%).",
+			  display_lvname(pool_seg->lv),
+			  dm_percent_to_float(percent),
+			  dm_percent_to_float(threshold));
 		return 0;
+	}
 
 	return 1;
 }


