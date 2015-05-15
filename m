From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:14 +0000 (UTC)
Subject: master - lvmpolld-client.c: explain known return codes
Message-ID: <20150515183714.AB5F8610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cdd153b891527d04f36e2c7feb34a6aebdc63df
Commit:        6cdd153b891527d04f36e2c7feb34a6aebdc63df
Parent:        333fdfd4b69d04ff94eca644d335567dd70bc589
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 16:44:31 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:31:54 2015 +0200

lvmpolld-client.c: explain known return codes

lvmpolld returns few well known return codes. Explain
these to users and suggest reading lvmpolld log files
for more details
---
 lib/lvmpolld/lvmpolld-client.c |   37 ++++++++++++++++++++++++++++++++-----
 1 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 91f77eb..58bc86f 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -20,6 +20,7 @@
 #include "metadata-exported.h"
 #include "polldaemon.h"
 #include "toolcontext.h"
+#include "lvm2cmd.h"
 
 struct progress_info {
 	unsigned error:1;
@@ -88,6 +89,33 @@ void lvmpolld_disconnect(void)
 	}
 }
 
+static void _explain_error_codes(int retcode)
+{
+	switch (retcode) {
+	/* LVM2 return codes */
+	case LVM2_NO_SUCH_COMMAND:
+		log_error("LVM command run by lvmpolld responded with: 'No such command.'");
+		break;
+	case LVM2_INVALID_PARAMETERS:
+		log_error("LVM command run by lvmpolld failed due to invalid parameters.");
+		break;
+	case LVM2_PROCESSING_FAILED:
+		log_error("LVM command executed by lvmpolld failed.");
+		break;
+
+	/* lvmpolld specific return codes */
+	case LVMPD_RET_DUP_FAILED:
+		log_error("lvmpolld failed to duplicate file descriptors.");
+	case LVMPD_RET_EXC_FAILED:
+		log_error("lvmpolld failed to exec() lvm binary.");
+		break;
+	default:
+		log_error("lvmpolld responded with unexpected return code.");
+	}
+
+	log_print_unless_silent("For more information see lvmpolld messages in syslog or lvmpolld log file.");
+}
+
 static void _process_error_response(daemon_reply rep)
 {
 	if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_FAILED))
@@ -102,7 +130,7 @@ static void _process_error_response(daemon_reply rep)
 			  daemon_reply_str(rep, "response", "<empty>"),
 			  daemon_reply_str(rep, "reason", "<empty>"));
 
-	log_print_unless_silent("For more detailed information see lvmpolld log file.");
+	log_print_unless_silent("For more information see lvmpolld messages in syslog or lvmpolld log file.");
 }
 
 static struct progress_info _request_progress_info(const char *uuid, unsigned abort_polling)
@@ -310,12 +338,11 @@ int lvmpolld_request_info(const struct poll_operation_id *id, const struct daemo
 
 	if (info.finished) {
 		if (info.cmd_signal)
-			log_error("Polling command got terminated by signal (%d).",
+			log_error("Command executed by lvmpolld got terminated by signal (%d).",
 				  info.cmd_signal);
 		else if (info.cmd_retcode)
-			log_error("Polling command exited with return code: %d.",
-				  info.cmd_retcode);
-		else  {
+			_explain_error_codes(info.cmd_retcode);
+		else {
 			log_verbose("Polling finished successfully.");
 			ret = 1;
 		}


