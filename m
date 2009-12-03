From: Milan Broz <mbroz@redhat.com>
Date: Thu,  3 Dec 2009 16:36:22 +0100
Subject: [PATCH] Fix pvmove test mode to not fail and do not poll.
Message-ID: <1259854582-2701-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test mode should not fail nor try to poll non-existent devices.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/pvmove.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index ac09d6a..745f5ca 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -312,8 +312,10 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME: Add option to use a log */
 	if (first_time) {
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			if (test_mode())
+			if (test_mode()) {
+				r = 1;
 				goto out;
+			}
 
 			/*
 			 * Nothing changed yet, try to revert pvmove.
@@ -570,6 +572,9 @@ static struct poll_functions _pvmove_fns = {
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		unsigned background)
 {
+	if (test_mode())
+		return ECMD_PROCESSED;
+
 	return poll_daemon(cmd, pv_name, NULL, background, PVMOVE, &_pvmove_fns,
 			   "Moved");
 }
-- 
1.6.5.3


