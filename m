From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:53:52 +0000 (UTC)
Subject: master - cleanup: shuffle check of threshold
Message-ID: <20160120125352.968B960D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b9ae55a8d691eb15d34dce74f00230bd2423c5b
Commit:        4b9ae55a8d691eb15d34dce74f00230bd2423c5b
Parent:        c99ca6f430eb3650115882b5b6a8f9dde6212b12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 15 14:39:58 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: shuffle check of threshold

Check first threshold and then policy_amount.
---
 lib/metadata/lv_manip.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e0312e3..1975c83 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4445,15 +4445,18 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		}
 	}
 
-	if (!policy_amount && policy_threshold < 100) {
+	if (policy_threshold >= 100) {
+		lp->extents = lp->poolmetadatasize = 0;
+		lp->sizeargs = 0;
+		return 1; /* nothing to do */
+	}
+
+	if (!policy_amount) {
 		log_error("Can't extend %s with %s autoextend percent set to 0%%.",
 			  display_lvname(lv),  first_seg(lv)->segtype->name);
 		return 0;
 	}
 
-	if (policy_threshold >= 100)
-		return 1; /* nothing to do */
-
 	if (!lv_is_active_locally(lv)) {
 		log_error("Can't read state of locally inactive LV %s.",
 			  display_lvname(lv));


