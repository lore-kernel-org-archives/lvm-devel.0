From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:32 -0500
Subject: [PATCH 10/19] lvm2app: Set suppress to 1
In-Reply-To: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
Message-ID: <1368053141-13836-11-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Removes printing to stdout/stderr etc.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_base.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 53be709..67ed023 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -66,6 +66,12 @@ lvm_t lvm_init(const char *system_dir)
 	 */
 	cmd->cmd_line = "liblvm";
 
+	/*
+	 * Turn off writing to stderr etc., not sure if there is a better way
+	 * to do this?
+	 */
+	log_suppress(1);
+
 	return (lvm_t) cmd;
 }
 
-- 
1.8.1.4


