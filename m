From: okozina <okozina@fedoraproject.org>
Date: Tue, 31 Mar 2015 11:17:41 +0000 (UTC)
Subject: master - polldaemon: fix indentation in _poll_vg fn
Message-ID: <20150331111741.07D8560F58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04826db7c415028cb4a16bdde5553859779380ac
Commit:        04826db7c415028cb4a16bdde5553859779380ac
Parent:        663254d7a5d84ef5803875806c461513f581f4e2
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 31 13:16:01 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Mar 31 13:16:01 2015 +0200

polldaemon: fix indentation in _poll_vg fn

---
 tools/polldaemon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 20a18fa..6b06506 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -230,8 +230,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 			continue;
 		}
 
-		if (!str_list_add(cmd->mem, sls, dm_pool_strdup(cmd->mem, name)))
-		{
+		if (!str_list_add(cmd->mem, sls, dm_pool_strdup(cmd->mem, name))) {
 			log_error("Failed to clone pvname");
 			goto err;
 		}


