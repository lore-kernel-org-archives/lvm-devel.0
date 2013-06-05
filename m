From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:05 +0000 (UTC)
Subject: dev-mornfall-lvmcache - cleanup: use proper activation_change_t
Message-ID: <20130605120205.32466613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a751ad703c8082aaf96c53fc1e76bd8fc607235
Commit:        5a751ad703c8082aaf96c53fc1e76bd8fc607235
Parent:        855175fa261c2c5de0e030615e2f274344e2d129
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 12:49:58 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:57 2013 +0200

cleanup: use proper activation_change_t

---
 tools/lvchange.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 7b0a517..cc3e96b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -212,9 +212,9 @@ static int lvchange_background_polling(struct cmd_context *cmd,
 
 static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	int activate;
+	activation_change_t activate;
 
-	activate = arg_uint_value(cmd, activate_ARG, 0);
+	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
 		lv = origin_from_cow(lv);


