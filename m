From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:03:24 +0000 (UTC)
Subject: master - cleanup: type cleanup
Message-ID: <20160623230324.A2F79609D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c212371fa6e65c783d7df50eab0108acb7b0cf8
Commit:        1c212371fa6e65c783d7df50eab0108acb7b0cf8
Parent:        7c921f18e236055b2d6b20794be076124489d6ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 00:35:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 00:39:14 2016 +0200

cleanup: type cleanup

Fix return code 1.
Since we always check for !() - this fix has no other effect.
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 77c9f01..5c61ddd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1655,7 +1655,7 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
 	if (lv_name && *lv_name && !apply_lvname_restrictions(*lv_name))
 		return_0;
 
-	return -1;
+	return 1;
 }
 
 /*


