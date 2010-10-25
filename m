From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:19 +0200
Subject: [PATCH 12/30] Check for NULL pointer
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <70c73406f27835cb14a1fc88c2ea6e14c93938e4.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clangs is happier

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/reporter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index f39d23f..eb0a857 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -323,7 +323,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			log_error("Invalid options string: %s", opts);
 			return EINVALID_CMD_LINE;
 		}
-		if (*opts == '+') {
+		if (*opts == '+' && options) {
 			if (!(str = dm_pool_alloc(cmd->mem,
 					 strlen(options) + strlen(opts) + 1))) {
 				log_error("options string allocation failed");
-- 
1.7.3.1


