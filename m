From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:33 +0000 (GMT)
Subject: main - makefiles: update doc
Message-ID: <20230213133133.CD5A73881D1A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31076942f10bdd2ef449697c1a315372b71ee8c1
Commit:        31076942f10bdd2ef449697c1a315372b71ee8c1
Parent:        4791a4fc68c681a45bcdc5660c6e96af607fab27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 16:10:19 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

makefiles: update doc

Document using of target useful for checking variable content.
---
 Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Makefile.in b/Makefile.in
index 1d5aff482..58f255d4d 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -171,6 +171,7 @@ help:
 	@echo "  lcov-dated		Generate lcov with timedate suffix."
 	@echo "  lcov-reset		Reset lcov counters"
 	@echo "  man			Build man pages."
+	@echo "  print-VARIABLE		Resolve make variable."
 	@echo "  rpm			Build rpm."
 	@echo "  run-unit-test		Run unit tests."
 	@echo "  tags			Generate c/etags."

