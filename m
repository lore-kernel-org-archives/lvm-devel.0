From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:11 +0000 (UTC)
Subject: master - toollib: Report errors on non-PV arguments to process_each_label.
Message-ID: <20131117222711.352116105F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5095222fa4f8cea89b721dcb12adad89176413e
Commit:        d5095222fa4f8cea89b721dcb12adad89176413e
Parent:        67c563ac2b643f97602686dc07cee4a8bdb5bc34
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:32:51 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:43:06 2013 +0100

toollib: Report errors on non-PV arguments to process_each_label.

---
 tools/toollib.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 529088c..9a33e55 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1821,8 +1821,12 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 				continue;
 			}
 
-			if (!label_read(dev, &label, 0))
+			if (!label_read(dev, &label, 0)) {
+				log_error("No physical volume label read from %s",
+					  argv[opt]);
+				ret_max = ECMD_FAILED;
 				continue;
+			}
 
 			ret = process_single_label(cmd, label, handle);
 


