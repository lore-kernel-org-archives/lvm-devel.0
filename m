From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Oct 2013 13:59:52 +0000 (UTC)
Subject: master - WHATS_NEW: commit 0decd75
Message-ID: <20131009135952.AB35660E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b91847beb38c3bd522a6ecb62e0a275825c0b5d
Commit:        1b91847beb38c3bd522a6ecb62e0a275825c0b5d
Parent:        bcb44281b7c379ed3310b5f9a16ce380d84f31dc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 9 15:59:19 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 9 15:59:19 2013 +0200

WHATS_NEW: commit 0decd75

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 39c5b05..dd274da 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Fix failing metadata repair when lvmetad is used.
   Fix incorrect memory handling when reading messages from lvmetad.
   Fix locking in lvmetad when handling the PV which is gone.
   Recognize new flag to skip udev scanning in udev rules and act appropriately.


