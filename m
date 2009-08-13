From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:26:58 -0400
Subject: [PATCH 4/9] Refactor vgsplit - add 'lock_vg_from_first' flag.
In-Reply-To: <1250198823-11591-4-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce 'lock_vg_from_first' flag to retain which vg was locked first.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 8607548..1a9e45e 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -218,6 +218,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
+	int lock_vg_from_first = 1;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -427,7 +428,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_and_release_vg(cmd, vg_to, vg_name_to);
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	if (lock_vg_from_first) {
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	} else {
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	}
 	return r;
 }
-- 
1.6.0.6


