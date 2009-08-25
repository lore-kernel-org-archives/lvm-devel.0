From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Tue, 25 Aug 2009 07:55:01 +0200
Subject: [PATCH 1/1] Fix Makefile distclean targets
In-Reply-To: <1251179701-10229-1-git-send-email-fdinitto@redhat.com>
References: <1251179701-10229-1-git-send-email-fdinitto@redhat.com>
Message-ID: <a277d00b8eaaa67fa3e5eed331366a4947323fa1.1251179617.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove unwanted Makefiles and don't purge lvm2.po that's
under RCS.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 683021e... d6eec79... M	Makefile.in
:100644 100644 305cef5... 1d2b707... M	liblvm/Makefile.in
:100644 100644 5db9ab5... 3902303... M	make.tmpl.in
 Makefile.in        |    2 ++
 liblvm/Makefile.in |    1 +
 make.tmpl.in       |    2 +-
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 683021e..d6eec79 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -42,6 +42,8 @@ ifeq ($(MAKECMDGOALS),distclean)
 	     lib/locking \
 	     lib/mirror \
 	     lib/snapshot \
+	     liblvm \
+	     udev \
 	     test/api \
 	     test \
 	     po
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 305cef5..1d2b707 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -93,3 +93,4 @@ distclean_lib:
 	$(RM) $(LIB_NAME).pc
 
 distclean: distclean_lib
+	$(RM) -f Makefile
diff --git a/make.tmpl.in b/make.tmpl.in
index 5db9ab5..3902303 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -250,7 +250,7 @@ distclean: $(SUBDIRS.distclean)
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
-	      lvm-version.h lvm2.po
+	      lvm-version.h
 
 .export.sym: .exported_symbols
 	set -e; (echo "Base {"; echo "	global:"; \
-- 
1.5.4.3


