From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 16:10:15 +0000 (UTC)
Subject: master - configure: enable building lvmlockd without sanlock or dlm
Message-ID: <20150706161015.F0A4D6106B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3605b81f36d0e534172ab376466308042142ab8
Commit:        d3605b81f36d0e534172ab376466308042142ab8
Parent:        4daea88516e39083ba52d6804c0cd398c899505d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 6 10:42:11 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 11:09:58 2015 -0500

configure: enable building lvmlockd without sanlock or dlm

---
 configure.in                         |   47 ++++++-
 daemons/lvmlockd/Makefile.in         |   23 +++-
 daemons/lvmlockd/lvmlockd-internal.h |  255 ++++++++++++++++++++++++++++------
 3 files changed, 275 insertions(+), 50 deletions(-)

diff --git a/configure.in b/configure.in
index 21ce581..9e713aa 100644
--- a/configure.in
+++ b/configure.in
@@ -40,6 +40,8 @@ case "$host_os" in
 		LVMETAD=no
 		LVMPOLLD=no
 		LVMLOCKD=no
+		LOCKDSANLOCK=no
+		LOCKDDLM=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -1175,9 +1177,44 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
 		   [Use lvmlockd by default.])
 
 ################################################################################
-dnl -- Look for sanlock and dlm libraries
-if test "$BUILD_LVMLOCKD" = yes; then
+dnl -- Build lockdsanlock
+AC_MSG_CHECKING(whether to build lockdsanlock)
+AC_ARG_ENABLE(lockd-sanlock,
+	      AC_HELP_STRING([--enable-lockd-sanlock],
+			     [enable the LVM lock daemon sanlock option]),
+	      LOCKDSANLOCK=$enableval)
+AC_MSG_RESULT($LOCKDSANLOCK)
+
+BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
+
+if test "$BUILD_LOCKDSANLOCK" = yes; then
+	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
+fi
+
+################################################################################
+dnl -- Build lockddlm
+AC_MSG_CHECKING(whether to build lockddlm)
+AC_ARG_ENABLE(lockd-dlm,
+	      AC_HELP_STRING([--enable-lockd-dlm],
+			     [enable the LVM lock daemon dlm option]),
+	      LOCKDDLM=$enableval)
+AC_MSG_RESULT($LOCKDDLM)
+
+BUILD_LOCKDDLM=$LOCKDDLM
+
+if test "$BUILD_LOCKDDLM" = yes; then
+	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
+fi
+
+################################################################################
+dnl -- Look for sanlock libraries
+if test "$BUILD_LOCKDSANLOCK" = yes; then
 	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+fi
+
+################################################################################
+dnl -- Look for dlm libraries
+if test "$BUILD_LOCKDDLM" = yes; then
 	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
 fi
 
@@ -1804,6 +1841,8 @@ AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
 AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(BUILD_LVMLOCKD)
+AC_SUBST(BUILD_LOCKDSANLOCK)
+AC_SUBST(BUILD_LOCKDDLM)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -2039,3 +2078,7 @@ AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMPOLLD" == no],
 
 AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMETAD" == no],
       [AC_MSG_WARN([lvmlockd requires lvmetad])])
+
+AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LOCKDDLM" == no && test "$BUILD_LOCKDSANLOCK" == no],
+      [AC_MSG_WARN([lvmlockd requires enabling sanlock or dlm or both])])
+
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index fcdce5c..fed7c22 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -15,10 +15,15 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SOURCES = \
-	lvmlockd-core.c \
-	lvmlockd-sanlock.c \
-	lvmlockd-dlm.c
+SOURCES = lvmlockd-core.c
+
+ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
+  SOURCES += lvmlockd-sanlock.c
+endif
+
+ifeq ("@BUILD_LOCKDDLM@", "yes")
+  SOURCES += lvmlockd-dlm.c
+endif
 
 TARGETS = lvmlockd lvmlockctl
 
@@ -29,7 +34,15 @@ include $(top_builddir)/make.tmpl
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
 
-LIBS += $(PTHREAD_LIBS) -ldlm_lt -lsanlock_client -lrt
+LIBS += $(PTHREAD_LIBS) -lrt
+
+ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
+  LIBS += -lsanlock_client
+endif
+
+ifeq ("@BUILD_LOCKDDLM@", "yes")
+  LIBS += -ldlm_lt
+endif
 
 LDFLAGS += -L$(top_builddir)/libdaemon/server
 CLDFLAGS += -L$(top_builddir)/libdaemon/server
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index f1aaa7e..9eee14a 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -198,49 +198,6 @@ struct val_blk {
 /* lm_unlock flags */
 #define LMUF_FREE_VG 0x00000001
 
-struct lockspace *alloc_lockspace(void);
-int lockspaces_empty(void);
-int last_string_from_args(char *args_in, char *last);
-int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch);
-
-int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
-int lm_prepare_lockspace_dlm(struct lockspace *ls);
-int lm_add_lockspace_dlm(struct lockspace *ls, int adopt);
-int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg);
-int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
-		uint32_t *r_version, int adopt);
-int lm_convert_dlm(struct lockspace *ls, struct resource *r,
-		   int ld_mode, uint32_t r_version);
-int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
-		  uint32_t r_version, uint32_t lmu_flags);
-int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r);
-int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
-int lm_data_size_dlm(void);
-int lm_is_running_dlm(void);
-
-int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
-int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset);
-int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r);
-int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
-int lm_prepare_lockspace_sanlock(struct lockspace *ls);
-int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt);
-int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg);
-int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
-		    uint32_t *r_version, int *retry, int adopt);
-int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
-		       int ld_mode, uint32_t r_version);
-int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
-		      uint32_t r_version, uint32_t lmu_flags);
-int lm_able_gl_sanlock(struct lockspace *ls, int enable);
-int lm_ex_disable_gl_sanlock(struct lockspace *ls);
-int lm_hosts_sanlock(struct lockspace *ls, int notify);
-int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r);
-int lm_gl_is_enabled(struct lockspace *ls);
-int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin);
-int lm_data_size_sanlock(void);
-int lm_is_running_sanlock(void);
-int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset);
-
 #define container_of(ptr, type, member) ({                      \
 	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
 	(type *)( (char *)__mptr - offsetof(type,member) );})
@@ -370,4 +327,216 @@ void log_level(int level, const char *fmt, ...)  __attribute__((format(printf, 2
 #define log_error(fmt, args...) log_level(LOG_ERR, fmt, ##args)
 #define log_warn(fmt, args...) log_level(LOG_WARNING, fmt, ##args)
 
+struct lockspace *alloc_lockspace(void);
+int lockspaces_empty(void);
+int last_string_from_args(char *args_in, char *last);
+int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch);
+
+
+#ifdef LOCKDDLM_SUPPORT
+
+int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_prepare_lockspace_dlm(struct lockspace *ls);
+int lm_add_lockspace_dlm(struct lockspace *ls, int adopt);
+int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg);
+int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
+		uint32_t *r_version, int adopt);
+int lm_convert_dlm(struct lockspace *ls, struct resource *r,
+		   int ld_mode, uint32_t r_version);
+int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
+		  uint32_t r_version, uint32_t lmu_flags);
+int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r);
+int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
+int lm_data_size_dlm(void);
+int lm_is_running_dlm(void);
+
+#else
+
+static inline int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	return -1;
+}
+
+static inline int lm_prepare_lockspace_dlm(struct lockspace *ls)
+{
+	return -1;
+}
+
+static inline int lm_add_lockspace_dlm(struct lockspace *ls, int adopt)
+{
+	return -1;
+}
+
+static inline int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg)
+{
+	return -1;
+}
+
+static inline int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
+		uint32_t *r_version, int adopt)
+{
+	return -1;
+}
+
+static inline int lm_convert_dlm(struct lockspace *ls, struct resource *r,
+		   int ld_mode, uint32_t r_version)
+{
+	return -1;
+}
+
+static inline int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
+		  uint32_t r_version, uint32_t lmu_flags)
+{
+	return -1;
+}
+
+static inline int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r)
+{
+	return -1;
+}
+
+static inline int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
+{
+	return -1;
+}
+
+static inline int lm_data_size_dlm(void)
+{
+	return -1;
+}
+
+static inline int lm_is_running_dlm(void)
+{
+	return 0;
+}
+
+#endif /* dlm support */
+
+#ifdef LOCKDSANLOCK_SUPPORT
+
+int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset);
+int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r);
+int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_prepare_lockspace_sanlock(struct lockspace *ls);
+int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt);
+int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg);
+int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
+		    uint32_t *r_version, int *retry, int adopt);
+int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
+		       int ld_mode, uint32_t r_version);
+int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
+		      uint32_t r_version, uint32_t lmu_flags);
+int lm_able_gl_sanlock(struct lockspace *ls, int enable);
+int lm_ex_disable_gl_sanlock(struct lockspace *ls);
+int lm_hosts_sanlock(struct lockspace *ls, int notify);
+int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r);
+int lm_gl_is_enabled(struct lockspace *ls);
+int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin);
+int lm_data_size_sanlock(void);
+int lm_is_running_sanlock(void);
+int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset);
+
+#else
+
+static inline int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	return -1;
+}
+
+static inline int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset)
+{
+	return -1;
+}
+
+static inline int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r)
+{
+	return -1;
+}
+
+static inline int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	return -1;
+}
+
+static inline int lm_prepare_lockspace_sanlock(struct lockspace *ls)
+{
+	return -1;
+}
+
+static inline int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt)
+{
+	return -1;
+}
+
+static inline int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
+{
+	return -1;
+}
+
+static inline int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
+		    uint32_t *r_version, int *retry, int adopt)
+{
+	return -1;
+}
+
+static inline int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
+		       int ld_mode, uint32_t r_version)
+{
+	return -1;
+}
+
+static inline int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
+		      uint32_t r_version, uint32_t lmu_flags)
+{
+	return -1;
+}
+
+static inline int lm_able_gl_sanlock(struct lockspace *ls, int enable)
+{
+	return -1;
+}
+
+static inline int lm_ex_disable_gl_sanlock(struct lockspace *ls)
+{
+	return -1;
+}
+
+static inline int lm_hosts_sanlock(struct lockspace *ls, int notify)
+{
+	return -1;
+}
+
+static inline int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r)
+{
+	return -1;
+}
+
+static inline int lm_gl_is_enabled(struct lockspace *ls)
+{
+	return -1;
+}
+
+static inline int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin)
+{
+	return -1;
+}
+
+static inline int lm_data_size_sanlock(void)
+{
+	return -1;
+}
+
+static inline int lm_is_running_sanlock(void)
+{
+	return 0;
+}
+
+static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
+{
+	return -1;
+}
+
+#endif /* sanlock support */
+
 #endif	/* _LVM_LVMLOCKD_INTERNAL_H */


