From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:47 +0100
Subject: [PATCH 5/6] Add some missing vg_revrts calls when pvmove aborts.
In-Reply-To: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
References: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264280328-8728-5-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 tools/pvmove.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 47982e6..a286db1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -303,8 +303,10 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* Suspend lvs_changed */
-	if (!suspend_lvs(cmd, lvs_changed))
+	if (!suspend_lvs(cmd, lvs_changed)) {
+		vg_revert(vg);
 		goto_out;
+	}
 
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
@@ -324,6 +326,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 				stack;
 		if (!resume_lvs(cmd, lvs_changed))
 			stack;
+		vg_revert(vg);
 		goto out;
 	}
 
-- 
1.6.6


