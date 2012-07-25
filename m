From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Jul 2012 03:29:16 +0000 (UTC)
Subject: master - Forgot to update WHATS_NEW for commit 5555d2a000ed4e3d5a694896f3dc6a7290543f43
Message-ID: <20120725032916.CFF19234F@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b607890203911a0f92e8f5d5f55e60b52d746ad
Commit:        1b607890203911a0f92e8f5d5f55e60b52d746ad
Parent:        5555d2a000ed4e3d5a694896f3dc6a7290543f43
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 24 22:28:23 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 24 22:28:23 2012 -0500

Forgot to update WHATS_NEW for commit 5555d2a000ed4e3d5a694896f3dc6a7290543f43

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa26622..bca890e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix segfault when attempting to replace RAID 4/5/6 device (2.02.97).
   Fix dumpconfig <node> to print only <node> without its siblings (2.02.89).
   Do not issue "Failed to handle a client connection" error if lvmetad killed.
   Support changing of discard and zeroing for thin pool.


