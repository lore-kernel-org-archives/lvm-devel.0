From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 14:59:26 +0200
Subject: [PATCH 5/5] Check for NULL pointer
In-Reply-To: <cover.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
Message-ID: <c55e248db9914edda41a5d685539277b1bc486a8.1288097372.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clangs is happier and check for non NULL options value.
Report internal error in this case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/reporter.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index f39d23f..24a27ba 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -324,6 +324,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			return EINVALID_CMD_LINE;
 		}
 		if (*opts == '+') {
+			if (!options) {
+				log_error(INTERNAL_ERROR "Missing options.");
+				return EINVALID_CMD_LINE;
+			}
 			if (!(str = dm_pool_alloc(cmd->mem,
 					 strlen(options) + strlen(opts) + 1))) {
 				log_error("options string allocation failed");
-- 
1.7.3.2


