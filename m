From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 15:33:08 +0000 (UTC)
Subject: master - configure: Fix a warning about test/Makefile.in.
Message-ID: <20150205153308.8DA7660E95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4065741a672d97f1c6b158ad781bc486c38e7c0a
Commit:        4065741a672d97f1c6b158ad781bc486c38e7c0a
Parent:        43d6b44a9fac5809bf73a88a7a6a106e302b4fe4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Feb 5 16:30:50 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 16:30:50 2015 +0100

configure: Fix a warning about test/Makefile.in.

---
 test/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index e0652e1..9e8e484 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -23,6 +23,7 @@ abs_srcdir = @abs_srcdir@
 abs_builddir = @abs_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
+datarootdir = @datarootdir@
 
 LVM_TEST_RESULTS ?= results
 export LVM_TEST_THIN_CHECK_CMD?=@THIN_CHECK_CMD@


