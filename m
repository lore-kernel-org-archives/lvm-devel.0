From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:31 +0000 (UTC)
Subject: master - thin: lvchange may change discards freely
Message-ID: <20121202170231.7C718A0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dde5a6c52b315d7b8e2dd6b91e17eb3955534682
Commit:        dde5a6c52b315d7b8e2dd6b91e17eb3955534682
Parent:        f0da2842cfec05753154e5516f01e0dfd7331640
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 2 16:30:45 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:56:44 2012 +0100

thin: lvchange may change discards freely

---
 tools/lvchange.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8eabbbb..c3c993a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -111,13 +111,7 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	if (arg_count(cmd, discards_ARG)) {
 		discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_IGNORE);
 		if (discards != first_seg(lv)->discards) {
-			if ((discards != THIN_DISCARDS_IGNORE) &&
-				 (first_seg(lv)->chunk_size &
-				  (first_seg(lv)->chunk_size - 1)))
-				log_error("Cannot change discards state for "
-					  "logical volume \"%s\" "
-					  "with non power of 2 chunk size.", lv->name);
-			else if (((discards == THIN_DISCARDS_IGNORE) ||
+			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
 			    lv_is_active(lv))
 				log_error("Cannot change discards state for active "


