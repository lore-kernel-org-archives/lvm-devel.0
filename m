From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Aug 2019 11:16:33 -0400
Subject: master - WHATS_NEW: vgcreate/vgextend logical block size
Message-ID: <201908011516.x71FGXCm003136@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a0d493d918510d863ddbdbc63d8a8ccb6ca2dd9
Commit:        3a0d493d918510d863ddbdbc63d8a8ccb6ca2dd9
Parent:        cd8a0133fa28a0dff2714c80f822e8c665fe6237
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 10:15:27 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 1 10:15:27 2019 -0500

WHATS_NEW: vgcreate/vgextend logical block size

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cb693de..a7ccd39 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Prevent creating VGs with PVs with different logical block sizes.
   Fix metadata writes from corrupting with large physical block size.
 
 Version 2.03.05 - 15th June 2019


