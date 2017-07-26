From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 26 Jul 2017 19:54:13 -0400
Subject: master - toolcontext: Improve invalid units error message.
Message-ID: <201707262354.v6QNsDqu018714@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3654f478e1beab950f9ee91bc2fd759d22552e1c
Commit:        3654f478e1beab950f9ee91bc2fd759d22552e1c
Parent:        54f5bc01b9509f80b3e8fe16f8bb1bc0228265ab
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 27 00:51:50 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 27 00:51:50 2017 +0100

toolcontext: Improve invalid units error message.

---
 lib/commands/toolcontext.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 678ee8a..39b300a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -474,10 +474,12 @@ bad:
 
 int process_profilable_config(struct cmd_context *cmd)
 {
+	const char *units;
+
 	if (!(cmd->default_settings.unit_factor =
-	      dm_units_to_factor(find_config_tree_str(cmd, global_units_CFG, NULL),
+	      dm_units_to_factor(units = find_config_tree_str(cmd, global_units_CFG, NULL),
 				 &cmd->default_settings.unit_type, 1, NULL))) {
-		log_error("Invalid units specification");
+		log_error("Unrecognised configuration setting for global/units: %s", units);
 		return 0;
 	}
 
@@ -2009,7 +2011,6 @@ out:
 		cmd = NULL;
 	}
 
-
 	return cmd;
 }
 


