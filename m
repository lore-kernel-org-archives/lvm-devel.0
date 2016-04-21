From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 21:00:24 +0000 (UTC)
Subject: master - poll daemon: only call lvmetad_connect when needed
Message-ID: <20160421210024.CA91560321@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d095c2fbb4383fc4830b9b714f8a7fd45b40fcd
Commit:        4d095c2fbb4383fc4830b9b714f8a7fd45b40fcd
Parent:        11dd36245450ed664c4a6bd177f17a8077c820a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 15:58:34 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 15:58:34 2016 -0500

poll daemon: only call lvmetad_connect when needed

When lvm is not using lvmetad, the lvmetad_connect()
in the forked polling process is not needed and was
generating unwanted warnings.
---
 tools/polldaemon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index c2211d7..6b15a0d 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -597,7 +597,7 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
 
-		if (daemon_mode == 1) {
+		if ((daemon_mode == 1) && find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
 			if (!lvmetad_connect(cmd))
 				log_warn("WARNING: lvm polling process %d cannot connect to lvmetad.", getpid());
 		}


