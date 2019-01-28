From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Jan 2019 12:24:37 -0500
Subject: master - vgscan: drop 'take a while' message
Message-ID: <201901281724.x0SHObgh030166@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30ad845f3d140f6778775ae5fe901b5d7e4988bc
Commit:        30ad845f3d140f6778775ae5fe901b5d7e4988bc
Parent:        2a45ef030060a28fa152f6245828a97df04c195c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 28 11:22:42 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 28 11:22:42 2019 -0600

vgscan: drop 'take a while' message

every command does this
---
 tools/vgscan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/vgscan.c b/tools/vgscan.c
index 470e3d8..6138855 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -57,8 +57,6 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
-
 	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &_vgscan_single);
 
 	if (arg_is_set(cmd, mknodes_ARG)) {


