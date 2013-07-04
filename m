From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  4 Jul 2013 12:51:47 +0000 (UTC)
Subject: master - config: fix timestamp comparison during merge
Message-ID: <20130704125147.A34E7613A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cb66fe16e0bc180a0be8e18d8b361b5b5842128
Commit:        1cb66fe16e0bc180a0be8e18d8b361b5b5842128
Parent:        a0ce432829d71da0c03647e249f4742cc98cea74
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 4 14:51:37 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 4 14:51:37 2013 +0200

config: fix timestamp comparison during merge

---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2994111..61e92cf 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1055,7 +1055,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	 * whether the .cache isn't older then any of configs
 	 */
 	cs = dm_config_get_custom(cft);
-	csn = dm_config_get_custom(cft);
+	csn = dm_config_get_custom(newdata);
 
 	if (cs && csn && (cs->timestamp < csn->timestamp))
 		cs->timestamp = csn->timestamp;


