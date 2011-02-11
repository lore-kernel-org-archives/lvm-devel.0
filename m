From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:59 +0100
Subject: [PATCH 13/16] Add missing stack traces for polldaemon
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <c738d1a52874c7f78cb488477772b9360ee5ccff.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Traces for failing calls

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/polldaemon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 94e52a3..0555b94 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -148,7 +148,7 @@ static int _check_lv_status(struct cmd_context *cmd,
 	/* Finished? Or progress to next segment? */
 	if (progress == PROGRESS_FINISHED_ALL) {
 		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
-			return 0;
+			return_0;
 	} else {
 		if (parms->poll_fns->update_metadata &&
 		    !parms->poll_fns->update_metadata(cmd, vg, lv, lvs_changed, 0)) {
@@ -211,7 +211,7 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 
 		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
 			unlock_and_free_vg(cmd, vg, vg->name);
-			return 0;
+			return_0;
 		}
 
 		unlock_and_free_vg(cmd, vg, vg->name);
-- 
1.7.4


