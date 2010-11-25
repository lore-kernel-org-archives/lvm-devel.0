From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:33 +0100
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
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
index 40d3c9a..16c19e2 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -328,6 +328,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
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


