From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:52 +0100
Subject: [PATCH 20/23] exit if lvmchache_init fails
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <a643f11abefe02b16de3b627c882b438cb7d4f57.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/polldaemon.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 50579ba..bcc649f 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -64,7 +64,8 @@ static int _become_daemon(struct cmd_context *cmd)
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	reset_locking();
-	lvmcache_init();
+	if (!lvmcache_init())
+		_exit(ECMD_FAILED);
 	dev_close_all();
 
 	return 1;
-- 
1.7.3.4


