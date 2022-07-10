From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:24 +0000 (GMT)
Subject: main - vdo: suffle code for better error path handling
Message-ID: <20220710232224.11700385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=493acb9195cef185b38ae4e4ffb84b984e5cc08c
Commit:        493acb9195cef185b38ae4e4ffb84b984e5cc08c
Parent:        e2e31d9acf1b96ab741c22dc0a2fefd672996d3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 9 21:33:57 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: suffle code for better error path handling

For failing dm_ no need to report 2nd. error,
but we missed to report error with 'updated==NULL'.
---
 tools/toollib.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 544791808..c29ba2ab4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1347,23 +1347,23 @@ int get_vdo_settings(struct cmd_context *cmd,
 			u |= VDO_CHANGE_ONLINE;
 	}
 
-	if (updated) {
-		// validation of updated VDO option
-		if (!dm_vdo_validate_target_params(vtp, 0 /* vdo_size */)) {
-err:
-			if (is_lvchange)
-				log_error("Cannot change VDO setting \"vdo_%s\" in existing VDO pool.",
-					  option);
-			else
-				log_error("Invalid argument for VDO setting \"vdo_%s\".",
-					  option);
-			goto out;
-		}
+	// validation of updated VDO option
+	if (!dm_vdo_validate_target_params(vtp, 0 /* vdo_size */))
+		goto_out;
 
+	if (updated)
 		*updated = u;
-	}
 
-	r = 1;
+	r = 1; // success
+	goto out;
+err:
+	if (is_lvchange)
+		log_error("Cannot change VDO setting \"vdo_%s\" in existing VDO pool.",
+			  option);
+	else
+		log_error("Invalid argument for VDO setting \"vdo_%s\".",
+			  option);
+
 out:
 	if (result)
 		dm_config_destroy(result);

