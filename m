From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 11:00:46 -0400
Subject: master - lvchange: allow activating cachevol
Message-ID: <201909201500.x8KF0kKE018846@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b46dce0badb221b1417231e7bbf2d7d898a5a8c1
Commit:        b46dce0badb221b1417231e7bbf2d7d898a5a8c1
Parent:        515e37b6dd352bd71e63bdef24fc13e2ee75ff98
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 19 16:18:47 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 09:59:37 2019 -0500

lvchange: allow activating cachevol

---
 tools/lvchange.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 03a7793..65cea6c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1391,6 +1391,20 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 				     struct processing_handle *handle,
 				     int lv_is_named_arg)
 {
+	int do_activate = is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY));
+
+	if (lv_is_cache_vol(lv) && lv_is_named_arg) {
+		if (!do_activate)
+			return 1;
+
+		if (arg_is_set(cmd, yes_ARG) ||
+		    (yes_no_prompt("Do you want to activate component LV in read-only mode? [y/n]: ") == 'y')) {
+			log_print_unless_silent("Allowing activation of component LV.");
+			cmd->activate_component = 1;
+		}
+		return 1;
+	}
+
 	if (!lv_is_visible(lv) &&
 	    !cmd->activate_component && /* activation of named component LV */
 	    ((first_seg(lv)->status & MERGING) || /* merging already started */


