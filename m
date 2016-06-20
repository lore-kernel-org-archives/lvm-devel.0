From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Jun 2016 16:19:30 +0000 (UTC)
Subject: master - vgscan: fix process_each args
Message-ID: <20160620161930.3E0E560FC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cae6591b9ddc5e94b64c542503d34448babf720f
Commit:        cae6591b9ddc5e94b64c542503d34448babf720f
Parent:        d1d3820219f6b0906bc0b3980b6eefcc187999d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 20 11:18:36 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 20 11:18:36 2016 -0500

vgscan: fix process_each args

zero/null args were mixed up.
---
 tools/vgscan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/vgscan.c b/tools/vgscan.c
index 45a2d7e..dfb1d46 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -117,8 +117,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	else
 		log_print_unless_silent("Reading volume groups from cache.");
 
-	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, NULL, 0,
-				 &vgscan_single);
+	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {
 		ret = vgmknodes(cmd, argc, argv);


