From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:34 +0200
Subject: [PATCH 13/15] clvmd/Makefile: cut down on unnecessary checks
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <db8ea77d24ff004af1206a5b51d6b972f3a55796.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove some duplication that's no longer necessary.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 a79952c... c23b51e... M	daemons/clvmd/Makefile.in
 daemons/clvmd/Makefile.in |   31 ++++---------------------------
 1 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index a79952c..c23b51e 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -38,55 +38,32 @@ SOURCES = \
 	lvm-functions.c  \
 	refresh_clvmd.c
 
-ifneq (,$(findstring gulm,, "@CLVMD@,"))
-	GULM = yes
-endif
-
-ifneq (,$(findstring cman,, "@CLVMD@,"))
-	CMAN = yes
-endif
-
-ifneq (,$(findstring openais,, "@CLVMD@,"))
-	OPENAIS = yes
-endif
-
-ifneq (,$(findstring corosync,, "@CLVMD@,"))
-	COROSYNC = yes
-endif
-
-ifneq (,$(findstring all,, "@CLVMD@,"))
-	GULM = yes
-	CMAN = yes
-	OPENAIS = yes
-	COROSYNC = yes
-endif
-
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-ifeq ("$(GULM)", "yes")
+ifneq (,$(findstring gulm,, "@CLVMD@,"))
 	SOURCES += clvmd-gulm.c tcp-comms.c
 	LMLIBS += $(CCS_LIBS) $(GULM_LIBS)
 	CFLAGS += $(CCS_CFLAGS) $(GULM_CFLAGS)
 	DEFS += -DUSE_GULM
 endif
 
-ifeq ("$(CMAN)", "yes")
+ifneq (,$(findstring cman,, "@CLVMD@,"))
 	SOURCES += clvmd-cman.c
 	LMLIBS += $(CMAN_LIBS) $(CONFDB_LIBS) $(DLM_LIBS)
 	CFLAGS += $(CMAN_CFLAGS) $(CONFDB_CFLAGS) $(DLM_CFLAGS)
 	DEFS += -DUSE_CMAN
 endif
 
-ifeq ("$(OPENAIS)", "yes")
+ifneq (,$(findstring openais,, "@CLVMD@,"))
 	SOURCES += clvmd-openais.c
 	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(SALCK_LIBS)
 	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(SALCK_CFLAGS)
 	DEFS += -DUSE_OPENAIS
 endif
 
-ifeq ("$(COROSYNC)", "yes")
+ifneq (,$(findstring corosync,, "@CLVMD@,"))
 	SOURCES += clvmd-corosync.c
 	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
 	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
-- 
1.5.4.3


