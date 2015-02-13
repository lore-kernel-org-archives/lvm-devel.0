From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:30 +0000 (UTC)
Subject: master - pvchange: no need to initialize selection handle directly, process_each_pv will do that automatically
Message-ID: <20150213102930.E5D99613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a729331432167008f4298903adb78d75abb267c
Commit:        1a729331432167008f4298903adb78d75abb267c
Parent:        e1710f34bbbb46f8f6c6cc7ba284a4cbdac6dc2e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 09:28:24 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 09:29:30 2015 +0100

pvchange: no need to initialize selection handle directly, process_each_pv will do that automatically

---
 tools/pvchange.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index 9a673f7..a8414c1 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -172,8 +172,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (!(handle = init_processing_handle(cmd)) ||
-	    (handle->internal_report_for_select && !init_selection_handle(cmd, handle, PVS))) {
+	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
 		goto out;


