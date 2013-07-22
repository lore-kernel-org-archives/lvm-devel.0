From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:24 +0000 (UTC)
Subject: master - python: make install to prefix dir
Message-ID: <20130722104224.A765D60DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03efb7c2e121d68ba39691b796dae8c9606108d4
Commit:        03efb7c2e121d68ba39691b796dae8c9606108d4
Parent:        c394c2a624b24193ca769bff956ca2bd8d1e5c1b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 20:48:41 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:22 2013 +0200

python: make install to prefix dir

Respect $prefix and avoid install to live system.
---
 python/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/python/Makefile.in b/python/Makefile.in
index 1fead22..9f9046b 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2011-2012 Red Hat, Inc.
+# Copyright (C) 2011-2013 Red Hat, Inc.
 #
 # This file is part of LVM2.
 #
@@ -27,7 +27,7 @@ liblvm_python.c:
 include $(top_builddir)/make.tmpl
 
 install_python_bindings: python_bindings
-	$(PYTHON) setup.py install --skip-build --root $(rootdir)
+	$(PYTHON) setup.py install --skip-build --root $(DESTDIR)$(prefix)
 
 install_lvm2: install_python_bindings
 


