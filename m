From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 12:04:05 +0000 (UTC)
Subject: master - WHATS_NEW: config handling changes
Message-ID: <20140306120405.1E1516098D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42eb9b45262f3cb9d9baf0903249128bb6923d4e
Commit:        42eb9b45262f3cb9d9baf0903249128bb6923d4e
Parent:        9a1d31a3c63e6e0078b4eb7e2afd43e2dcc65bc9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 6 13:03:51 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 13:03:51 2014 +0100

WHATS_NEW: config handling changes

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7deba2f..cfdc488 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Make lvm 'dumpconfig --type default' complete for it to be consumed by lvm.
   Run pvscan --cache via systemd-run in udev if the PV label is detected lost.
   Fix memleak when lvmetad discovers PV to appear on another device.
   Fix calculation of maximum size of COW device for snapshot (2.02.99).


