From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 13:50:03 +0000 (UTC)
Subject: master - man: fix pages for generators
Message-ID: <20141124135003.81FA7613B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a058fab118b74ddddc8492752748f0a68c014ce6
Commit:        a058fab118b74ddddc8492752748f0a68c014ce6
Parent:        8bc7b4f926c8ae24c99391c39fc8e2a9fa55d80a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 00:32:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 14:39:04 2014 +0100

man: fix pages for generators

Properly generate man page for systemd generators on make.
Simplified  install_clusters
---
 man/Makefile.in |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 5a11ae2..40bf7a2 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -77,14 +77,10 @@ MAN8DIR=$(mandir)/man8
 
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
-CLEAN_TARGETS=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(MAN8DM)
-DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmcache.7 lvmthin.7 blkdeactivate.8
-
 include $(top_builddir)/make.tmpl
 
-ifneq ("@CLVMD@", "none")
-  install: install_cluster
-endif
+CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
+DISTCLEAN_TARGETS+=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8 lvmcache.7 lvmthin.7 blkdeactivate.8
 
 all: man device-mapper
 
@@ -92,7 +88,7 @@ all: man device-mapper
 
 device-mapper: $(MAN8DM)
 
-man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER)
+man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
 
 $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
@@ -134,4 +130,4 @@ ifdef MAN8SYSTEMD_GENERATORS
 	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
 endif
 
-install: install_lvm2 install_device-mapper
+install: install_lvm2 install_device-mapper install_cluster


