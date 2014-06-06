From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:27 +0000 (UTC)
Subject: dev-prajnoha-report-select - vgchange: With '--yes', don't prompt the user
Message-ID: <20140606120327.3040B60FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0f9c79ae8e1df16d23f3eb608fb4bf5455ec841
Commit:        c0f9c79ae8e1df16d23f3eb608fb4bf5455ec841
Parent:        1f2aedb1903d1422b7093f6afbdd81d912c969b6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 5 22:45:19 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 5 22:45:19 2014 -0500

vgchange:  With '--yes', don't prompt the user

If the user supplies a '--yes' argument, then don't bother them with
a question to confirm whether to change the cluster attribute (even
if clvmd isn't running).
---
 tools/vgchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 478a8ca..958919c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -317,7 +317,7 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (clustered) {
+	if (clustered && !arg_count(cmd, yes_ARG)) {
 		if (!dm_daemon_is_running(CLVMD_PIDFILE)) {
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
 					  " running.\n"


