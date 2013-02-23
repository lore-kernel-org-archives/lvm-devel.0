From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:42:07 +0000 (UTC)
Subject: master - thin: removal of external_origin
Message-ID: <20130223094207.7AA8841D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cba0ea9f96ed658d11df4428ec20502da1867c0
Commit:        2cba0ea9f96ed658d11df4428ec20502da1867c0
Parent:        30c13eff3766eb49f925acabf836470b63d05903
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 20 16:14:24 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:37:01 2013 +0100

thin: removal of external_origin

---
 lib/metadata/lv_manip.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 72516ea..ef9f643 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3352,6 +3352,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_external_origin(lv)) {
+		log_error("Can't remove external origin logical volume \"%s\".",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & MIRROR_IMAGE) {
 		log_error("Can't remove logical volume %s used by a mirror",
 			  lv->name);
@@ -3578,6 +3584,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 				return_0;
 	}
 
+	if (lv_is_external_origin(lv) &&
+	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "external origin"))
+		return_0;
+
 	if (lv_is_used_thin_pool(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;


