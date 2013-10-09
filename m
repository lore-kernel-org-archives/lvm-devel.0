From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Oct 2013 10:11:51 +0000 (UTC)
Subject: master - WHATS_NEW: commit d888a05 and 808a5d9
Message-ID: <20131009101151.65B8460A3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=863be9d9c6dbe84f072b77d37a64de601bd2f76b
Commit:        863be9d9c6dbe84f072b77d37a64de601bd2f76b
Parent:        a7c73154ea4f751cfd7e72162d355844993d72fa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 9 12:11:12 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 9 12:11:12 2013 +0200

WHATS_NEW: commit d888a05 and 808a5d9

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7450f04..39c5b05 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.104
 ===================================
+  Fix incorrect memory handling when reading messages from lvmetad.
+  Fix locking in lvmetad when handling the PV which is gone.
   Recognize new flag to skip udev scanning in udev rules and act appropriately.
   Add support for flagging an LV to skip udev scanning during activation.
   Improve message when unable to change discards setting on active thin pool.


