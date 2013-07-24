From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 21:09:15 +0000 (UTC)
Subject: master - python: Introduce pyexecdir
Message-ID: <20130724210915.29E6560D3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97df05ce107ae2bed9ef02cfcdcdde39bd2100d4
Commit:        97df05ce107ae2bed9ef02cfcdcdde39bd2100d4
Parent:        462df8d89df2b87bbdb11c31b0b94523dea7aa28
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 24 22:07:10 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 24 22:07:10 2013 +0100

python: Introduce pyexecdir

Use pyexecdir for $DESTDIR + $prefix
---
 make.tmpl.in       |    1 +
 python/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index ae62182..e2c4441 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -73,6 +73,7 @@ systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
 systemd_generator_dir = $(DESTDIR)@systemdutildir@/system-generators
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
+pyexecdir = $(DESTDIR)$(prefix)
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
diff --git a/python/Makefile.in b/python/Makefile.in
index c9572d8..1aaec7e 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -27,7 +27,7 @@ liblvm_python.c:
 include $(top_builddir)/make.tmpl
 
 install_python_bindings: python_bindings
-	$(PYTHON) setup.py install --skip-build --prefix $(prefix)
+	$(PYTHON) setup.py install --skip-build --prefix $(pyexecdir)
 
 install_lvm2: install_python_bindings
 


