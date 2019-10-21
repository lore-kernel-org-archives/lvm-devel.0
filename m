From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 Oct 2019 14:30:43 -0400
Subject: master - vgchange: remove bogus option restriction
Message-ID: <201910211830.x9LIUhFX001101@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=967e2decd22cee4aa4426cfda5732860e1a085b3
Commit:        967e2decd22cee4aa4426cfda5732860e1a085b3
Parent:        c08704cee7e34a96fdaa453faf900683283e8691
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 21 13:27:29 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 21 13:29:57 2019 -0500

vgchange: remove bogus option restriction

for -A with -a
---
 tools/vgchange.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 479ddd6..a10bf11 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -749,12 +749,6 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_is_set(cmd, activate_ARG) &&
-	    arg_is_set(cmd, autobackup_ARG)) {
-		log_error("-A option not necessary with -a option");
-		return EINVALID_CMD_LINE;
-	}
-
 	if (arg_is_set(cmd, maxphysicalvolumes_ARG) &&
 	    arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("MaxPhysicalVolumes may not be negative");


