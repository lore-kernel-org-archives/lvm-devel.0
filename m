From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 22 Jul 2009 17:38:15 +0200
Subject: [PATCH 4/5] Add liblvm dynamic install target.
In-Reply-To: <1248277096-29947-4-git-send-email-twoerner@redhat.com>
References: <1248277096-29947-1-git-send-email-twoerner@redhat.com>
	<1248277096-29947-2-git-send-email-twoerner@redhat.com>
	<1248277096-29947-3-git-send-email-twoerner@redhat.com>
	<1248277096-29947-4-git-send-email-twoerner@redhat.com>
Message-ID: <1248277096-29947-5-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Install liblvm2app into libdir altogether with the devel link.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 liblvm/Makefile.in |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 0deaeac..f19069d 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -43,3 +43,25 @@ liblvm.cflow: $(SOURCES)
 		 ) > $@
 
 cflow: liblvm.cflow
+
+.PHONY: install_dynamic install_include install_pkgconfig
+
+INSTALL_TYPE = install_dynamic
+
+ifeq ("@PKGCONFIG@", "yes")
+  INSTALL_TYPE += install_pkgconfig
+endif
+
+install: $(INSTALL_TYPE) install_include
+
+install_include:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm.h $(includedir)/lvm.h
+
+install_dynamic:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $(VERSIONED_SHLIB) \
+		$(libdir)/$(VERSIONED_SHLIB)
+	$(LN_S) -f $(VERSIONED_SHLIB) $(libdir)/$(LIB_NAME).$(LIB_SUFFIX)
+
+.PHONY: distclean_lib distclean
+
+distclean: distclean_lib
-- 
1.6.2.5


