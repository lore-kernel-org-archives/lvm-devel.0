From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Feb 2016 09:22:46 +0000 (UTC)
Subject: master - makefiles: add more dirs for lcov output
Message-ID: <20160226092246.9277D60DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85a593c1911f5c7ef5a8de38178b085c02ad3965
Commit:        85a593c1911f5c7ef5a8de38178b085c02ad3965
Parent:        3e31f5186904328d7f3fc8eae71cda72715107e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 10:14:39 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 26 10:21:34 2016 +0100

makefiles: add more dirs for lcov output

New daemons were missing in generated lcov output.
---
 Makefile.in |    7 +++++--
 WHATS_NEW   |    1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 7557f62..52441f1 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -166,8 +166,11 @@ install_tmpfiles_configuration:
 
 LCOV_TRACES = libdm.info lib.info liblvm.info tools.info \
 	libdaemon/client.info libdaemon/server.info \
-	daemons/clvmd.info daemons/dmeventd.info \
-	daemons/lvmetad.info
+	daemons/clvmd.info \
+	daemons/dmeventd.info \
+	daemons/lvmetad.info \
+	daemons/lvmlockd.info \
+	daemons/lvmpolld.info
 
 CLEAN_TARGETS += $(LCOV_TRACES)
 
diff --git a/WHATS_NEW b/WHATS_NEW
index ecae780..f91b3d0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Update makefile to generate lcov output also for lvmpolld and lvmlockd.
   Fix SystemdService lvm2-lvmdbusd.service name.
   Improve support for env LVM_VG_NAME for reference VG name in lvconvert.
   Fix regresion when lvresize accepted zero sizes (2.02.141).


