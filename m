From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Apr 2015 09:36:44 +0000 (UTC)
Subject: master - tests: more help#
Message-ID: <20150428093644.8B22361086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71dbfd7c2077fc5d83eac37da68b55ef1a195d29
Commit:        71dbfd7c2077fc5d83eac37da68b55ef1a195d29
Parent:        3fbb7b6e35b12c36838139eb365b526129b63baf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 28 11:35:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 28 11:35:56 2015 +0200

tests: more help#

---
 test/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bf9b58e..04fbea0 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -76,6 +76,7 @@ help:
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
+	@echo "  LVM_TEST_BACKING_DEVICE Set device used for testing (see also LVM_TEST_DIR)."
 	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
 	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."


