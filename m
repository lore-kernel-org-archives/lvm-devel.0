From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 13 Aug 2013 16:17:24 +0000 (UTC)
Subject: master - WHATS_NEW: one more for a85439
Message-ID: <20130813161724.80681613AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e166c00ac619a17970b2a71429e02038b1ebf2dc
Commit:        e166c00ac619a17970b2a71429e02038b1ebf2dc
Parent:        268b370e245ee0d6abaeeedff513c9678eeb7f54
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 13 18:16:05 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 13 18:16:05 2013 +0200

WHATS_NEW: one more for a85439

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 40e99e6..6cce602 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Also skip /var and /var/log by default in blkdeactivate.
   Add support for bind mounts in blkdeactivate.
   Add blkdeactivate -v/--verbose for debug output from external tools used.
   Add blkdeactivate -e/--errors for error messages from external tools used.


