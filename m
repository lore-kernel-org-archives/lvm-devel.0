From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 30 Nov 2016 22:17:36 +0000 (UTC)
Subject: master - WHATS_NEW: Allow a transiently failed RaidLV to be refreshed
Message-ID: <20161130221736.39E6B60AA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5da10fda4c0b7caa0e9cd221298a8ad475332e36
Commit:        5da10fda4c0b7caa0e9cd221298a8ad475332e36
Parent:        ad7fd775f2b7d2d8fa9fe9bbec5101d9ecda9a92
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Nov 30 23:17:21 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Nov 30 23:17:21 2016 +0100

WHATS_NEW: Allow a transiently failed RaidLV to be refreshed

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2f96ece..20f3296 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Allow a transiently failed RaidLV to be refreshed
   Use lv_update_and_reload() inside mirror code where it applies.
   Preserve mirrored status for temporary layered mirrors.
   Use transient raid check before repairing raid volume.


