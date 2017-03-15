From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Mar 2017 21:37:47 -0400
Subject: master - man: specify man-generator path
Message-ID: <201703150137.v2F1blxP007802@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f536c53aee3e64495ab71d625426f4f965713e77
Commit:        f536c53aee3e64495ab71d625426f4f965713e77
Parent:        1dc1a1cedb5ba3d9f48d2d5915145c3fdabf6cb7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 15 01:36:12 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 15 01:36:12 2017 +0000

man: specify man-generator path

---
 man/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index e7020cd..ae1739e 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -112,7 +112,7 @@ MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
 
-MANGENERATOR=man-generator
+MANGENERATOR=./man-generator
 TESTMAN=test.gen
 
 include $(top_builddir)/make.tmpl


