From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:26:57 -0400
Subject: [PATCH 3/9] Refactor vgsplit - remove bad2 label.
In-Reply-To: <1250198823-11591-3-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index fd4099f..8607548 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -287,7 +287,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);
 			stack;
-			goto bad2;
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			return ECMD_FAILED;
 		}
 
 	} else if (vg_read_error(vg_to) == SUCCESS) {
@@ -427,7 +428,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 bad:
 	unlock_and_release_vg(cmd, vg_to, vg_name_to);
-bad2:
 	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	return r;
 }
-- 
1.6.0.6


