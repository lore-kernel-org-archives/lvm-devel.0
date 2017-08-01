From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 12:34:40 -0400
Subject: master - makefiles: script executable missed dynamic
Message-ID: <201708011634.v71GYecD018047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad44543e8166d7068c8db1222aa06c786dcf58b3
Commit:        ad44543e8166d7068c8db1222aa06c786dcf58b3
Parent:        9dc1f51d2825c5e48da06e20a9c7a570fbef09a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 18:19:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 18:32:16 2017 +0200

makefiles: script executable missed dynamic

Add missing  ELDFLAGS when linking binary.
Also pass CFLAGS for cases where we build code coverage compilation.
---
 scripts/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index b0d72c6..d06766f 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -89,7 +89,7 @@ endif
 CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
 
 lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(LVMLIBS)
+	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)


