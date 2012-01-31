From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Tue, 31 Jan 2012 12:15:57 +0100
Subject: [PATCH] clvmd: port to new corosync >= 2.0
Message-ID: <1328008557-19291-1-git-send-email-fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "Fabio M. Di Nitto" <fdinitto@redhat.com>

configure.in: update to check for libcmap/libconfdb

daemons/clvmd/Makefile.in: propagate CMAP_LDFLAGS/CMAP_CFLAGS

lib/misc/configure.h.in: autoupdated

daemons/clvmd/clvmd-corosync.c:
 - update to use new libquorum init api
 - use either confdb or cmap as necessary
   NOTE that the new cluster_name is defined in corosync.conf

totem {
  cluster_name: foobar
}

tested using corosync 1.99.1 (2.0 beta release) and dlm from
http://people.redhat.com/teigland/dlm-3.99.0-1.fc15.src.rpm

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
 configure.in                   |   39 +++++++++++++++++++++++++----
 daemons/clvmd/Makefile.in      |    6 +++-
 daemons/clvmd/clvmd-corosync.c |   53 ++++++++++++++++++++++++++++++++++++++++
 lib/misc/configure.h.in        |    3 ++
 4 files changed, 93 insertions(+), 8 deletions(-)

diff --git a/configure.in b/configure.in
index 96b5f51..e7c4c7e 100644
--- a/configure.in
+++ b/configure.in
@@ -549,6 +549,7 @@ if test x$BUILDCOROSYNC = xyes || \
    test x$BUILDOPENAIS = xyes; then
 	PKG_CHECK_MODULES(COROSYNC, corosync, [HAVE_COROSYNC=yes], $bailout)
 	CHECKCONFDB=yes
+	CHECKCMAP=yes
 fi
 
 dnl -- Look for corosync libraries if required.
@@ -567,7 +568,7 @@ fi
 dnl -- Below are checks for libraries common to more than one build.
 
 dnl -- Check confdb library.
-dnl -- mandatory for corosync build.
+dnl -- mandatory for corosync < 2.0 build.
 dnl -- optional for openais/cman build.
 
 if test x$CHECKCONFDB = xyes; then
@@ -586,11 +587,34 @@ if test x$CHECKCONFDB = xyes; then
 		CONFDB_LIBS="-lconfdb"
 		HAVE_CONFDB=yes
 	fi
+fi
+
+dnl -- Check cmap library
+dnl -- mandatory for corosync >= 2.0 build.
+
+if test x$CHECKCMAP = xyes; then
+	PKG_CHECK_MODULES(CMAP, libcmap,
+			  [HAVE_CMAP=yes],
+			  [HAVE_CMAP=no])
 
-	if test x$BUILDCOROSYNC = xyes && \
-	   test x$HAVE_CONFDB != xyes &&
+	AC_CHECK_HEADERS(corosync/cmap.h,
+		[HAVE_CMAP_H=yes],
+		[HAVE_CMAP_H=no])
+
+	if test x$HAVE_CMAP != xyes && \ 
+	   test x$HAVE_CMAP_H = xyes; then
+		check_lib_no_libs cmap cmap_initialize
+		AC_MSG_RESULT([no pkg for cmap, using -lcmap])
+		CMAP_LIBS="-lcmap"
+		HAVE_CMAP=yes
+	fi
+fi
+
+if test x$BUILDCOROSYNC = xyes; then
+	if test x$HAVE_CMAP != xyes && \
+	   test x$HAVE_CONFDB != xyes && \
 	   test x$CLVMD != xall; then
-		AC_MSG_ERROR([bailing out... confdb library is required])
+		AC_MSG_ERROR([bailing out... cmap (corsync >= 2.0) or confdb (corosync < 2.0) library is required])
 	fi
 fi
 
@@ -629,11 +653,12 @@ if test x$CLVMD = xall; then
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_QUORUM = xyes && \
 	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_DLM = xyes && \
-	   test x$HAVE_CONFDB = xyes; then
+	   test x$HAVE_DLM = xyes; then
+	   if test x$HAVE_CONFDB = xyes || test x$HAVE_CMAP = xyes; then
 		AC_MSG_RESULT([Enabling clvmd corosync cluster manager])
 		CLVMD="$CLVMD,corosync"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
+	   fi
 	fi
 	if test x$HAVE_COROSYNC = xyes && \
 	   test x$HAVE_CPG = xyes && \
@@ -1311,6 +1336,8 @@ AC_SUBST(CLVMD_CMANAGERS)
 AC_SUBST(CLVMD_PATH)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
+AC_SUBST(CMAP_CFLAGS)
+AC_SUBST(CMAP_LIBS)
 AC_SUBST(CMDLIB)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index dcdabab..9ca11ba 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -17,6 +17,8 @@ top_builddir = @top_builddir@
 
 CMAN_LIBS = @CMAN_LIBS@
 CMAN_CFLAGS = @CMAN_CFLAGS@
+CMAP_LIBS = @CMAP_LIBS@
+CMAP_CFLAGS = @CMAP_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
@@ -54,8 +56,8 @@ endif
 
 ifneq (,$(findstring corosync,, "@CLVMD@,"))
 	SOURCES += clvmd-corosync.c
-	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
-	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
+	LMLIBS += $(CMAP_LIBS) $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
+	CFLAGS += $(CMAP_CFLAGS) $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
 	DEFS += -DUSE_COROSYNC
 endif
 
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index e929681..6bd9500 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -30,7 +30,12 @@
 
 #include <corosync/cpg.h>
 #include <corosync/quorum.h>
+#ifdef HAVE_COROSYNC_CONFDB_H
 #include <corosync/confdb.h>
+#endif
+#ifdef HAVE_COROSYNC_CMAP_H
+#include <corosync/cmap.h>
+#endif
 #include <libdlm.h>
 
 #include <syslog.h>
@@ -273,6 +278,10 @@ static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 static int _init_cluster(void)
 {
 	cs_error_t err;
+/* defined by new corosync/quorum.h header */
+#ifdef QUORUM_SET
+	uint32_t quorum_type;
+#endif
 
 	node_hash = dm_hash_create(100);
 
@@ -285,8 +294,20 @@ static int _init_cluster(void)
 		return cs_to_errno(err);
 	}
 
+#ifdef QUORUM_SET
+	err = quorum_initialize(&quorum_handle,
+				&quorum_callbacks,
+				&quorum_type);
+
+	if (quorum_type != QUORUM_SET) {
+		syslog(LOG_ERR, "Corosync quorum service is not configured");
+		DEBUGLOG("Corosync quorum service is not configured");
+		return EINVAL;
+	}
+#else
 	err = quorum_initialize(&quorum_handle,
 				&quorum_callbacks);
+#endif
 	if (err != CS_OK) {
 		syslog(LOG_ERR, "Cannot initialise Corosync quorum service: %d",
 		       err);
@@ -558,6 +579,7 @@ static int _cluster_send_message(const void *buf, int msglen, const char *csid,
  * dependancies as well as to allow people to set a cluster name
  * for themselves even if they are not running on RH cluster.
  */
+#ifdef HAVE_COROSYNC_CONFDB_H
 static int _get_cluster_name(char *buf, int buflen)
 {
 	confdb_handle_t handle;
@@ -596,6 +618,37 @@ out:
 	confdb_finalize(handle);
 	return 0;
 }
+#endif
+
+#ifdef HAVE_COROSYNC_CMAP_H
+static int _get_cluster_name(char *buf, int buflen)
+{
+	cmap_handle_t cmap_handle = 0;
+	int result;
+	char *name = NULL;
+
+	/* This is a default in case everything else fails */
+	strncpy(buf, "Corosync", buflen);
+
+	/* Look for a cluster name in cmap */
+	result = cmap_initialize(&cmap_handle);
+	if (result != CS_OK)
+		return 0;
+
+	result = cmap_get_string(cmap_handle, "totem.cluster_name", &name);
+	if (result != CS_OK)
+		goto out;
+
+	memset(buf, 0, buflen);
+	strncpy(buf, name, buflen);
+
+out:
+	if (name)
+		free(name);
+	cmap_finalize(cmap_handle);
+	return 0;
+}
+#endif
 
 static struct cluster_ops _cluster_corosync_ops = {
 	.name                     = "corosync",
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 707445a..1c86c15 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -87,6 +87,9 @@
 /* Define to 1 if your system has a working `chown' function. */
 #undef HAVE_CHOWN
 
+/* Define to 1 if you have the <corosync/cmap.h> header file. */
+#undef HAVE_COROSYNC_CMAP_H
+
 /* Define to 1 if you have the <corosync/confdb.h> header file. */
 #undef HAVE_COROSYNC_CONFDB_H
 
-- 
1.7.7.6


