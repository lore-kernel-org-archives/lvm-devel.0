From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  9 Apr 2010 17:42:55 +0200
Subject: [PATCH 3/3] Update intall rules for udev.
In-Reply-To: <cover.1270827575.git.zkabelac@redhat.com>
References: <cover.1270827575.git.zkabelac@redhat.com>
Message-ID: <9d08be7642d5e6691099476707279d870365d9de.1270827575.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix unwanted modification of $(top_builddir)/make.tmpl.

Using dependency rules to install rules for udev.
There is minor problem, with concurent usage of builddir
and srcdir could lead to missuse of 10-dm.rules which
could be found in VPATH from different builddir.
However current solution uses intermediate target so
the generated 10-dm.rules exists only for short period of time
during make install execution.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 udev/Makefile.in |   25 +++++++------------------
 1 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index 2511cf8..11635bb 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -25,24 +25,13 @@ include $(top_builddir)/make.tmpl
 
 vpath %.rules $(srcdir)
 
-%: %.in
+%.rules: %.rules.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
 
-install_lvm2: $(LVM_RULES)
-	@echo "Installing $(LVM_RULES) in $(udevdir)"
-	@for f in $(LVM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
-	done
-
-install_device-mapper: $(DM_RULES)
-	@echo "Installing $(DM_RULES) in $(udevdir)"
-	@for f in $(DM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
-	   if test -f $$f; then file=$$f; else file=$(srcdir)/$$f; fi; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$file $(udevdir)/$$f; \
-	done
+%_install: %.rules
+	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)
+
+install_device-mapper: $(DM_RULES:.rules=_install)
+install_lvm2: $(LVM_RULES:.rules=_install)
 
 install: install_lvm2 install_device-mapper
-- 
1.7.0.1


