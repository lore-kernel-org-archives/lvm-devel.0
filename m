From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:28:49 +0000 (UTC)
Subject: master - make: CFLAGS, not CLDFLAGS
Message-ID: <20131204132849.545D060A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37853cc7a9e60036134034718f22ec688917146b
Commit:        37853cc7a9e60036134034718f22ec688917146b
Parent:        a65ab773b4ddb06e87d678d3b2f4d0ca3e5b9fd0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 4 14:28:40 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 14:28:40 2013 +0100

make: CFLAGS, not CLDFLAGS

---
 daemons/lvmetad/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index f08198a..67a557f 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -34,7 +34,8 @@ LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
 LIBS += $(PTHREAD_LIBS)
 
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_LDFLAGS)
-CLDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_CFLAGS)
+CLDFLAGS += -L$(top_builddir)/libdaemon/server
+CFLAGS += $(DAEMON_CFLAGS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a


