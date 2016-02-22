From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon, 22 Feb 2016 17:17:07 +0000 (UTC)
Subject: master - lvmdbusd: Fix make install for python >= 3.5
Message-ID: <20160222171707.3CF9361C6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec81c421793e63373cf6e119fe4bfd60368ee47d
Commit:        ec81c421793e63373cf6e119fe4bfd60368ee47d
Parent:        367fb85e44e0718a335c328ca75cb646539d3148
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Feb 22 18:14:23 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Feb 22 18:16:41 2016 +0100

lvmdbusd: Fix make install for python >= 3.5

python 3.5 renamed .pyo files to .opt-1.pyc.
---
 daemons/lvmdbusd/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 658fcd8..9ee5b0b 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -57,7 +57,7 @@ install_lvmdbusd:
 	$(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
 	PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
 	$(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
-	$(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.pyc $(DESTDIR)$(lvmdbusdir)/__pycache__/*.pyo
+	$(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
 
 install_lvm2: install_lvmdbusd
 


