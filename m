From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 25 Sep 2023 23:34:24 +0000
Subject: [Git][lvmteam/lvm2][main] 14 commits: lvmdbusd: fix syntax warning
Message-ID: <651219003585c_28a526c610b9@gitlab-sidekiq-low-urgency-cpu-bound-v2-89c5f5645-57pgx.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
a8fd6de9 by Zdenek Kabelac at 2023-09-20T15:55:28+02:00
lvmdbusd: fix syntax warning

python3.12 reported SyntaxWarning: invalid escape sequence &#39;\/&#39;

- - - - -
90713c84 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: enhance timestamp for debugging

Add microseconds for timestamps in dm-event trace messages.
Also collect timestamps only when debugging when they are used.

- - - - -
a203499b by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: release buffer on dm_event_get_version

Avoid memory leak in this function.

- - - - -
39602471 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dm-event: reset descriptors

Reset descriptors after closing them to -1.

- - - - -
c31dcf36 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: use return

Use &#39;return&#39; instead of calling exit() when possible.

- - - - -
637d812d by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: unregister all devices on restart

Instead of just exiting in the middle of monitoring,
unregisted all monitored devices first and then exit.

To speedup this path, all send internal SIGINT when thread
unregiters itself, to wakup-up main sleeping loop.

- - - - -
80d34abf by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: info status report

To quickly get info about some internal dmeventd status,
implment   &#39;dmeventd -i&#39; support.

Reported messages are some &#39;raw&#39; internal informations mainly
useful to developers.

- - - - -
744cdc3b by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
configure.ac: add --with-dmeventd-exit-on-path

- - - - -
3da18a06 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
configure: autoreconf

- - - - -
a9d7a9d1 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
dmeventd: implement exit_on file check

When exit on file is present in a system and term/break signal is
catched, them dmeventd is no longger refusing to exit.

For the correct shutdown, there should be ideally unmonitoring call,
however in some case it&#39;s very hard to implement this correct procedure.

With this &#39;exit on&#39; file dmeventd at least avoid &#39;blocking&#39; shutdown,
before systemd kills use with -9 anyway possibly even in some unwanted
stated of internal dmeventd processing (i.e. in the middle of some lvm
command processing).

- - - - -
e930ee93 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
debug: correct level

No error for just tracing message.

- - - - -
d54deae0 by Zdenek Kabelac at 2023-09-26T01:23:00+02:00
debug: correcting check for error

Correct trace for erroring case of close.

- - - - -
cb8486a9 by Zdenek Kabelac at 2023-09-26T01:24:38+02:00
tests: check exit_on works

- - - - -
d0637837 by Zdenek Kabelac at 2023-09-26T01:32:48+02:00
WHATS_NEW_DM: update

- - - - -


14 changed files:

- WHATS_NEW_DM
- configure
- configure.ac
- daemons/dmeventd/dmeventd.c
- daemons/dmeventd/libdevmapper-event.c
- daemons/lvmdbusd/utils.py
- device_mapper/ioctl/libdm-iface.c
- include/configure.h.in
- lib/log/log.c
- libdm/ioctl/libdm-iface.c
- make.tmpl.in
- man/Makefile.in
- man/dmeventd.8_main
- test/shell/dmeventd-restart.sh


Changes:

=====================================
WHATS_NEW_DM
=====================================
@@ -1,5 +1,7 @@
 Version 1.02.197 - 
 ===================================
+  Add support for exit-on file for dmevent to reduce shutdown delays.
+  Add configure option --with-dmeventd-exit-on-path to specify default path.
   Add dmsetup --headings none|abbrev|full to set report headings type.
   Add DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS to provide alternative headings.
 


=====================================
configure
=====================================
@@ -736,6 +736,7 @@ DEFAULT_PROFILE_SUBDIR
 DEFAULT_PID_DIR
 DEFAULT_MIRROR_SEGTYPE
 DEFAULT_LOCK_DIR
+DEFAULT_DMEVENTD_EXIT_ON_PATH
 DEFAULT_DM_RUN_DIR
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
@@ -1005,6 +1006,7 @@ with_systemdsystemunitdir
 with_tmpfilesdir
 with_dmeventd_pidfile
 with_dmeventd_path
+with_dmeventd_exit_on_path
 with_default_system_dir
 with_default_profile_subdir
 with_default_archive_subdir
@@ -1813,6 +1815,9 @@ Optional Packages:
                           dmeventd pidfile [PID_DIR/dmeventd.pid]
   --with-dmeventd-path=PATH
                           dmeventd path [EPREFIX/sbin/dmeventd]
+  --with-dmeventd-exit-on-path=PATH
+                          Default path to exit-on file in dmeventd
+                          [/run/nologin]
   --with-default-system-dir=DIR
                           default LVM system directory [/etc/lvm]
   --with-default-profile-subdir=SUBDIR
@@ -15938,6 +15943,15 @@ else $as_nop
 fi
 
 
+# Check whether --with-dmeventd-exit-on-path was given.
+if test ${with_dmeventd_exit_on_path+y}
+then :
+  withval=$with_dmeventd_exit_on_path; DEFAULT_DMEVENTD_EXIT_ON_PATH=$withval
+else $as_nop
+  DEFAULT_DMEVENTD_EXIT_ON_PATH="/run/nologin"
+fi
+
+
 if test "$BUILD_DMEVENTD" = "yes"
 then :
 
@@ -15948,6 +15962,9 @@ printf "%s\n" "#define DMEVENTD_PIDFILE \"$DMEVENTD_PIDFILE\"" >>confdefs.h
 printf "%s\n" "#define DMEVENTD_PATH \"$DMEVENTD_PATH\"" >>confdefs.h
 
 
+printf "%s\n" "#define DEFAULT_DMEVENTD_EXIT_ON_PATH \"$DEFAULT_DMEVENTD_EXIT_ON_PATH\"" >>confdefs.h
+
+
 fi
 
 ################################################################################
@@ -16228,6 +16245,7 @@ AIO_LIBS=${AIO_LIBS:--laio}
 
 
 
+
 
 
 ################################################################################


=====================================
configure.ac
=====================================
@@ -1686,12 +1686,19 @@ AC_ARG_WITH(dmeventd-path,
 			   [dmeventd path [EPREFIX/sbin/dmeventd]]),
 	    DMEVENTD_PATH=$withval,
 	    DMEVENTD_PATH="$SBINDIR/dmeventd")
+AC_ARG_WITH(dmeventd-exit-on-path,
+	    AS_HELP_STRING([--with-dmeventd-exit-on-path=PATH],
+			   [Default path to exit-on file in dmeventd [/run/nologin]]),
+	    DEFAULT_DMEVENTD_EXIT_ON_PATH=$withval,
+	    DEFAULT_DMEVENTD_EXIT_ON_PATH="/run/nologin")
 
 AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
 	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
 			   [Path to dmeventd binary.])
+	AC_DEFINE_UNQUOTED(DEFAULT_DMEVENTD_EXIT_ON_PATH, ["$DEFAULT_DMEVENTD_EXIT_ON_PATH"],
+			   [Path to exit-on dmeventd file.])
 ])
 
 ################################################################################
@@ -1825,6 +1832,7 @@ AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
+AC_SUBST(DEFAULT_DMEVENTD_EXIT_ON_PATH)
 AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_MIRROR_SEGTYPE)
 AC_SUBST(DEFAULT_PID_DIR)


=====================================
daemons/dmeventd/dmeventd.c
=====================================
@@ -98,6 +98,7 @@ static int _systemd_activation = 0;
 static int _foreground = 0;
 static int _restart = 0;
 static time_t _idle_since = 0;
+static const char *_exit_on = DEFAULT_DMEVENTD_EXIT_ON_PATH;
 static char **_initial_registrations = 0;
 
 /* FIXME Make configurable at runtime */
@@ -723,12 +724,18 @@ static int _get_status(struct message_data *message_data)
 static int _get_parameters(struct message_data *message_data) {
 	struct dm_event_daemon_message *msg = message_data->msg;
 	int size;
+	char idle_buf[32] = "";
+
+	if (_idle_since)
+		(void)dm_snprintf(idle_buf, sizeof(idle_buf), " idle=%lu", (long unsigned) (time(NULL) - _idle_since));
 
 	free(msg->data);
-	if ((size = dm_asprintf(&msg->data, "%s pid=%d daemon=%s exec_method=%s",
+	if ((size = dm_asprintf(&msg->data, "%s pid=%d daemon=%s exec_method=%s exit_on=\"%s\"%s",
 				message_data->id, getpid(),
 				_foreground ? "no" : "yes",
-				_systemd_activation ? "systemd" : "direct")) < 0) {
+				_systemd_activation ? "systemd" : "direct",
+				_exit_on,
+				idle_buf)) < 0) {
 		stack;
 		return -ENOMEM;
 	}
@@ -998,6 +1005,8 @@ static void _monitor_unregister(void *arg)
 	_lock_mutex();
 	thread->status = DM_THREAD_DONE; /* Last access to thread memory! */
 	_unlock_mutex();
+	if (_exit_now)  /* Exit is already in-progress, wake-up sleeping select() */
+		kill(getpid(), SIGINT);
 }
 
 /* Device monitoring thread. */
@@ -1162,6 +1171,36 @@ static int _unregister_for_event(struct message_data *message_data)
 	return ret;
 }
 
+static void _unregister_all_threads(void)
+{
+	struct thread_status *thread, *tmp;
+
+	_lock_mutex();
+
+	dm_list_iterate_items_safe(thread, tmp, &_thread_registry)
+		_update_events(thread, 0);
+
+	_unlock_mutex();
+}
+
+static void _wait_for_new_pid(void)
+{
+	unsigned long st_ino = 0;
+	struct stat st;
+	int i;
+
+	for (i = 0; i < 400000; ++i) {
+		if (lstat(DMEVENTD_PIDFILE, &st) == 0) {
+			if (!st_ino)
+				st_ino = st.st_ino;
+			else if (st_ino != st.st_ino)
+				break; /* different pidfile */
+		} else if (errno == ENOENT)
+			break; /* pidfile is removed */
+		usleep(100);
+	}
+}
+
 /*
  * Register for an event.
  *
@@ -1678,9 +1717,9 @@ static void _process_request(struct dm_event_fifos *fifos)
 	free(msg.data);
 
 	if (cmd == DM_EVENT_CMD_DIE) {
-		if (unlink(DMEVENTD_PIDFILE))
-			log_sys_error("unlink", DMEVENTD_PIDFILE);
-		_exit(0);
+		_unregister_all_threads();
+		_exit_now = DM_SCHEDULED_EXIT;
+		log_info("dmeventd exiting for restart.");
 	}
 }
 
@@ -1727,7 +1766,7 @@ static void _cleanup_unused_threads(void)
 		DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
 
 		if (pthread_join(thread->thread, NULL))
-			log_sys_error("pthread_join", "");
+			log_sys_debug("pthread_join", "");
 
 		_free_thread_status(thread);
 		_lock_mutex();
@@ -1758,7 +1797,7 @@ static void _init_thread_signals(void)
 	sigdelset(&my_sigset, SIGQUIT);
 
 	if (pthread_sigmask(SIG_BLOCK, &my_sigset, NULL))
-		log_sys_error("pthread_sigmask", "SIG_BLOCK");
+		log_sys_debug("pthread_sigmask", "SIG_BLOCK");
 }
 
 /*
@@ -1770,7 +1809,8 @@ static void _init_thread_signals(void)
  */
 static void _exit_handler(int sig __attribute__((unused)))
 {
-	_exit_now = DM_SIGNALED_EXIT;
+	if (!_exit_now)
+		_exit_now = DM_SIGNALED_EXIT;
 }
 
 #ifdef __linux__
@@ -1786,7 +1826,7 @@ static int _set_oom_adj(const char *oom_adj_path, int val)
 	fprintf(fp, "%i", val);
 
 	if (dm_fclose(fp))
-		log_sys_error("fclose", oom_adj_path);
+		log_sys_debug("fclose", oom_adj_path);
 
 	return 1;
 }
@@ -1800,11 +1840,11 @@ static int _protect_against_oom_killer(void)
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
 		if (errno != ENOENT)
-			log_sys_error("stat", OOM_ADJ_FILE);
+			log_sys_debug("stat", OOM_ADJ_FILE);
 
 		/* Try old oom_adj interface as a fallback */
 		if (stat(OOM_ADJ_FILE_OLD, &st) == -1) {
-			log_sys_error("stat", OOM_ADJ_FILE_OLD);
+			log_sys_debug("stat", OOM_ADJ_FILE_OLD);
 			return 1;
 		}
 
@@ -1893,14 +1933,14 @@ out:
 static void _remove_files_on_exit(void)
 {
 	if (unlink(DMEVENTD_PIDFILE))
-		log_sys_error("unlink", DMEVENTD_PIDFILE);
+		log_sys_debug("unlink", DMEVENTD_PIDFILE);
 
 	if (!_systemd_activation) {
 		if (unlink(DM_EVENT_FIFO_CLIENT))
-			log_sys_error("unlink", DM_EVENT_FIFO_CLIENT);
+			log_sys_debug("unlink", DM_EVENT_FIFO_CLIENT);
 
 		if (unlink(DM_EVENT_FIFO_SERVER))
-			log_sys_error("unlink", DM_EVENT_FIFO_SERVER);
+			log_sys_debug("unlink", DM_EVENT_FIFO_SERVER);
 	}
 }
 
@@ -2032,6 +2072,68 @@ static int _reinstate_registrations(struct dm_event_fifos *fifos)
 	return 1;
 }
 
+static int _info_dmeventd(const char *name, struct dm_event_fifos *fifos)
+{
+	struct dm_event_daemon_message msg = { 0 };
+	int i, count = 0;
+	char *line;
+	int version;
+	int ret = 0;
+
+	/* Get the list of registrations from the running daemon. */
+	if (!init_fifos(fifos)) {
+		fprintf(stderr, "Could not initiate communication with existing dmeventd.\n");
+		return 0;
+	}
+
+	if (!dm_event_get_version(fifos, &version)) {
+		fprintf(stderr, "Could not communicate with existing dmeventd.\n");
+		goto out;
+	}
+
+	if (version < 1) {
+		fprintf(stderr, "The running dmeventd instance is too old.\n"
+			"Protocol version %d (required: 1). Action cancelled.\n", version);
+		goto out;
+	}
+
+	if (daemon_talk(fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
+		fprintf(stderr, "Failed to acquire status from existing dmeventd.\n");
+		goto out;
+	}
+
+	line = strchr(msg.data, ' ') + 1;
+	for (i = 0; msg.data[i]; ++i)
+		if (msg.data[i] == ';') {
+			msg.data[i] = 0;
+			if (!count)
+				printf("%s is monitoring:\n", name);
+			printf("%s\n", line);
+			line = msg.data + i + 1;
+			++count;
+		}
+
+	free(msg.data);
+
+	if (!count)
+		printf("%s does not monitor any device.\n", name);
+
+	if (version >= 2) {
+		if (daemon_talk(fifos, &msg, DM_EVENT_CMD_GET_PARAMETERS, "-", "-", 0, 0)) {
+			fprintf(stderr, "Failed to acquire parameters from existing dmeventd.\n");
+			goto out;
+		}
+		printf("%s internal status: %s\n", name, msg.data);
+		free(msg.data);
+	}
+
+	ret = 1;
+out:
+	fini_fifos(fifos);
+
+	return ret;
+}
+
 static void _restart_dmeventd(void)
 {
 	struct dm_event_fifos fifos = {
@@ -2118,19 +2220,15 @@ static void _restart_dmeventd(void)
 	    ((e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) && strcmp(e, "1")))
 		_systemd_activation = 1;
 
-	for (i = 0; i < 10; ++i) {
-		if ((access(DMEVENTD_PIDFILE, F_OK) == -1) && (errno == ENOENT))
-			break;
-		usleep(10);
-	}
+	fini_fifos(&fifos);
 
-	if (!_systemd_activation) {
-		fini_fifos(&fifos);
+	/* Give a few seconds dmeventd to finish */
+	_wait_for_new_pid();
+
+	if (!_systemd_activation)
 		return;
-	}
 
 	/* Reopen fifos. */
-	fini_fifos(&fifos);
 	if (!init_fifos(&fifos)) {
 		fprintf(stderr, "Could not initiate communication with new instance of dmeventd.\n");
 		exit(EXIT_FAILURE);
@@ -2151,10 +2249,12 @@ bad:
 static void _usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
-		"%s [-d [-d [-d]]] [-f] [-h] [-l] [-R] [-V] [-?]\n\n"
+		"%s [-d [-d [-d]]] [-e path] [-f] [-h] [i] [-l] [-R] [-V] [-?]\n\n"
 		"   -d       Log debug messages to syslog (-d, -dd, -ddd)\n"
+		"   -e       Select a file path checked on exit\n"
 		"   -f       Don't fork, run in the foreground\n"
 		"   -h       Show this help information\n"
+		"   -i       Query running instance of dmeventd for info\n"
 		"   -l       Log to stdout,stderr instead of syslog\n"
 		"   -?       Show this help information on stderr\n"
 		"   -R       Restart dmeventd\n"
@@ -2171,20 +2271,29 @@ int main(int argc, char *argv[])
 		.server_path = DM_EVENT_FIFO_SERVER
 	};
 	time_t now, idle_exit_timeout = DMEVENTD_IDLE_EXIT_TIMEOUT;
-	opterr = 0;
-	optind = 0;
 
-	while ((opt = getopt(argc, argv, "?fhVdlR")) != EOF) {
+	optopt = optind = opterr = 0;
+	optarg = (char*) "";
+	while ((opt = getopt(argc, argv, ":?e:fhiVdlR")) != EOF) {
 		switch (opt) {
 		case 'h':
 			_usage(argv[0], stdout);
-			exit(EXIT_SUCCESS);
+			return EXIT_SUCCESS;
 		case '?':
 			_usage(argv[0], stderr);
-			exit(EXIT_SUCCESS);
+			return EXIT_SUCCESS;
+		case 'i':
+			return _info_dmeventd(argv[0], &fifos) ? EXIT_SUCCESS : EXIT_FAILURE;
 		case 'R':
 			_restart++;
 			break;
+		case 'e':
+			if (strchr(optarg, '"')) {
+				fprintf(stderr, "dmeventd: option -e does not accept path \"%s\" with '\"' character.\n", optarg);
+				return EXIT_FAILURE;
+			}
+			_exit_on=optarg;
+			break;
 		case 'f':
 			_foreground++;
 			break;
@@ -2196,7 +2305,10 @@ int main(int argc, char *argv[])
 			break;
 		case 'V':
 			printf("dmeventd version: %s\n", DM_LIB_VERSION);
-			exit(EXIT_SUCCESS);
+			return EXIT_SUCCESS;
+		case ':':
+			fprintf(stderr, "dmeventd: option -%c requires an argument.\n", optopt);
+			return EXIT_FAILURE;
 		}
 	}
 
@@ -2287,15 +2399,28 @@ int main(int argc, char *argv[])
 					break;
 				}
 			}
-		} else if (_exit_now == DM_SIGNALED_EXIT) {
-			_exit_now = DM_SCHEDULED_EXIT;
-			/*
-			 * When '_exit_now' is set, signal has been received,
-			 * but can not simply exit unless all
-			 * threads are done processing.
-			 */
-			log_info("dmeventd received break, scheduling exit.");
-		}
+		} else
+			switch (_exit_now) {
+			case DM_SIGNALED_EXIT:
+				_exit_now = DM_SCHEDULED_EXIT;
+				/*
+				 * When '_exit_now' is set, signal has been received,
+				 * but can not simply exit unless all
+				 * threads are done processing.
+				 */
+				log_info("dmeventd received break, scheduling exit.");
+				/* fall through */
+			case DM_SCHEDULED_EXIT:
+				/* While exit is scheduled, check for exit_on file */
+				DEBUGLOG("Checking exit on file \"%s\".", _exit_on);
+				if (_exit_on[0] && (access(_exit_on, F_OK) == 0)) {
+					log_info("dmeventd detected exit on file %s, unregistering all monitored devices.",
+						 _exit_on);
+					_unregister_all_threads();
+				}
+				break;
+			}
+
 		_process_request(&fifos);
 		_cleanup_unused_threads();
 	}
@@ -2305,9 +2430,9 @@ int main(int argc, char *argv[])
 	log_notice("dmeventd shutting down.");
 
 	if (fifos.client >= 0 && close(fifos.client))
-		log_sys_error("client close", fifos.client_path);
+		log_sys_debug("client close", fifos.client_path);
 	if (fifos.server >= 0 && close(fifos.server))
-		log_sys_error("server close", fifos.server_path);
+		log_sys_debug("server close", fifos.server_path);
 
 	if (_use_syslog)
 		closelog();


=====================================
daemons/dmeventd/libdevmapper-event.c
=====================================
@@ -552,6 +552,8 @@ void fini_fifos(struct dm_event_fifos *fifos)
 		if (close(fifos->server))
 			log_sys_debug("close", fifos->server_path);
 	}
+
+	fifos->client = fifos->server = -1;
 }
 
 /* Get uuid of a device */
@@ -844,6 +846,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	char *p;
 	struct dm_event_daemon_message msg = { 0 };
+	int ret = 0;
 
 	if (daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0))
 		return 0;
@@ -851,13 +854,17 @@ int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	*version = 0;
 
 	if (!p || !(p = strchr(p, ' '))) /* Message ID */
-		return 0;
+		goto out;
 	if (!(p = strchr(p + 1, ' '))) /* HELLO */
-		return 0;
+		goto out;
 	if ((p = strchr(p + 1, ' '))) /* HELLO, once more */
 		*version = atoi(p);
 
-	return 1;
+	ret = 1;
+out:
+	free(msg.data);
+
+	return ret;
 }
 
 void dm_event_log_set(int debug_log_level, int use_syslog)
@@ -872,11 +879,11 @@ void dm_event_log(const char *subsys, int level, const char *file,
 {
 	static int _abort_on_internal_errors = -1;
 	static pthread_mutex_t _log_mutex = PTHREAD_MUTEX_INITIALIZER;
-	static time_t start = 0;
+	static long long _start = 0;
 	const char *indent = "";
 	FILE *stream = log_stderr(level) ? stderr : stdout;
 	int prio;
-	time_t now;
+	long long now, now_nsec;
 	int log_with_debug = 0;
 
 	if (subsys[0] == '#') {
@@ -923,17 +930,28 @@ void dm_event_log(const char *subsys, int level, const char *file,
 	if (_use_syslog) {
 		vsyslog(prio, format, ap);
 	} else {
-		now = time(NULL);
-		if (!start)
-			start = now;
-		now -= start;
-		if (_debug_level)
-			fprintf(stream, "[%2lld:%02lld] %8x:%-6s%s",
-				(long long)now / 60, (long long)now % 60,
+		if (_debug_level) {
+#define _NSEC_PER_SEC (1000000000LL)
+#ifdef HAVE_REALTIME
+			struct timespec mono_time = { 0 };
+			if (clock_gettime(CLOCK_MONOTONIC, &mono_time) == 0)
+				now = mono_time.tv_sec * _NSEC_PER_SEC + mono_time.tv_nsec;
+			else
+#endif
+				now = time(NULL) * _NSEC_PER_SEC;
+
+			if (!_start)
+				_start = now;
+			now -= _start;
+			now_nsec = now %_NSEC_PER_SEC;
+			now /= _NSEC_PER_SEC;
+			fprintf(stream, "[%2lld:%02lld.%06lld] %8x:%-6s%s",
+				now / 60, now % 60, now_nsec / 1000,
 				// TODO: Maybe use shorter ID
 				// ((int)(pthread_self()) >> 6) & 0xffff,
 				(int)pthread_self(), subsys,
 				(_debug_level > 3) ? "" : indent);
+		}
 		if (_debug_level > 3)
 			fprintf(stream, "%28s:%4d %s", file, line, indent);
 		vfprintf(stream, _(format), ap);


=====================================
daemons/lvmdbusd/utils.py
=====================================
@@ -543,7 +543,7 @@ def round_size(size_bytes):
 	return size_bytes + bs - remainder
 
 
-_ALLOWABLE_CH = string.ascii_letters + string.digits + '#+-.:=@_\/%'
+_ALLOWABLE_CH = string.ascii_letters + string.digits + '#+-.:=@_/%'
 _ALLOWABLE_CH_SET = set(_ALLOWABLE_CH)
 
 _ALLOWABLE_VG_LV_CH = string.ascii_letters + string.digits + '.-_+'


=====================================
device_mapper/ioctl/libdm-iface.c
=====================================
@@ -404,7 +404,7 @@ static void _close_control_fd(void)
 {
 	if (_control_fd != -1) {
 		if (close(_control_fd) < 0)
-			log_sys_error("close", "_control_fd");
+			log_sys_debug("close", "_control_fd");
 		_control_fd = -1;
 	}
 }


=====================================
include/configure.h.in
=====================================
@@ -43,6 +43,9 @@
 /* Name of default metadata cache subdirectory. */
 #undef DEFAULT_CACHE_SUBDIR
 
+/* Path to exit-on dmeventd file. */
+#undef DEFAULT_DMEVENTD_EXIT_ON_PATH
+
 /* Define default node creation behavior with dmsetup create */
 #undef DEFAULT_DM_ADD_NODE
 


=====================================
lib/log/log.c
=====================================
@@ -234,7 +234,7 @@ static int _get_pid_starttime(int *pid, unsigned long long *starttime)
 	if ((e = read(fd, buf, sizeof(buf) - 1)) <= 0)
 		log_sys_debug("read", statfile);
 
-	if (!close(fd))
+	if (close(fd))
 		log_sys_debug("close", statfile);
 
 	if (e <= 0)


=====================================
libdm/ioctl/libdm-iface.c
=====================================
@@ -403,7 +403,7 @@ static void _close_control_fd(void)
 {
 	if (_control_fd != -1) {
 		if (close(_control_fd) < 0)
-			log_sys_error("close", "_control_fd");
+			log_sys_debug("close", "_control_fd");
 		_control_fd = -1;
 	}
 }


=====================================
make.tmpl.in
=====================================
@@ -167,6 +167,7 @@ DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
 DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 DEFAULT_PID_DIR = @DEFAULT_PID_DIR@
 DEFAULT_MANGLING = @MANGLING@
+DEFAULT_DMEVENTD_EXIT_ON_PATH = @DEFAULT_DMEVENTD_EXIT_ON_PATH@
 
 #----------------------------------------------------------------------
 # From http://blog.melski.net/tag/debugging-makefiles/


=====================================
man/Makefile.in
=====================================
@@ -180,6 +180,7 @@ $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_PID_DIR#+$(DEFAULT_PID_DIR)+" \
 	-e "s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+" \
 	-e "s+#DEFAULT_LIBLINE#+$(DEFAULT_LIBLINE)+" \
+	-e "s+#DEFAULT_DMEVENTD_EXIT_ON_PATH#+$(DEFAULT_DMEVENTD_EXIT_ON_PATH)+" \
 	-e "s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+" $< > $@
 endef
 


=====================================
man/dmeventd.8_main
=====================================
@@ -10,8 +10,11 @@ dmeventd \(em Device-mapper event daemon
 .RB [ -d
 .RB [ -d
 .RB [ -d ]]]
+.RB [ -e
+.BR exit_on_path ]
 .RB [ -f ]
 .RB [ -h ]
+.RB [ -i ]
 .RB [ -l ]
 .RB [ -R ]
 .RB [ -V ]
@@ -36,6 +39,16 @@ debug messages sent to syslog.
 Each extra d adds more debugging information.
 .
 .TP
+.B -e exit_on_path
+Specifies the file path whose presence is checked by the daemon when it
+receives a signal (SIGINT, SIGTERM) and allows to exit even if there are still
+monitored devices.
+This can help with system shutdown where devices
+have not been unmonitored properly.
+To disable this behavior set this to the empty string "".
+Default value is "\fI#DEFAULT_DMEVENTD_EXIT_ON_PATH#\fP".
+.
+.TP
 .B -f
 Don't fork, run in the foreground.
 .
@@ -44,6 +57,12 @@ Don't fork, run in the foreground.
 Show help information.
 .
 .TP
+.B -i
+Query the running daemon instance for the status informations. The format is
+internal and unstable and it is targeted for developers.
+Format may change between versions.
+.
+.TP
 .B -l
 Log through stdout and stderr instead of syslog.
 This option works only with option -f, otherwise it is ignored.


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -46,8 +46,8 @@ rm LOCAL_DMEVENTD debug.log*
 dmeventd -R -f &
 echo $! >LOCAL_DMEVENTD
 
-# wait longer as tries to communicate with killed daemon
-sleep 9
+# wait longer as tries 5s to communicate with killed daemon
+sleep 7
 # now dmeventd should not be running
 not pgrep dmeventd
 rm LOCAL_DMEVENTD
@@ -63,4 +63,24 @@ test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 lvchange --monitor y --verbose $vg/$lv2 2>&1 | tee lvchange.out
 test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 
-vgremove -ff $vg
+rm -f debug.log*
+dmeventd -R -f -e "$PWD/test_nologin" -ldddd > debug.log_DMEVENTD_$RANDOM 2>&1 &
+echo $! >LOCAL_DMEVENTD
+
+pgrep -o dmeventd
+kill -INT "$(< LOCAL_DMEVENTD)"
+sleep 1
+
+# dmeventd should be still present (although in 'exit-mode')
+pgrep -o dmeventd
+
+# Create a file simulating 'shutdown in progress'
+touch test_nologin
+sleep 1.1
+
+# Should be now dead (within 1 second)
+not pgrep -o dmeventd
+rm -f LOCAL_DMEVENTD
+
+# Do not run dmeventd here again
+vgremove -ff --config 'activation/monitoring = 0' $vg



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/fc2feabef7507108311c01e48c6262606caf37fd...d06378373e32b159165e10347b243b37c4e472c1

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/fc2feabef7507108311c01e48c6262606caf37fd...d06378373e32b159165e10347b243b37c4e472c1
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230925/78a59f4b/attachment-0001.htm>
