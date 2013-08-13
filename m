From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 13 Aug 2013 16:26:17 +0000 (UTC)
Subject: master - WHATS_NEW: be more precise
Message-ID: <20130813162617.C20C16142B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd7cac15bcc4fe2a6036b4408a8c53d003a6859f
Commit:        fd7cac15bcc4fe2a6036b4408a8c53d003a6859f
Parent:        e166c00ac619a17970b2a71429e02038b1ebf2dc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 13 18:25:54 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 13 18:25:54 2013 +0200

WHATS_NEW: be more precise

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6cce602..b1f379b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.101 - 
 ===================================
-  Also skip /var and /var/log by default in blkdeactivate.
+  Also skip /var and /var/log by default in blkdeactivate when unmounting.
   Add support for bind mounts in blkdeactivate.
   Add blkdeactivate -v/--verbose for debug output from external tools used.
   Add blkdeactivate -e/--errors for error messages from external tools used.


