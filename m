From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 17:23:29 -0400
Subject: master - tests: drop some clvmd refs
Message-ID: <201806142123.w5ELNTC8014833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=faf3cc8f71a6e727e2124199eef25ff00e954c0f
Commit:        faf3cc8f71a6e727e2124199eef25ff00e954c0f
Parent:        b2cb8f846ac8061bb3e71d5805edd72e67d277db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 23:14:32 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 23:22:42 2018 +0200

tests: drop some clvmd refs

Do not try to link clvmd binary.
Ensure lib is created new and does not refer old binaries.
---
 test/Makefile.in |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index ca2e2e1..48ecdd7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -123,7 +123,6 @@ help:
 	@echo "  LVM_TEST_CACHE_RESTORE_CMD Command for cache_restore [$(LVM_TEST_CACHE_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
 	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
-	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMETAD	Enable valgrind testing of lvmetad (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
@@ -304,7 +303,6 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
 	echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
-	echo 'CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
 	echo 'LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
 	echo 'LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
 	echo 'LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
@@ -314,7 +312,7 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
 	echo 'LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION THIN RAID CACHE\' >> $@-t
-	echo ' LVMETAD_PIDFILE LVMPOLLD_PIDFILE DMEVENTD_PIDFILE CLVMD_PIDFILE\' >> $@-t
+	echo ' LVMETAD_PIDFILE LVMPOLLD_PIDFILE DMEVENTD_PIDFILE \' >> $@-t
 	echo ' LVM_TEST_THIN_CHECK_CMD LVM_TEST_THIN_DUMP_CMD LVM_TEST_THIN_REPAIR_CMD LVM_TEST_THIN_RESTORE_CMD\' >> $@-t
 	echo ' LVM_TEST_CACHE_CHECK_CMD LVM_TEST_CACHE_DUMP_CMD LVM_TEST_CACHE_REPAIR_CMD LVM_TEST_CACHE_RESTORE_CMD' >> $@-t
 	mv $@-t $@
@@ -358,12 +356,13 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 
 .lib-dir-stamp:
 	$(MKDIR_P) lib unit
+	$(RM) lib/clvmd
 	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
-	for i in daemons/clvmd/clvmd daemons/dmeventd/dmeventd \
-		tools/dmsetup daemons/lvmetad/lvmetad \
+	for i in daemons/dmeventd/dmeventd \
+		libdm/dm-tools/dmsetup daemons/lvmetad/lvmetad \
 		daemons/lvmpolld/lvmpolld ; do \
 		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
-	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmstats
+	$(LN_S) -f $(abs_top_builddir)/libdm/dm-tools/dmsetup lib/dmstats
 	$(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm


