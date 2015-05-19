From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:03:10 +0000 (UTC)
Subject: master - WHATS_NEW: various updates
Message-ID: <20150519190310.92B4460FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=788e4c54232372db6551d9a1323e1b59892900c1
Commit:        788e4c54232372db6551d9a1323e1b59892900c1
Parent:        e6b5eb88f23701446653ed616b54bec15c54d42d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 19 21:01:24 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 21:01:24 2015 +0200

WHATS_NEW: various updates

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index de3ddce..e14c858 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.121 - 
 ================================
+  Do not fail polling when poll LV not found (already finished or removed).
+  Replace poll_get_copy_vg/lv fns with vg_read() and find_lv() in polldaemon.
+  Close all device fds only in before sleep call in polldaemon.
 
 Version 2.02.120 - 15th May 2015
 ================================


