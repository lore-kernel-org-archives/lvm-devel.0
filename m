From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 20 Aug 2013 23:36:17 +0000 (UTC)
Subject: dev-dct-process-part3 - toollib: Remove a spurious (debug) log_error.
Message-ID: <20130820233617.DE75460DE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ceeb7f620e79e811b4e461bbf661fe70b90c6a14
Commit:        ceeb7f620e79e811b4e461bbf661fe70b90c6a14
Parent:        a1dce692177b946ffa9ea85250567ad7abde729a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:34:12 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 21 01:35:33 2013 +0200

toollib: Remove a spurious (debug) log_error.

---
 tools/toollib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ab0cd0d..cc0acae 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1171,7 +1171,6 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 		if (!label_read(dev, &label, 0))
 			continue;
 
-		log_error("processing %s", dev_name(dev));
 		ret = process_single_label(cmd, label, handle);
 
 		if (ret > ret_max)


