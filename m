From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jan 2014 09:59:30 +0000 (UTC)
Subject: master - thin: cleanup _thin_pool_add_message
Message-ID: <20140108095930.63744602AE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de3abfa6222c7c35f8262032112fea3b6098fd58
Commit:        de3abfa6222c7c35f8262032112fea3b6098fd58
Parent:        0a13815e68c3d85b140f8c6d4d91592ae2f8b992
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 8 10:56:05 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 8 10:56:05 2014 +0100

thin: cleanup _thin_pool_add_message

Make this code a bit more readable for Coverity as otherwise
it marks the "type" variable in the "_thin_pool_add_message" fn
as undefined for certain path (...which is normally unreachable anyway,
but let's clean this up).
---
 lib/thin/thin.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index df6482e..ff263d9 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -62,16 +62,10 @@ static int _thin_pool_add_message(struct lv_segment *seg,
 					     lv_name);
 		/* FIXME: switch to _SNAP later, if the created LV has an origin */
 		type = DM_THIN_MESSAGE_CREATE_THIN;
-	}
-
-	if (!dm_config_get_uint32(sn, "delete", &delete_id)) {
-		if (!lv)
-			return SEG_LOG_ERROR("Unknown message in");
-	} else {
-		if (lv)
-			return SEG_LOG_ERROR("Unsupported message format in");
+	} else if (dm_config_get_uint32(sn, "delete", &delete_id))
 		type = DM_THIN_MESSAGE_DELETE;
-	}
+	else
+		return SEG_LOG_ERROR("Unknown message in");
 
 	if (!attach_pool_message(seg, type, lv, delete_id, 1))
 		return_0;


