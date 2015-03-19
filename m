From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Mar 2015 10:25:03 +0000 (UTC)
Subject: master - makefiles: add more dirs for lcov
Message-ID: <20150319102503.CC07960E13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a13d2614664ba0bc7b5b345e446cfaa38de4c470
Commit:        a13d2614664ba0bc7b5b345e446cfaa38de4c470
Parent:        6407d184d1d4ce491035fe4d9e3ebbe6aefaa394
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 19 10:23:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 19 10:24:34 2015 +0100

makefiles: add more dirs for lcov

lvmetad lcovered.
---
 Makefile.in |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 641b833..41eb2e9 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -122,8 +122,11 @@ endif
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
-LCOV_TRACES = libdm.info lib.info tools.info \
-	daemons/dmeventd.info daemons/clvmd.info
+LCOV_TRACES = libdm.info lib.info liblvm.info tools.info \
+	libdaemon/client.info libdaemon/server.info \
+	daemons/clvmd.info daemons/dmeventd.info \
+	daemons/lvmetad.info
+
 CLEAN_TARGETS += $(LCOV_TRACES)
 
 ifneq ("$(LCOV)", "")


