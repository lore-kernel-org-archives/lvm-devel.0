From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:49 +0000 (UTC)
Subject: master - tests: document make parametr for tracing aux scripts
Message-ID: <20160420223549.C381F608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22a71e1119823be5ec76abff151f852ee366a00c
Commit:        22a71e1119823be5ec76abff151f852ee366a00c
Parent:        509b2e524795d28f68be06b862794f7f0c5c9991
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 20 23:18:51 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

tests: document make parametr for tracing aux scripts

---
 test/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index d4c6b95..0903b90 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -83,6 +83,7 @@ help:
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
+	@echo "  LVM_TEST_AUX_TRACE	Set for verbose messages for aux scripts []."
 	@echo "  LVM_TEST_BACKING_DEVICE Set device used for testing (see also LVM_TEST_DIR)."
 	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."


