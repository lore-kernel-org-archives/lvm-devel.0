From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 17:42:23 -0500
Subject: 2018-06-01-stable - update WHATS_NEW
Message-ID: <201811062242.wA6MgNlr014508@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fda169077d09e4136d9af14990fb5bee045f196
Commit:        9fda169077d09e4136d9af14990fb5bee045f196
Parent:        9799c8da07b77844451c64bcbbce0d9d43ce2552
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 6 16:41:43 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 16:41:43 2018 -0600

update WHATS_NEW

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e3fcc6e..98b4c8f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.183 - 
 ====================================
+  Avoid opening devices to get block size by using existing open fd.
 
 Version 2.02.182 - 30th October 2018
 ====================================


