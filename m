From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:35 +0000 (UTC)
Subject: master - debug: add debug message
Message-ID: <20140924085735.EE3BD60B46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc5031c28383d492aa0c349fe2e058c2c26b2934
Commit:        bc5031c28383d492aa0c349fe2e058c2c26b2934
Parent:        edb3902c25801117557852f4a37802144da63841
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 24 10:03:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

debug: add debug message

Since we leave error printing on the called of deactivation,
at least put in debug log for this case.
---
 lib/activate/activate.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3e4b04b..58e847e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2160,8 +2160,12 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 	r = _lv_deactivate(lv);
 	critical_section_dec(cmd, "deactivated");
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists) {
+		/* Turn into log_error, but we do not log error */
+		log_debug_activation("Deactivated volume is still %s present.",
+				     display_lvname(lv));
 		r = 0;
+	}
 out:
 	if (lv_to_free) {
 		lv_release_replicator_vgs(lv_to_free);


