From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:27:03 -0400
Subject: [PATCH 9/9] Change vgsplit behavior to open/lock first vg based on alphabetical ordering.
In-Reply-To: <1250198823-11591-9-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-6-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-7-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-8-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the destination vgname comes before the source vgname, we must open the
destination first because of the locking rules.  Thus, do a strcmp and set
the flag based on the comparison.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index ef1ab2c..a8e525d 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -314,6 +314,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (strcmp(vg_name_to, vg_name_from) < 0)
+		lock_vg_from_first = 0;
+
 	if (lock_vg_from_first) {
 		vg_from = _vgsplit_from(cmd, vg_name_from);
 		if (!vg_from)
-- 
1.6.0.6


