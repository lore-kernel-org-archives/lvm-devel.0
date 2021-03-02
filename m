From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:45 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210302215845.2C7183834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0b0c20077affbd9671f89c7eab685ee3315e8d8
Commit:        d0b0c20077affbd9671f89c7eab685ee3315e8d8
Parent:        9cb913ab4bf8e8e98f2f84210e4bee55d7f177a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 00:15:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index e65f13123..cbd542fed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.12 - 
 ===================================
+  Support interruption when taking archive and backup.
+  Accelerate large lvremoves.
+  Speedup search for cached device nodes.
+  Speedup command initialization.
   Add devices file feature, off by default for now.
   Support extension of writecached volumes.
   Fix problem with unbound variable usage within fsadm.


