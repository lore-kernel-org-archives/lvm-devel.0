From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:17 +0000 (UTC)
Subject: master - lvm2app: Set suppress to 1
Message-ID: <20130702192617.5117360F45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfa265f1985818567b1eb6f7fae0ff3ba315b152
Commit:        bfa265f1985818567b1eb6f7fae0ff3ba315b152
Parent:        45a0f9e45be5999095c71382361f37f7c24d86d6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Apr 2 17:10:02 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lvm2app: Set suppress to 1

Removes printing to stdout/stderr etc.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_base.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

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
 


