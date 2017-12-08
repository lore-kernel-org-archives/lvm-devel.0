From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Dec 2017 07:22:17 -0500
Subject: master - cleanup: debug message
Message-ID: <201712081222.vB8CMHfK007705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a64c73a979062c097395735372bbb33456d445f2
Commit:        a64c73a979062c097395735372bbb33456d445f2
Parent:        700e2a2d251cf8dcaf56035e0bd83ce8f808b5c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 8 13:17:15 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 8 13:21:15 2017 +0100

cleanup: debug message

---
 tools/vgchange.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index ea737ba..616a9d3 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -124,8 +124,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				 * If the LV is active exclusive remotely,
 				 * then ignore it here
 				 */
-				log_verbose("%s/%s is exclusively active on"
-					    " a remote node", vg->name, lv->name);
+				log_verbose("%s is exclusively active on a remote node.",
+					    display_lvname(lv));
 				expected_count--; /* not accounted */
 			}
 			continue;
@@ -783,7 +783,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (!arg_is_set(cmd, refresh_ARG) &&
 	    !vgchange_background_polling(cmd, vg))
-			return_ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	return ret;
 }


