From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 20:54:02 +0000 (UTC)
Subject: master - python: fix Makefile installation path
Message-ID: <20130724205402.9AC0660EBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=462df8d89df2b87bbdb11c31b0b94523dea7aa28
Commit:        462df8d89df2b87bbdb11c31b0b94523dea7aa28
Parent:        f5a205668b9965a7a2471d9e7cbcd3db49a495c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 24 21:52:39 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 24 21:52:39 2013 +0100

python: fix Makefile installation path

Use --prefix rather than --root.
(Needs more thorough investigation, but this seems to avoid /usr/usr
paths.)
---
 python/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/python/Makefile.in b/python/Makefile.in
index fd529b8..c9572d8 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -27,7 +27,7 @@ liblvm_python.c:
 include $(top_builddir)/make.tmpl
 
 install_python_bindings: python_bindings
-	$(PYTHON) setup.py install --skip-build --root $(DESTDIR)$(prefix)
+	$(PYTHON) setup.py install --skip-build --prefix $(prefix)
 
 install_lvm2: install_python_bindings
 


