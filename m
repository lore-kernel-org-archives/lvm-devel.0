From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 09:01:28 +0000 (UTC)
Subject: master - makefiles: standard usage of make.tmpl
Message-ID: <20141122090128.9C56E60E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75d79f3dad99106c2ecb68c67507f9c367893ec1
Commit:        75d79f3dad99106c2ecb68c67507f9c367893ec1
Parent:        4dc602f79bd6579eef15a9227aee99fe832a7610
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 21 16:34:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 09:58:31 2014 +0100

makefiles: standard usage of make.tmpl

Use lvm2 standard TARGETS.

Make liblvm_python.c as intermediate target (gets deleted after use)

Properly delete build dir on make distclean.

Mark install_python_bindings as .PHONY.
---
 python/Makefile.in |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/python/Makefile.in b/python/Makefile.in
index 1aaec7e..843560e 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -15,7 +15,9 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-python_bindings: .liblvm_built
+TARGETS = .liblvm_built
+
+include $(top_builddir)/make.tmpl
 
 .liblvm_built: liblvm_python.c
 	$(PYTHON) setup.py build
@@ -24,18 +26,21 @@ python_bindings: .liblvm_built
 liblvm_python.c:
 	$(LN_S) $(srcdir)/liblvm.c $@
 
-include $(top_builddir)/make.tmpl
-
-install_python_bindings: python_bindings
+install_python_bindings: $(TARGETS)
 	$(PYTHON) setup.py install --skip-build --prefix $(pyexecdir)
 
 install_lvm2: install_python_bindings
 
 install: install_lvm2
 
+.PHONY: install_python_bindings
+.INTERMEDIATE: liblvm_python.c
+
 clean:
 	$(RM) -r build
 
-CLEAN_TARGETS += .liblvm_built liblvm_python.c
+distclean: clean
+
+CLEAN_TARGETS += liblvm_python.c
 
 DISTCLEAN_TARGETS += setup.py


