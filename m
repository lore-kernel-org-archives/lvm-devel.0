From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 27 Jul 2015 13:53:27 +0000 (UTC)
Subject: master - lvmlockd: Drop -lrt now handled by configure.
Message-ID: <20150727135327.66428602B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa11ddd7df9cd29956cb2610d4a730980734b8c2
Commit:        fa11ddd7df9cd29956cb2610d4a730980734b8c2
Parent:        3e333e9b5c0fcae2014dcb22f14d288b440b9576
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 27 14:53:08 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 27 14:53:08 2015 +0100

lvmlockd: Drop -lrt now handled by configure.

---
 daemons/lvmlockd/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index fed7c22..a2aca30 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -34,7 +34,7 @@ include $(top_builddir)/make.tmpl
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
 
-LIBS += $(PTHREAD_LIBS) -lrt
+LIBS += $(PTHREAD_LIBS)
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
   LIBS += -lsanlock_client


