From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:17 +0000 (UTC)
Subject: master - lvchange: just skip on cache pool
Message-ID: <20140711113417.D70C661381@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba048612a3dcb9ca35c54f05a006ec458da4164f
Commit:        ba048612a3dcb9ca35c54f05a006ec458da4164f
Parent:        8932d4a6257cfb842adb43c71d650515ef041ba6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 9 17:55:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:50:06 2014 +0200

lvchange: just skip on cache pool

---
 tools/lvchange.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9bd6a88..992efde 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -215,6 +215,9 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 
 	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
+	if (lv_is_cache_pool(lv))
+		return 1;
+
 	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 		return 1;
 
@@ -951,11 +954,6 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return EINVALID_CMD_LINE;
 	}
 
-	if (lv_is_cache_pool(lv)) {
-		log_error("Can't change cache pool logical volume.");
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||


