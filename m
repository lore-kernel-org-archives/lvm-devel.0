From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 27 Oct 2017 11:11:17 -0400
Subject: master - man: Makefiles with V=1 support
Message-ID: <201710271511.v9RFBHvD014711@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c68c19c322e23242b21885d759ab5ec3bbe8e08
Commit:        0c68c19c322e23242b21885d759ab5ec3bbe8e08
Parent:        4b0f6829f63d36b473f6670a41ac7521ff82674d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 27 16:44:11 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 27 17:05:15 2017 +0200

man: Makefiles with V=1 support

Generation of man pages is generating lot of barely readable output.
For normal build quietize this a bit.

For original verbose build start to use  'make V=1'
(just like i.e. linux kernel does)

TODO: apply at more places...
---
 man/Makefile.in |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index b8f3aeb..cd1106f 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -46,6 +46,19 @@ MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
+ifeq ("$(origin V)", "command line")
+  BUILD_VERBOSE = $(V)
+endif
+ifndef BUILD_VERBOSE
+  BUILD_VERBOSE = 0
+endif
+
+ifeq ($(BUILD_VERBOSE),1)
+  Q =
+else
+  Q = @
+endif
+
 
 ifeq ($(MAKECMDGOALS),all_man)
   MAN_ALL="yes"
@@ -151,14 +164,14 @@ SEE_ALSO=$(srcdir)/see_also.end
 .PRECIOUS: %.8_gen
 
 %.8_gen: $(srcdir)/%.8_des $(srcdir)/%.8_end $(MANGENERATOR) $(TESTMAN)
-	@( \
+	$(Q)( \
 	    if [ ! -s $(TESTMAN) ] ; then \
 		echo "Copying pre-generated template $@" ; \
 	    else \
 		echo "Generating template $@" ; \
 	    fi \
 	)
-	set -e ; ( \
+	$(Q)set -e ; ( \
 	    if [ ! -s $(TESTMAN) ] ; then \
 		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
 	    else \
@@ -171,8 +184,8 @@ SEE_ALSO=$(srcdir)/see_also.end
 	) > $@
 
 define SUBSTVARS
-echo "Generating $@"
-$(SED)	-e "s+#VERSION#+$(LVM_VERSION)+" \
+$(Q)echo "Generating $@"
+$(Q)$(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+" \
 	-e "s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+" \
 	-e "s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+" \
@@ -197,7 +210,7 @@ endef
 # - in "$vg-$lv"
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
-$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+$(Q)$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \


