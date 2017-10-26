From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Oct 2017 08:05:50 -0400
Subject: master - Makefile: help shows hint about LVM_LOG_FILE_MAX_LINES
Message-ID: <201710261205.v9QC5oBX008080@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04186616bef6789d6f363a1d461c01d344616c7a
Commit:        04186616bef6789d6f363a1d461c01d344616c7a
Parent:        837bfab75c712c28c161309f1381bb7a84eb17fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 26 13:57:51 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 26 14:04:58 2017 +0200

Makefile: help shows hint about LVM_LOG_FILE_MAX_LINES

---
 test/Makefile.in |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index c3285e4..230ce5b 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -114,8 +114,9 @@ help:
 	@echo "  LVM_STRACE		Enable strace logging."
 	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
-	@echo "  S			Skip given test (regex)."
-	@echo "  T			Run given test (regex)."
+	@echo "  LVM_LOG_FILE_MAX_LINES	Maximum number of logged lines for lvm2 command [1000000]."
+	@echo "  S			Skip given test(s) (regex)."
+	@echo "  T			Run given test(s) (regex)."
 	@echo "  VERBOSE		Verbose output (1), timing (2)."
 
 check: .tests-stamp


