From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Jul 2019 17:15:02 -0400
Subject: master - WHATS_NEW: fix large physical block size
Message-ID: <201907302115.x6ULF2KA018117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1996c78c18ee0b555e4f7eba16858d8dd4fa0a1
Commit:        c1996c78c18ee0b555e4f7eba16858d8dd4fa0a1
Parent:        e3ba8561fa128e145c6952f4b962c11fc93f4ebc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 30 16:14:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 30 16:14:28 2019 -0500

WHATS_NEW: fix large physical block size

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e4d1ac7..cb693de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Fix metadata writes from corrupting with large physical block size.
 
 Version 2.03.05 - 15th June 2019
 ================================


