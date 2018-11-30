From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 07:10:57 -0500
Subject: master - makefiles: clean unit-test
Message-ID: <201811301210.wAUCAvER014593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b87ffaa8a273ee7870298d9f74f0fabbf160148
Commit:        8b87ffaa8a273ee7870298d9f74f0fabbf160148
Parent:        7fb280ceacbacf6d0fb02ba1378e2caef2c8c582
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 12:55:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 30 13:03:09 2018 +0100

makefiles: clean unit-test

---
 test/unit/Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/unit/Makefile b/test/unit/Makefile
index a37a0aa..909cef2 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -35,7 +35,8 @@ UNIT_DEPENDS = $(UNIT_SOURCE:%.c=%.d)
 UNIT_OBJECTS = $(UNIT_SOURCE:%.c=%.o)
 CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 	$(UNIT_SOURCE:%.c=%.gcda) \
-	$(UNIT_SOURCE:%.c=%.gcno)
+	$(UNIT_SOURCE:%.c=%.gcno) \
+	test/unit/unit-test
 
 test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"


