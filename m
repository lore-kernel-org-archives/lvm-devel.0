From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 16 Jun 2014 23:57:18 +0000 (UTC)
Subject: master - poll_daemon: Cleanly exit polling if the LV is no longer active
Message-ID: <20140616235718.4046D612DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a20de8af208725ff2054209aa7ff7f41cc770db6
Commit:        a20de8af208725ff2054209aa7ff7f41cc770db6
Parent:        962a40b98134417f27e89709625ba2ec662204c2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 16 18:56:32 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 16 18:56:32 2014 -0500

poll_daemon:  Cleanly exit polling if the LV is no longer active

If the we are polling an LV due to some sort of conversion and it
becomes inactive, a rather worrisome message is produced, e.g.:
"  ABORTING: Mirror percentage check failed."

We can cleanly exit if we do a simple check to see if the LV is
active before performing the check.  This eliminates the scary
message.
---
 tools/polldaemon.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index be8a5a3..0765930 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -152,6 +152,16 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 			return 0;
 		}
 
+		/*
+		 * If the LV is not active locally, the kernel cannot be
+		 * queried for its status.  We must exit in this case.
+		 */
+		if (!lv_is_active_locally(lv)) {
+			log_print_unless_silent("%s: Interrupted: No longer active.", name);
+			unlock_and_release_vg(cmd, vg, vg->name);
+			return 1;
+		}
+
 		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return_0;


