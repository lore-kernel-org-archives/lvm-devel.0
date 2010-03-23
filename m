From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:35 +0100
Subject: [PATCH 2/6] Query make.tmpl variable
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <3e4113eb36cd0e26da4f9b66199d12963b9e7444.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid hard sed replacement - i.e. quick test change in make.tmpl
could avoid recofiguration steps in same debug cases.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index a4b1d78..593500e 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -88,7 +88,7 @@ endif
 check: all
 	$(MAKE) -C test all
 
-ifneq ("@LCOV@", "")
+ifneq ("$(LCOV)", "")
 .PHONY: lcov-reset lcov lcov-dated
 
 ifeq ($(MAKECMDGOALS),lcov-dated)
@@ -116,7 +116,7 @@ lcov: all
 		-a $(LCOV_REPORTS_DIR)/libdm.info \
 		-a $(LCOV_REPORTS_DIR)/tools.info \
 		-o $(LCOV_REPORTS_DIR)/lvm.info
-ifneq ("@GENHTML@", "")
+ifneq ("$(GENHTML)", "")
 	$(GENHTML) -o $(LCOV_REPORTS_DIR) -p $(top_srcdir) $(LCOV_REPORTS_DIR)/lvm.info
 endif
 
-- 
1.7.0.1


