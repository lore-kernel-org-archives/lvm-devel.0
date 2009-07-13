From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 00:12:35 -0400
Subject: [PATCH 2/5] Add default cmd->cmd_line initialization for liblvm lvm_create().
In-Reply-To: <1247458358-24590-2-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1247458358-24590-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This needs initialized to non-NULL before using the archive() call.
Normally this is set to the cmdline string when lvm is called from a tool.
We could think about using it in another way, as a potential audit trail
of liblvm calls, or just leave it set to the default "liblvm", similar to
what clvmd does.  For now, just set it to "liblvm".

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm_base.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 213246a..4fa8541 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -45,6 +45,12 @@ lvm_t lvm_create(const char *system_dir)
 		lvm_destroy((lvm_t) cmd);
 		return NULL;
 	}
+	/*
+	 * FIXME: Use cmd->cmd_line as audit trail for liblvm calls.  Used in
+	 * archive() call.  Possible example:
+	 * cmd_line = "lvm_vg_create: vg1\nlvm_vg_extend vg1 /dev/sda1\n"
+	 */
+	cmd->cmd_line = (char *)"liblvm";
 
 	return (lvm_t) cmd;
 }
-- 
1.6.0.6


