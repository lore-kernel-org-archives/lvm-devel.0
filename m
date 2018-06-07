From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:12 -0400
Subject: master - scripts/lvm2_activation_generator_systemd_red_hat: rewrite to use lvmconfig
Message-ID: <201806071521.w57FLCw1012770@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd8c6cf8628e5898ea89ebbcccfe423dba83a840
Commit:        bd8c6cf8628e5898ea89ebbcccfe423dba83a840
Parent:        74460cd009267564be032a373e78ec5eba67b4ce
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jun 7 16:15:04 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:15:04 2018 +0100

scripts/lvm2_activation_generator_systemd_red_hat: rewrite to use lvmconfig

Unit tested the new code, but not run functional tests (assuming they exist).
---
 configure.ac                                       |    3 +
 scripts/Makefile.in                                |   16 +--
 scripts/generator-internals.c                      |  200 +++++++++++++++++
 .../lvm2_activation_generator_systemd_red_hat.c    |  232 ++++++++++++--------
 test/unit/Makefile.in                              |    6 +-
 test/unit/units.h                                  |    2 +
 6 files changed, 348 insertions(+), 111 deletions(-)

diff --git a/configure.ac b/configure.ac
index 67f2462..365df25 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1533,6 +1533,9 @@ SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
+LVMCONFIG_PATH="$$BINDIR/lvmconfig"
+AC_DEFINE_UNQUOTED(LVMCONFIG_PATH, ["$LVMCONFIG_PATH"], [Path to lvmconfig binary.])
+
 USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 
 FSADM_PATH="$SBINDIR/fsadm"
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ee39306..208aebf 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -15,21 +15,14 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-ifeq ("@APPLIB@", "yes")
-	SOURCES = lvm2_activation_generator_systemd_red_hat.c
-	TARGETS = lvm2_activation_generator_systemd_red_hat
-endif
+SOURCES = lvm2_activation_generator_systemd_red_hat.c
+TARGETS = lvm2_activation_generator_systemd_red_hat
 
 include $(top_builddir)/make.tmpl
 
-ifeq ("@APPLIB@", "yes")
-	DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so
-	LDFLAGS += -L$(top_builddir)/liblvm
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	LDFLAGS += -Wl,-rpath-link,$(top_builddir)/daemons/dmeventd
 endif
-	LVMLIBS = @LVM2APP_LIB@ -laio
-endif
 
 LVM_SCRIPTS = lvmdump.sh lvmconf.sh
 DM_SCRIPTS =
@@ -93,12 +86,7 @@ lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(INTERNAL_LIBS
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)
-ifeq ("@APPLIB@", "yes")
 	$(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
-else
-	@echo "WARNING: LVM2 activation systemd generator not installed." \
-	      "It requires the LVM2 application library to be built as well."
-endif
 
 install_systemd_units:	install_dbus_service
 	$(INSTALL_DIR) $(systemd_unit_dir)
diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
new file mode 100644
index 0000000..c38323b
--- /dev/null
+++ b/scripts/generator-internals.c
@@ -0,0 +1,200 @@
+// This file contains the unit testable parts of
+// lvm2_activation_generator_systemd_red_hat
+
+#include <ctype.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>		/* For PATH_MAX for musl libc */
+#include <stdarg.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <syslog.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <unistd.h>
+
+//----------------------------------------------------------------
+
+static void _error(const char *format, ...) __attribute__ ((format(printf, 1, 2)));
+
+//----------------------------------------------------------------
+
+// I'm rolling my own version of popen() here because I do not want to
+// go through the shell.
+
+struct child_process {
+	pid_t pid;
+	FILE *fp;
+};
+
+static bool _open_child(struct child_process *child, const char *cmd, const char *argv[])
+{
+	int r, pipe_fd[2];
+
+	r = pipe(pipe_fd);
+	if (r < 0) {
+		_error("call to pipe() failed: %d\n", r);
+		return false;
+	}
+
+	child->pid = fork();
+	if (child->pid < 0) {
+		close(pipe_fd[0]);
+		close(pipe_fd[1]);
+		_error("call to fork() failed: %d\n", r);
+		return false;
+	}
+
+	if (child->pid == 0) {
+		// child
+		close(pipe_fd[0]);
+		if (pipe_fd[1] != STDOUT_FILENO) {
+			dup2(pipe_fd[1], STDOUT_FILENO);
+			close(pipe_fd[1]);
+		}
+
+		execv(cmd, (char *const *) argv);
+		// Shouldn't get here unless exec failed.
+		exit(1);
+	} else {
+		// parent
+		close(pipe_fd[1]);
+		child->fp = fdopen(pipe_fd[0], "r");
+		if (!child->fp) {
+			_error("call to fdopen() failed\n");
+			return false;
+		}
+	}
+
+	return true;
+}
+
+// Returns the child's exit status
+static bool _close_child(struct child_process *child)
+{
+	int status;
+
+	fclose(child->fp);
+
+	while (waitpid(child->pid, &status, 0) < 0)
+		if (errno != EINTR)
+			return -1;
+
+	if (WIFEXITED(status) && !WEXITSTATUS(status))
+		return true;
+
+	return false;
+}
+
+//----------------------------------------------------------------
+// Aquiring config from the lvmconfig process
+
+#define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
+#define LVM_CONF_USE_LVMPOLLD	"global/use_lvmpolld"
+
+struct config {
+	bool use_lvmetad;
+	bool sysinit_needed;
+};
+
+static bool _begins_with(const char *line, const char *prefix, const char **rest)
+{
+	size_t len = strlen(prefix);
+
+	if (strlen(line) < len)
+		return false;
+
+	if (strncmp(line, prefix, len))
+		return false;
+
+	*rest = line + len;
+
+	return true;
+}
+
+static bool _parse_bool(const char *val, bool * result)
+{
+	const char *b = val, *e;
+
+	while (*b && isspace(*b))
+		b++;
+
+	if (!*b)
+		goto parse_error;
+
+	e = b;
+	while (*e && !isspace(*e))
+		e++;
+
+	if ((e - b) != 1)
+		goto parse_error;
+
+	// We only handle '1', or '0'
+	if (*b == '1') {
+		*result = true;
+		return true;
+
+	} else if (*b == '0') {
+		*result = false;
+		return true;
+	}
+	// Fallthrough
+
+ parse_error:
+	_error("couldn't parse bool value '%s'\n", val);
+	return false;
+}
+
+static bool _parse_line(const char *line, struct config *cfg)
+{
+	const char *val;
+
+	if (_begins_with(line, "use_lvmetad=", &val)) {
+		return _parse_bool(val, &cfg->use_lvmetad);
+
+	} else if (_begins_with(line, "use_lvmpolld=", &val)) {
+		bool r;
+		if (!_parse_bool(val, &r))
+			return false;
+		cfg->sysinit_needed = !r;
+		return true;
+	}
+
+	return false;
+}
+
+static bool _get_config(struct config *cfg, const char *lvmconfig_path)
+{
+	static const char *_argv[] = {
+		"lvmconfig", LVM_CONF_USE_LVMETAD, LVM_CONF_USE_LVMPOLLD, NULL
+	};
+
+	bool r = true;
+	char buffer[256];
+	struct child_process child;
+
+	cfg->use_lvmetad = false;
+	cfg->sysinit_needed = true;
+
+	if (!_open_child(&child, lvmconfig_path, _argv)) {
+		_error("couldn't open lvmconfig process\n");
+		return false;
+	}
+
+	while (fgets(buffer, sizeof(buffer), child.fp)) {
+		if (!_parse_line(buffer, cfg)) {
+			_error("_parse_line() failed\n");
+			r = false;
+		}
+	}
+
+	if (!_close_child(&child)) {
+		_error("lvmconfig failed\n");
+		r = false;
+	}
+
+	return r;
+}
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 551b29a..9ba1996 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -12,106 +12,139 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
 
-#include <stdio.h>
-#include <unistd.h>
+#include <ctype.h>
 #include <errno.h>
+#include <fcntl.h>
+#include <limits.h>		/* For PATH_MAX for musl libc */
 #include <stdarg.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <string.h>
 #include <syslog.h>
-#include <sys/types.h>
 #include <sys/stat.h>
-#include <fcntl.h>
-#include <limits.h>		/* For PATH_MAX for musl libc */
-#include "liblvm/lvm2app.h"
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <unistd.h>
+
 #include "configure.h"
+#include "device_mapper/libdevmapper.h"
 
-#define KMSG_DEV_PATH		"/dev/kmsg"
-#define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
-#define LVM_CONF_USE_LVMPOLLD	"global/use_lvmpolld"
+//----------------------------------------------------------------
 
-#define UNIT_TARGET_LOCAL_FS  "local-fs-pre.target"
-#define UNIT_TARGET_REMOTE_FS "remote-fs-pre.target"
+// Code in this file gets included in the unit tests.
+#include "generator-internals.c"
 
-static char unit_path[PATH_MAX];
-static char target_path[PATH_MAX];
-static char message[PATH_MAX + 3]; /* +3 for '<n>' where n is the log level */
-static int kmsg_fd = -1;
+//----------------------------------------------------------------
+// Logging
 
-enum {
-	UNIT_EARLY,
-	UNIT_MAIN,
-	UNIT_NET
-};
+#define KMSG_DEV_PATH		"/dev/kmsg"
+static int _kmsg_fd;
 
-static const char *unit_names[] = {
-	[UNIT_EARLY] = "lvm2-activation-early.service",
-	[UNIT_MAIN] = "lvm2-activation.service",
-	[UNIT_NET] = "lvm2-activation-net.service"
-};
+static void _log_init(void)
+{
+	// failing is harmless
+	_kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY | O_NOCTTY);
+}
 
-__attribute__ ((format(printf, 2, 3)))
-static void kmsg(int log_level, const char *format, ...)
+static void _log_exit(void)
+{
+	if (_kmsg_fd != -1)
+		(void) close(_kmsg_fd);
+}
+
+__attribute__ ((format(printf, 1, 2)))
+static void _error(const char *format, ...)
 {
-	va_list ap;
 	int n;
+	va_list ap;
+	char message[PATH_MAX + 3];	/* +3 for '<n>' where n is the log level */
 
-	snprintf(message, 4, "<%d>", log_level);
+	snprintf(message, 4, "<%d>", LOG_ERR);
 
 	va_start(ap, format);
 	n = vsnprintf(message + 3, PATH_MAX, format, ap);
 	va_end(ap);
 
-	if (kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > PATH_MAX)))
+	if (_kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > PATH_MAX)))
 		return;
 
 	/* The n+4: +3 for "<n>" prefix and +1 for '\0' suffix */
-	if (write(kmsg_fd, message, n + 4)) { /* Ignore result code */; }
+	(void) write(_kmsg_fd, message, n + 4);
 }
 
-static void lvm_get_use_lvmetad_and_lvmpolld(int *use_lvmetad, int *use_lvmpolld)
-{
-	*use_lvmetad = *use_lvmpolld = 0;
+//----------------------------------------------------------------
 
-	*use_lvmetad = lvm_config_find_bool(NULL, LVM_CONF_USE_LVMETAD, 0);
-	*use_lvmpolld = lvm_config_find_bool(NULL, LVM_CONF_USE_LVMPOLLD, 0);
-}
+#define UNIT_TARGET_LOCAL_FS  "local-fs-pre.target"
+#define UNIT_TARGET_REMOTE_FS "remote-fs-pre.target"
+
+struct generator {
+	const char *dir;
+	struct config cfg;
 
-static int register_unit_with_target(const char *dir, const char *unit, const char *target)
+	int kmsg_fd;
+	char unit_path[PATH_MAX];
+	char target_path[PATH_MAX];
+};
+
+enum {
+	UNIT_EARLY,
+	UNIT_MAIN,
+	UNIT_NET
+};
+
+static const char *_unit_names[] = {
+	[UNIT_EARLY] = "lvm2-activation-early.service",
+	[UNIT_MAIN] = "lvm2-activation.service",
+	[UNIT_NET] = "lvm2-activation-net.service"
+};
+
+//----------------------------------------------------------------
+
+static int register_unit_with_target(struct generator *gen, const char *unit,
+				     const char *target)
 {
 	int r = 1;
 
-	if (dm_snprintf(target_path, PATH_MAX, "%s/%s.wants", dir, target) < 0) {
-		r = 0; goto out;
+	if (dm_snprintf(gen->target_path, PATH_MAX, "%s/%s.wants", gen->dir, target) < 0) {
+		r = 0;
+		goto out;
 	}
-	(void) dm_prepare_selinux_context(target_path, S_IFDIR);
-	if (mkdir(target_path, 0755) < 0 && errno != EEXIST) {
-		kmsg(LOG_ERR, "LVM: Failed to create target directory %s: %m.\n", target_path);
-		r = 0; goto out;
+
+	(void) dm_prepare_selinux_context(gen->target_path, S_IFDIR);
+	if (mkdir(gen->target_path, 0755) < 0 && errno != EEXIST) {
+		_error("LVM: Failed to create target directory %s: %m.\n", gen->target_path);
+		r = 0;
+		goto out;
 	}
 
-	if (dm_snprintf(target_path, PATH_MAX, "%s/%s.wants/%s", dir, target, unit) < 0) {
-		r = 0; goto out;
+	if (dm_snprintf
+	    (gen->target_path, PATH_MAX, "%s/%s.wants/%s", gen->dir, target, unit) < 0) {
+		r = 0;
+		goto out;
 	}
-	(void) dm_prepare_selinux_context(target_path, S_IFLNK);
-	if (symlink(unit_path, target_path) < 0) {
-		kmsg(LOG_ERR, "LVM: Failed to create symlink for unit %s: %m.\n", unit);
+	(void) dm_prepare_selinux_context(gen->target_path, S_IFLNK);
+	if (symlink(gen->unit_path, gen->target_path) < 0) {
+		_error("LVM: Failed to create symlink for unit %s: %m.\n", unit);
 		r = 0;
 	}
-out:
+ out:
 	dm_prepare_selinux_context(NULL, 0);
 	return r;
 }
 
-static int generate_unit(const char *dir, int unit, int sysinit_needed)
+static int generate_unit(struct generator *gen, int unit)
 {
 	FILE *f;
-	const char *unit_name = unit_names[unit];
-	const char *target_name = unit == UNIT_NET ? UNIT_TARGET_REMOTE_FS : UNIT_TARGET_LOCAL_FS;
+	const char *unit_name = _unit_names[unit];
+	const char *target_name =
+	    unit == UNIT_NET ? UNIT_TARGET_REMOTE_FS : UNIT_TARGET_LOCAL_FS;
 
-	if (dm_snprintf(unit_path, PATH_MAX, "%s/%s", dir, unit_name) < 0)
+	if (dm_snprintf(gen->unit_path, PATH_MAX, "%s/%s", gen->dir, unit_name)
+	    < 0)
 		return 0;
 
-	if (!(f = fopen(unit_path, "wxe"))) {
-		kmsg(LOG_ERR, "LVM: Failed to create unit file %s: %m.\n", unit_name);
+	if (!(f = fopen(gen->unit_path, "wxe"))) {
+		_error("LVM: Failed to create unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
@@ -124,79 +157,90 @@ static int generate_unit(const char *dir, int unit, int sysinit_needed)
 	      "[Unit]\n"
 	      "Description=Activation of LVM2 logical volumes\n"
 	      "Documentation=man:lvm2-activation-generator(8)\n"
-	      "SourcePath=/etc/lvm/lvm.conf\n"
-	      "DefaultDependencies=no\n", f);
+	      "SourcePath=/etc/lvm/lvm.conf\n" "DefaultDependencies=no\n", f);
 
 	if (unit == UNIT_NET) {
 		fprintf(f, "After=%s iscsi.service fcoe.service\n"
 			"Before=remote-fs-pre.target shutdown.target\n\n"
 			"[Service]\n"
-			"ExecStartPre=/usr/bin/udevadm settle\n", unit_names[UNIT_MAIN]);
+			"ExecStartPre=/usr/bin/udevadm settle\n", _unit_names[UNIT_MAIN]);
 	} else {
-		if (unit == UNIT_EARLY) {
+		if (unit == UNIT_EARLY)
 			fputs("After=systemd-udev-settle.service\n"
 			      "Before=cryptsetup.target\n", f);
-		} else
-			fprintf(f, "After=%s cryptsetup.target\n", unit_names[UNIT_EARLY]);
+		else
+			fprintf(f, "After=%s cryptsetup.target\n", _unit_names[UNIT_EARLY]);
 
 		fputs("Before=local-fs-pre.target shutdown.target\n"
-		      "Wants=systemd-udev-settle.service\n\n"
-		      "[Service]\n", f);
+		      "Wants=systemd-udev-settle.service\n\n" "[Service]\n", f);
 	}
 
 	fputs("ExecStart=" LVM_PATH " vgchange -aay --ignoreskippedcluster", f);
-	if (sysinit_needed)
-		fputs (" --sysinit", f);
+	if (gen->cfg.sysinit_needed)
+		fputs(" --sysinit", f);
 	fputs("\nType=oneshot\n", f);
 
 	if (fclose(f) < 0) {
-		kmsg(LOG_ERR, "LVM: Failed to write unit file %s: %m.\n", unit_name);
+		_error("LVM: Failed to write unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
-	if (!register_unit_with_target(dir, unit_name, target_name)) {
-		kmsg(LOG_ERR, "LVM: Failed to register unit %s with target %s.\n", unit_name, target_name);
+	if (!register_unit_with_target(gen, unit_name, target_name)) {
+		_error("LVM: Failed to register unit %s with target %s.\n",
+		       unit_name, target_name);
 		return 0;
 	}
 
 	return 1;
 }
 
-int main(int argc, char *argv[])
+static bool _parse_command_line(struct generator *gen, int argc, const char **argv)
 {
-	int use_lvmetad, use_lvmpolld, sysinit_needed;
-	const char *dir;
-	int r = EXIT_SUCCESS;
-	mode_t old_mask;
-
-	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY);
-
 	if (argc != 4) {
-		kmsg(LOG_ERR, "LVM: Incorrect number of arguments for activation generator.\n");
-		r = EXIT_FAILURE; goto out;
+		_error("LVM: Incorrect number of arguments for activation generator.\n");
+		return false;
 	}
 
-	/* If lvmetad used, rely on autoactivation instead of direct activation. */
-	lvm_get_use_lvmetad_and_lvmpolld(&use_lvmetad, &use_lvmpolld);
-	if (use_lvmetad)
-		goto out;
+	gen->dir = argv[1];
+	return true;
+}
+
+static bool _run(int argc, const char **argv)
+{
+	bool r;
+	mode_t old_mask;
+	struct generator gen;
+
+	if (!_parse_command_line(&gen, argc, argv))
+		return false;
+
+	if (!_get_config(&gen.cfg, LVMCONFIG_PATH))
+		return false;
 
-	dir = argv[1];
+	if (gen.cfg.use_lvmetad)
+		// If lvmetad used, rely on autoactivation instead of direct activation.
+		return true;
 
 	/* mark lvm2-activation.*.service as world-accessible */
 	old_mask = umask(0022);
 
-	sysinit_needed = !use_lvmpolld;
+	r = generate_unit(&gen, UNIT_EARLY) &&
+	    generate_unit(&gen, UNIT_MAIN) && generate_unit(&gen, UNIT_NET);
 
-	if (!generate_unit(dir, UNIT_EARLY, sysinit_needed) ||
-	    !generate_unit(dir, UNIT_MAIN, sysinit_needed) ||
-	    !generate_unit(dir, UNIT_NET, sysinit_needed))
-		r = EXIT_FAILURE;
 	umask(old_mask);
-out:
-	if (r)
-		kmsg(LOG_ERR, "LVM: Activation generator failed.\n");
-	if (kmsg_fd != -1)
-		(void) close(kmsg_fd);
+
 	return r;
 }
+
+int main(int argc, const char **argv)
+{
+	bool r;
+
+	_log_init();
+	r = _run(argc, argv);
+	if (!r)
+		_error("LVM: Activation generator failed.\n");
+	_log_exit();
+
+	return r ? EXIT_SUCCESS : EXIT_FAILURE;
+}
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 994968c..e7cc852 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -14,6 +14,7 @@ UNIT_SOURCE=\
 	base/data-struct/radix-tree.c \
 	device_mapper/vdo/status.c \
 	\
+	test/unit/activation-generator_t.c \
 	test/unit/bcache_t.c \
 	test/unit/bcache_utils_t.c \
 	test/unit/bitset_t.c \
@@ -32,12 +33,11 @@ UNIT_SOURCE=\
 UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
 UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
 CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
-UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -laio
 
-test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a $(INTERNAL_LIBS)
+test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(UNIT_LDLIBS) -lm
+	      -o $@ $+ $(LIBS) -lm -ldl -laio
 
 .PHONEY: run-unit-test
 run-unit-test: test/unit/unit-test
diff --git a/test/unit/units.h b/test/unit/units.h
index d7ac6ad..bc0db8d 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -20,6 +20,7 @@
 //-----------------------------------------------------------------
 
 // Declare the function that adds tests suites here ...
+void activation_generator_tests(struct dm_list *suites);
 void bcache_tests(struct dm_list *suites);
 void bcache_utils_tests(struct dm_list *suites);
 void bitset_tests(struct dm_list *suites);
@@ -36,6 +37,7 @@ void vdo_tests(struct dm_list *suites);
 // ... and call it in here.
 static inline void register_all_tests(struct dm_list *suites)
 {
+        activation_generator_tests(suites);
 	bcache_tests(suites);
 	bcache_utils_tests(suites);
 	bitset_tests(suites);


