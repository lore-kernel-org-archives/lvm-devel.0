From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 08:22:09 -0400
Subject: [PATCH] Add lvmcache_init() to polldaemon initialization.
In-Reply-To: <1246018929-30950-1-git-send-email-dwysocha@redhat.com>
References: <1246018929-30950-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1246018929-30950-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/polldaemon.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d137f5f..8c5c7da 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -57,6 +57,7 @@ static int _become_daemon(struct cmd_context *cmd)
 	strncpy(*cmd->argv, "(lvm2copyd)", strlen(*cmd->argv));
 
 	reset_locking();
+	lvmcache_init();
 	dev_close_all();
 
 	return 1;
-- 
1.6.0.6


