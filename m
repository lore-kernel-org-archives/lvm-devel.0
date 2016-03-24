From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 24 Mar 2016 11:47:42 +0000 (UTC)
Subject: master - WHATS_NEW: commit 6129d2e64d14047169048775dc7081135c0fcc50
Message-ID: <20160324114742.1327160D06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37b548c6b5106315943454df8c5392c9bd604368
Commit:        37b548c6b5106315943454df8c5392c9bd604368
Parent:        6129d2e64d14047169048775dc7081135c0fcc50
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 24 12:47:35 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 24 12:47:35 2016 +0100

WHATS_NEW: commit 6129d2e64d14047169048775dc7081135c0fcc50

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32528a2..652b24f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.148 - 
 ==================================
+  Fix missing /dev sync in lvm2 command before dmeventd monitor/unmonitor.
   Replace hard-coded module and target names with macros.
   Add pv_major and pv_minor report fields.
   Detect and warn about mismatch between devices used and assumed for an LV.


