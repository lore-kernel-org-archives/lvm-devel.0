From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Jun 2018 15:32:53 -0400
Subject: 2018-06-01-stable - WHATS_NEW: recent changes
Message-ID: <201806201932.w5KJWrN1027857@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bd9a89c148fa66c343e1754485af2387e5fbed1
Commit:        8bd9a89c148fa66c343e1754485af2387e5fbed1
Parent:        a30e6222799409ab6e6151683c95eb13f4abaefb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 20 14:32:29 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 20 14:32:29 2018 -0500

WHATS_NEW: recent changes

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e4342a1..b12ca25 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.180 - 
 =================================
+  Reopen devices RDWR before writing to avoid udev issues.
+  Fix mem leak in clvmd.
 
 Version 2.02.179 - 18th June 2018
 =================================


