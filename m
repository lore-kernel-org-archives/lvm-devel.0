From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 23:49:03 +0000 (UTC)
Subject: master - TEST: Avoid building unit tests with --disable-testing.
Message-ID: <20121009234903.E6AD7246B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff752c60dfde5f40e400746b98b17e511c9f1e34
Commit:        ff752c60dfde5f40e400746b98b17e511c9f1e34
Parent:        439989adab473b2fa867b1e492b205084471051a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 11:20:28 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 20:37:34 2012 +0200

TEST: Avoid building unit tests with --disable-testing.

---
 test/unit/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 65e8bec..740eb14 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -15,8 +15,8 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
-SOURCES = bitset_t.c matcher_t.c config_t.c string_t.c run.c
 ifeq ("@TESTING@", "yes")
+SOURCES = bitset_t.c matcher_t.c config_t.c string_t.c run.c
 TARGETS = run
 endif
 


