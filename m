From: David Teigland <teigland@sourceware.org>
Date: Fri, 17 Mar 2017 12:55:15 -0400
Subject: master - man: advise against mirrored mirror log
Message-ID: <201703171655.v2HGtFnA009114@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07040942ed02455cf168ba6cf40264a644627553
Commit:        07040942ed02455cf168ba6cf40264a644627553
Parent:        8d7be8f5df2787354bb6cf40b6436047b82cfb58
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 17 11:54:39 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 17 11:54:39 2017 -0500

man: advise against mirrored mirror log

---
 tools/args.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 9d839b5..b81e2c9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -331,7 +331,8 @@ arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_VAL, 0, 0,
     "\\fBcore\\fP is not persistent; the log is kept only in memory.\n"
     "In this case, the mirror must be synchronized (by copying LV data from\n"
     "the first device to others) each time the LV is activated, e.g. after reboot.\n"
-    "\\fBmirrored\\fP is a persistent log that is itself mirrored.\n")
+    "\\fBmirrored\\fP is a persistent log that is itself mirrored, but\n"
+    "should be avoided. Instead, use the raid1 type for log redundancy.\n")
 
 arg(mirrorsonly_ARG, '\0', "mirrorsonly", 0, 0, 0,
     "Only remove missing PVs from mirror LVs.\n")


