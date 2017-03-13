From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Mar 2017 15:14:55 -0400
Subject: master - commands: fix command matching for unused options
Message-ID: <201703131914.v2DJEtCH020664@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38292ca1d0a78aa6b06a4180b8e87cb9dd417a22
Commit:        38292ca1d0a78aa6b06a4180b8e87cb9dd417a22
Parent:        49cd54fc3a4cfbe785ba387a3c748362f74ea52f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 13 12:54:56 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 13 13:37:07 2017 -0500

commands: fix command matching for unused options

When a given command:

- matches command definition A based on required options,
  but uses optional options that are not accepted by A.

- matches command definition B based on required options,
  (but fewer required items than A), and uses no
  unaccepted optional options.

then B is the correct choice.  Command A would fail because
of the unaccepted optional options.  The logic was mistakenly
letting A win because it had a greater number of required option
matches, without accounting for the optional option mismatches.
---
 tools/lvmcmdline.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d1399c9..baf5d3b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1643,15 +1643,21 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 
 		/*
 		 * Choose the best match, which in general is the command with
-		 * the most matching required_{opt,pos}.
+		 * the most matching required_{opt,pos}, but it could be a
+		 * command with fewer required_{opt,pos} matches in the case
+		 * where cmddef1 has more required matches, but a match_unused
+		 * and cmddef2 has fewer required matches, but zero match_unused.
 		 *
 		 * A match is better if:
 		 * . more required opt/pos args match
 		 * . type arg matches when other doesn't
-		 * . those being equal, less unused options
+		 * . less unused options
 		 */
 
-		if (!best_required || (match_required > best_required) || (match_type > best_type) ||
+		if (!best_required ||
+		    ((match_required > best_required) && !match_unused) ||
+		    (match_unused < best_unused) ||
+		    (match_type > best_type) ||
 		    ((match_required == best_required) && (match_type == best_type) && (match_unused < best_unused))) {
 			/* log_warn("best %d has match_required %d match_ro %d match_rp %d",
 				 i, match_required, match_ro, match_rp); */


