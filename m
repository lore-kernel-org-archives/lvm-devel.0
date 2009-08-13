From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:27:01 -0400
Subject: [PATCH 7/9] Refactor vgsplit: _vgsplit_from or _vgsplit_to failure cleanup depends on order.
In-Reply-To: <1250198823-11591-7-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-6-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index bfcd7f5..7fe39e9 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -315,8 +315,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	vg_from = _vgsplit_from(cmd, vg_name_from);
-	if (!vg_from)
+	if (!vg_from) {
+		if (!lock_vg_from_first)
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
+	}
 
 	/*
 	 * Set metadata format of original VG.
@@ -327,7 +330,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 	if (!vg_to) {
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		if (lock_vg_from_first)
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
 	if (existing_vg) {
-- 
1.6.0.6


