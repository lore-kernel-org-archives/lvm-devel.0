From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 20 Aug 2013 23:36:15 +0000 (UTC)
Subject: dev-dct-process-part3 - toollib: Report errors on non-PV arguments to process_each_label.
Message-ID: <20130820233615.CB56A60DE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1dce692177b946ffa9ea85250567ad7abde729a
Commit:        a1dce692177b946ffa9ea85250567ad7abde729a
Parent:        785d5122132450ca206eb187df69125b978af43c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:32:51 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 21 01:35:21 2013 +0200

toollib: Report errors on non-PV arguments to process_each_label.

---
 tools/toollib.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0af018a..ab0cd0d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1142,8 +1142,12 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
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
 


