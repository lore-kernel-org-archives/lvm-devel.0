From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Jan 2017 13:56:44 +0000 (UTC)
Subject: master - dmeventd_thind: set LVM_RUN_BY_DMEVENTD
Message-ID: <20170123135644.AA92660727@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=836eb122cec35c1f00281968d92f9d85e67652d7
Commit:        836eb122cec35c1f00281968d92f9d85e67652d7
Parent:        4a7f2155c1d6bd5df1226632c5c5d5631c5abc97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 23 14:23:24 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 23 14:55:47 2017 +0100

dmeventd_thind: set LVM_RUN_BY_DMEVENTD

Set LVM_RUN_BY_DMEVENTD envvar to expose the command is runing from
dmeventd environment.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index a6a534d..f551971 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -69,19 +69,23 @@ DM_EVENT_LOG_FN("thin")
 
 static int _run_command(struct dso_state *state)
 {
-	char val[2][36];
-	char *env[] = { val[0], val[1], NULL };
+	char val[3][36];
+	char *env[] = { val[0], val[1], val[2], NULL };
 	int i;
 
+	/* Mark for possible lvm2 command we are running from dmeventd
+	 * lvm2 will not try to talk back to dmeventd while processing it */
+	(void) dm_snprintf(val[0], sizeof(val[0]), "LVM_RUN_BY_DMEVENTD=1");
+
 	if (state->data_percent) {
 		/* Prepare some known data to env vars for easy use */
-		(void) dm_snprintf(val[0], sizeof(val[0]), "DMEVENTD_THIN_POOL_DATA=%d",
+		(void) dm_snprintf(val[1], sizeof(val[1]), "DMEVENTD_THIN_POOL_DATA=%d",
 				   state->data_percent / DM_PERCENT_1);
-		(void) dm_snprintf(val[1], sizeof(val[1]), "DMEVENTD_THIN_POOL_METADATA=%d",
+		(void) dm_snprintf(val[2], sizeof(val[2]), "DMEVENTD_THIN_POOL_METADATA=%d",
 				   state->metadata_percent / DM_PERCENT_1);
 	} else {
 		/* For an error event it's for a user to check status and decide */
-		env[0] = NULL;
+		env[1] = NULL;
 		log_debug("Error event processing");
 	}
 


