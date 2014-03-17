From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:18 +0000 (UTC)
Subject: master - cleanup: relocate check for mirror
Message-ID: <20140317133318.3D1FE60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d686f3856a51490194140c694fa4364a54244630
Commit:        d686f3856a51490194140c694fa4364a54244630
Parent:        b738260c7cdbc6094feda9f9e2426d50bd413263
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 14:05:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:43 2014 +0100

cleanup: relocate check for mirror

Move testing code into _lvconvert_snapshot function.
---
 tools/lvconvert.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4a26614..1331620 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2038,6 +2038,11 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
+	if (lv->status & MIRRORED) {
+		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
+		return 0;
+	}
+
 	if (lv_is_origin(lv)) {
 		/* Unsupported stack */
 		log_error("Unable to convert origin \"%s\" into a snapshot.", lv->name);
@@ -3039,10 +3044,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {
-		if (lv->status & MIRRORED) {
-			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
-			return ECMD_FAILED;
-		}
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 


