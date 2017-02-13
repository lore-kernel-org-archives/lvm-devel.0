From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 19:46:35 +0000 (UTC)
Subject: master - commands: suggest --help if command doesn't match
Message-ID: <20170213194635.ECE6260921@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2fd5b31d3cbe1267ab01c4d6af4785f800938f4
Commit:        b2fd5b31d3cbe1267ab01c4d6af4785f800938f4
Parent:        698abdde165a3e747b81f18cf3405f2d4abb5bae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 13 13:46:17 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 13:46:17 2017 -0600

commands: suggest --help if command doesn't match

---
 tools/lvmcmdline.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 58d1a44..44efc85 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1542,6 +1542,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	if (!best_required) {
 		/* cmd did not have all the required opt/pos args of any command */
 		log_error("Failed to find a matching command definition.");
+		log_error("Run '%s --help' for more information.", name);
 		if (close_ro) {
 			log_warn("Closest command usage is:");
 			print_usage(&_cmdline.commands[close_i]);


