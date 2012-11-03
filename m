From: Jacek Konieczny <jajcus@jajcus.net>
Date: Sat,  3 Nov 2012 19:38:40 +0100
Subject: [PATCH] sd_notify(3) support in clvmd
In-Reply-To: <1351967920-14881-1-git-send-email-jajcus@jajcus.net>
References: <1351967920-14881-1-git-send-email-jajcus@jajcus.net>
Message-ID: <1351967920-14881-2-git-send-email-jajcus@jajcus.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use sd_notify() function from the libsystemd-daemon library to
report startup progress of clvmd.

This fearture can be disabled via the configure script.

Signed-off-by: Jacek Konieczny <jajcus@jajcus.net>
---
 configure.in              |   28 ++++++++++++++++++++++++++++
 daemons/clvmd/Makefile.in |    7 +++++++
 daemons/clvmd/clvmd.c     |   32 ++++++++++++++++++++++++++++++++
 lib/misc/configure.h.in   |    3 +++
 4 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index 75e0d84..7cb7664 100644
--- a/configure.in
+++ b/configure.in
@@ -757,6 +757,34 @@ if test "x$CLVMD" != xnone; then
 fi
 
 ################################################################################
+dnl -- Disable sd_notify
+AC_MSG_CHECKING(whether to enable sd_notify)
+AC_ARG_ENABLE([sd_notify],
+	      AC_HELP_STRING([--disable-sd-notify], 
+	      [disable sd_notify support in clvmd]),
+	      [SD_NOTIFY=$enableval], [SD_NOTIFY=auto])
+AC_MSG_RESULT($SD_NOTIFY)
+
+if test x$SD_NOTIFY != xno ; then
+	if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+	PKG_CHECK_MODULES([LIBSYSTEMD_DAEMON], [libsystemd-daemon],
+		[SD_NOTIFY=yes], [
+		   	if test x$SD_NOTIFY = yes ; then
+				AC_MSG_ERROR([bailing out])
+			else
+				SD_NOTIFY=no
+			fi
+		])
+fi
+AC_SUBST([SD_NOTIFY])
+if test x$SD_NOTIFY = xyes; then
+	AC_DEFINE([ENABLE_SD_NOTIFY], [1],
+		  [Define to 1 to include sd_notify() support in clvmd])
+fi
+
+################################################################################
 dnl -- Build cluster mirror log daemon
 AC_MSG_CHECKING(whether to build cluster mirror log daemon)
 AC_ARG_ENABLE(cmirrord,
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 9ca11ba..a81f52e 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -29,6 +29,8 @@ QUORUM_LIBS = @QUORUM_LIBS@
 QUORUM_CFLAGS = @QUORUM_CFLAGS@
 SALCK_LIBS = @SALCK_LIBS@
 SALCK_CFLAGS = @SALCK_CFLAGS@
+LIBSYSTEMD_DAEMON_LIBS = @LIBSYSTEMD_DAEMON_LIBS@
+LIBSYSTEMD_DAEMON_CFLAGS = @LIBSYSTEMD_DAEMON_CFLAGS@
 
 SOURCES = \
 	clvmd-command.c  \
@@ -81,6 +83,11 @@ LVMLIBS = $(LVMINTERNAL_LIBS)
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
 endif
+
+ifeq ("@SD_NOTIFY@", "yes")
+	LMLIBS += $(LIBSYSTEMD_DAEMON_LIBS)
+	CFLAGS += $(LIBSYSTEMD_DAEMON_CFLAGS)
+endif
  
 include $(top_builddir)/make.tmpl
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index eb0bffd..dd2ab6b 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -41,6 +41,10 @@
 #include <sys/un.h>
 #include <sys/utsname.h>
 
+#ifdef ENABLE_SD_NOTIFY
+#include <systemd/sd-daemon.h>
+#endif
+
 #ifndef TRUE
 #define TRUE 1
 #endif
@@ -483,6 +487,9 @@ int main(int argc, char *argv[])
 	   but the cluster is not ready yet */
 	local_sock = open_local_sock();
 	if (local_sock < 0) {
+#ifdef ENABLE_SD_NOTIFY
+		sd_notify(0, "STATUS=clvmd could not create local socket");
+#endif
 		child_init_signal_and_exit(DFAIL_LOCAL_SOCK);
 		/* NOTREACHED */
 	}
@@ -514,6 +521,10 @@ int main(int argc, char *argv[])
 	pthread_barrier_init(&lvm_start_barrier, NULL, 2);
 	init_lvhash();
 
+#ifdef ENABLE_SD_NOTIFY
+	sd_notify(0, "STATUS=Starting the cluster interface");
+#endif
+
 	/* Start the cluster interface */
 	if (cluster_iface == IF_AUTO)
 		cluster_iface = get_cluster_type();
@@ -557,10 +568,16 @@ int main(int argc, char *argv[])
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
 		log_error("Can't initialise cluster interface\n");
+#ifdef ENABLE_SD_NOTIFY
+		sd_notify(0, "STATUS=Can't initialise cluster interface");
+#endif
 		child_init_signal_and_exit(DFAIL_CLUSTER_IF);
 		/* NOTREACHED */
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
+#ifdef ENABLE_SD_NOTIFY
+	sd_notify(0, "STATUS=Cluster ready, doing some more initialisation");
+#endif
 
 	/* Save our CSID */
 	clops->get_our_csid(our_csid);
@@ -573,6 +590,9 @@ int main(int argc, char *argv[])
 	/* Add the local socket to the list */
 	newfd = malloc(sizeof(struct local_client));
 	if (!newfd) {
+#ifdef ENABLE_SD_NOTIFY
+		sd_notify(0, "STATUS=clvmd failed, not enough memory");
+#endif
 		child_init_signal_and_exit(DFAIL_MALLOC);
 		/* NOTREACHED */
 	}
@@ -599,6 +619,9 @@ int main(int argc, char *argv[])
 		clops->cluster_init_completed();
 
 	DEBUGLOG("clvmd ready for work\n");
+#ifdef ENABLE_SD_NOTIFY
+	sd_notify(0, "READY=1\nSTATUS=clvmd ready for work");
+#endif
 	child_init_signal(SUCCESS);
 
 	/* Try to shutdown neatly */
@@ -608,6 +631,10 @@ int main(int argc, char *argv[])
 	/* Do some work */
 	main_loop(local_sock, cmd_timeout);
 
+#ifdef ENABLE_SD_NOTIFY
+	sd_notify(0, "STATUS=Shutting down");
+#endif
+
 	pthread_mutex_lock(&lvm_thread_mutex);
 	pthread_cond_signal(&lvm_thread_cond);
 	pthread_mutex_unlock(&lvm_thread_mutex);
@@ -632,6 +659,11 @@ int main(int argc, char *argv[])
 	}
 
 	ret = 0;
+
+#ifdef ENABLE_SD_NOTIFY
+	sd_notify(0, "STATUS=Finished");
+#endif
+
 out:
 	dm_hash_destroy(lvm_params.excl_uuid);
 
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index fdc5a26..5a78f80 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -77,6 +77,9 @@
 /* Library version */
 #undef DM_LIB_VERSION
 
+/* Define to 1 to include sd_notify() support in clvmd */
+#undef ENABLE_SD_NOTIFY
+
 /* Define to 1 if you have `alloca', as a function or macro. */
 #undef HAVE_ALLOCA
 
-- 
1.7.7.4


