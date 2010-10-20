From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Oct 2010 15:12:14 -0000
Subject: LVM2 daemons/dmeventd/.exported_symbols daemon ...
Message-ID: <20101020151214.8249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-20 15:12:13

Modified files:
	daemons/dmeventd: .exported_symbols dmeventd.c dmeventd.h 
	                  libdevmapper-event.c 
	libdm          : libdm-file.c 

Log message:
	Implement dmeventd -R, allowing dmeventd to be restarted without losing
	monitoring state.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/.exported_symbols.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/daemons/dmeventd/.exported_symbols	2010/08/16 22:54:36	1.10
+++ LVM2/daemons/dmeventd/.exported_symbols	2010/10/20 15:12:12	1.11
@@ -0,0 +1,3 @@
+init_fifos
+fini_fifos
+daemon_talk
--- LVM2/daemons/dmeventd/dmeventd.c	2010/09/30 21:06:50	1.66
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/10/20 15:12:12	1.67
@@ -99,6 +99,8 @@
 
 int dmeventd_debug = 0;
 static int _foreground = 0;
+static int _restart = 0;
+static char **_initial_registrations = 0;
 
 /* Data kept about a DSO. */
 struct dso_data {
@@ -444,6 +446,61 @@
 	return NULL;
 }
 
+static int _get_status(struct message_data *message_data)
+{
+	struct dm_event_daemon_message *msg = message_data->msg;
+	struct thread_status *thread;
+	int i = 0, j = 0;
+	int ret = -1;
+	int count = dm_list_size(&_thread_registry);
+	int size = 0, current = 0;
+	char *buffers[count];
+	char *message;
+
+	dm_free(msg->data);
+
+	for (i = 0; i < count; ++i)
+		buffers[i] = NULL;
+
+	i = 0;
+	_lock_mutex();
+	dm_list_iterate_items(thread, &_thread_registry) {
+		if ((current = dm_asprintf(buffers + i, "0:%d %s %s %u %" PRIu32 ";",
+					   i, thread->dso_data->dso_name,
+					   thread->device.uuid, thread->events,
+					   thread->timeout)) < 0) {
+			_unlock_mutex();
+			goto out;
+		}
+		++ i;
+		size += current;
+	}
+	_unlock_mutex();
+
+	msg->size = size + strlen(message_data->id) + 1;
+	msg->data = dm_malloc(msg->size);
+	if (!msg->data)
+		goto out;
+	*msg->data = 0;
+
+	message = msg->data;
+	strcpy(message, message_data->id);
+	message += strlen(message_data->id);
+	*message = ' ';
+	message ++;
+	for (j = 0; j < i; ++j) {
+		strcpy(message, buffers[j]);
+		message += strlen(buffers[j]);
+	}
+
+	ret = 0;
+ out:
+	for (j = 0; j < i; ++j)
+		dm_free(buffers[j]);
+	return ret;
+
+}
+
 /* Cleanup@exit. */
 static void _exit_dm_lib(void)
 {
@@ -1343,6 +1400,7 @@
 		{ DM_EVENT_CMD_SET_TIMEOUT, _set_timeout},
 		{ DM_EVENT_CMD_GET_TIMEOUT, _get_timeout},
 		{ DM_EVENT_CMD_ACTIVE, _active},
+		{ DM_EVENT_CMD_GET_STATUS, _get_status},
 	}, *req;
 
 	for (req = requests; req < requests + sizeof(requests); req++)
@@ -1362,11 +1420,12 @@
 	/* Parse the message. */
 	memset(&message_data, 0, sizeof(message_data));
 	message_data.msg = msg;
-	if (msg->cmd == DM_EVENT_CMD_HELLO)  {
+	if (msg->cmd == DM_EVENT_CMD_HELLO || msg->cmd == DM_EVENT_CMD_DIE)  {
 		ret = 0;
 		answer = msg->data;
 		if (answer) {
-			msg->size = dm_asprintf(&(msg->data), "%s HELLO", answer);
+			msg->size = dm_asprintf(&(msg->data), "%s %s", answer,
+						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO");
 			dm_free(answer);
 		} else {
 			msg->size = 0;
@@ -1390,6 +1449,7 @@
 /* Only one caller at a time. */
 static void _process_request(struct dm_event_fifos *fifos)
 {
+	int die = 0;
 	struct dm_event_daemon_message msg;
 
 	memset(&msg, 0, sizeof(msg));
@@ -1401,6 +1461,9 @@
 	if (!_client_read(fifos, &msg))
 		return;
 
+	if (msg.cmd == DM_EVENT_CMD_DIE)
+		die = 1;
+
 	/* _do_process_request fills in msg (if memory allows for
 	   data, otherwise just cmd and size = 0) */
 	_do_process_request(&msg);
@@ -1408,9 +1471,26 @@
 	if (!_client_write(fifos, &msg))
 		stack;
 
+	if (die) raise(9);
+
 	dm_free(msg.data);
 }
 
+static void _process_initial_registrations()
+{
+	int i = 0;
+	char *reg;
+	struct dm_event_daemon_message msg = { 0, 0, NULL };
+
+	while ((reg = _initial_registrations[i])) {
+		msg.cmd = DM_EVENT_CMD_REGISTER_FOR_EVENT;
+		msg.size = strlen(reg);
+		msg.data = reg;
+		_do_process_request(&msg);
+		++ i;
+	}
+}
+
 static void _cleanup_unused_threads(void)
 {
 	int ret;
@@ -1616,6 +1696,56 @@
 	setsid();
 }
 
+static void restart()
+{
+	struct dm_event_fifos fifos;
+	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	int i, count = 0;
+	char *message;
+	int length;
+
+	/* Get the list of registrations from the running daemon. */
+
+	if (!init_fifos(&fifos)) {
+		fprintf(stderr, "Could not initiate communication with existing dmeventd.\n");
+		exit(EXIT_FAILURE);
+	}
+
+	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)) {
+		fprintf(stderr, "Could not communicate with existing dmeventd.\n");
+		exit(EXIT_FAILURE);
+	}
+
+	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
+		exit(EXIT_FAILURE);
+	}
+
+	message = msg.data;
+	message = strchr(message, ' ');
+	++ message;
+	length = strlen(msg.data);
+	for (i = 0; i < length; ++i) {
+		if (msg.data[i] == ';') {
+			msg.data[i] = 0;
+			++count;
+		}
+	}
+
+	_initial_registrations = dm_malloc(sizeof(char*) * (count + 1));
+	for (i = 0; i < count; ++i) {
+		_initial_registrations[i] = dm_strdup(message);
+		message += strlen(message) + 1;
+	}
+	_initial_registrations[count] = 0;
+
+	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0)) {
+		fprintf(stderr, "Old dmeventd refused to die.\n");
+		exit(EXIT_FAILURE);
+	}
+
+	fini_fifos(&fifos);
+}
+
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n");
@@ -1638,7 +1768,7 @@
 	opterr = 0;
 	optind = 0;
 
-	while ((opt = getopt(argc, argv, "?fhVd")) != EOF) {
+	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -1646,6 +1776,9 @@
 		case '?':
 			usage(argv[0], stderr);
 			exit(0);
+		case 'R':
+			_restart++;
+			break;
 		case 'f':
 			_foreground++;
 			break;
@@ -1667,6 +1800,9 @@
 	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
+	if (_restart)
+		restart();
+
 	if (!_foreground)
 		_daemonize();
 
@@ -1706,6 +1842,9 @@
 		kill(getppid(), SIGTERM);
 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
 
+	if (_initial_registrations)
+		_process_initial_registrations();
+
 	while (!_exit_now) {
 		_process_request(&fifos);
 		_cleanup_unused_threads();
--- LVM2/daemons/dmeventd/dmeventd.h	2010/07/13 13:51:02	1.6
+++ LVM2/daemons/dmeventd/dmeventd.h	2010/10/20 15:12:12	1.7
@@ -35,6 +35,8 @@
 	DM_EVENT_CMD_SET_TIMEOUT,
 	DM_EVENT_CMD_GET_TIMEOUT,
 	DM_EVENT_CMD_HELLO,
+	DM_EVENT_CMD_DIE,
+	DM_EVENT_CMD_GET_STATUS,
 };
 
 /* Message passed between client and daemon. */
@@ -63,4 +65,12 @@
 #define EXIT_FIFO_FAILURE        6
 #define EXIT_CHDIR_FAILURE       7
 
+/* Implemented in libdevmapper-event.c, but not part of public API. */
+int daemon_talk(struct dm_event_fifos *fifos,
+		struct dm_event_daemon_message *msg, int cmd,
+		const char *dso_name, const char *dev_name,
+		enum dm_event_mask evmask, uint32_t timeout);
+int init_fifos(struct dm_event_fifos *fifos);
+void fini_fifos(struct dm_event_fifos *fifos);
+
 #endif /* __DMEVENTD_DOT_H__ */
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/08/16 22:54:36	1.34
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/10/20 15:12:12	1.35
@@ -276,7 +276,6 @@
 		dm_free(msg->data);
 		msg->data = NULL;
 	}
-
 	return bytes == size;
 }
 
@@ -341,13 +340,13 @@
 	return bytes == size;
 }
 
-static int _daemon_talk(struct dm_event_fifos *fifos,
-			struct dm_event_daemon_message *msg, int cmd,
-			const char *dso_name, const char *dev_name,
-			enum dm_event_mask evmask, uint32_t timeout)
+int daemon_talk(struct dm_event_fifos *fifos,
+		struct dm_event_daemon_message *msg, int cmd,
+		const char *dso_name, const char *dev_name,
+		enum dm_event_mask evmask, uint32_t timeout)
 {
-	const char *dso = dso_name ? dso_name : "";
-	const char *dev = dev_name ? dev_name : "";
+	const char *dso = dso_name ? dso_name : "-";
+	const char *dev = dev_name ? dev_name : "-";
 	const char *fmt = "%d:%d %s %s %u %" PRIu32;
 	int msg_size;
 	memset(msg, 0, sizeof(*msg));
@@ -452,6 +451,7 @@
 
 	else if (!pid) {
 		execvp(args[0], args);
+		log_error("Unable to exec dmeventd: %s", strerror(errno));
 		_exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)
@@ -466,24 +466,15 @@
 	return ret;
 }
 
-/* Initialize client. */
-static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
+int init_fifos(struct dm_event_fifos *fifos)
 {
 	/* FIXME? Is fifo the most suitable method? Why not share
 	   comms/daemon code with something else e.g. multipath? */
 
-	/* init fifos */
-	memset(fifos, 0, sizeof(*fifos));
-
 	/* FIXME Make these either configurable or depend directly on dmeventd_path */
 	fifos->client_path = DM_EVENT_FIFO_CLIENT;
 	fifos->server_path = DM_EVENT_FIFO_SERVER;
 
-	if (!_start_daemon(dmeventd_path, fifos)) {
-		stack;
-		return 0;
-	}
-
 	/* Open the fifo used to read from the daemon. */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
 		log_error("%s: open server fifo %s",
@@ -511,7 +502,23 @@
 	return 1;
 }
 
-static void _dtr_client(struct dm_event_fifos *fifos)
+/* Initialize client. */
+static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
+{
+	/* init fifos */
+	memset(fifos, 0, sizeof(*fifos));
+
+	/* FIXME Make these either configurable or depend directly on dmeventd_path */
+	fifos->client_path = DM_EVENT_FIFO_CLIENT;
+	fifos->server_path = DM_EVENT_FIFO_SERVER;
+
+	if (!_start_daemon(dmeventd_path, fifos))
+		return_0;
+
+	return init_fifos(fifos);
+}
+
+void fini_fifos(struct dm_event_fifos *fifos)
 {
 	if (flock(fifos->server, LOCK_UN))
 		log_error("flock unlock %s", fifos->server_path);
@@ -576,16 +583,16 @@
 		return -ESRCH;
 	}
 
-	ret = _daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0);
+	ret = daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
 
 	dm_free(msg->data);
 	msg->data = 0;
 
 	if (!ret)
-		ret = _daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
+		ret = daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
 
 	/* what is the opposite of init? */
-	_dtr_client(&fifos);
+	fini_fifos(&fifos);
 
 	return ret;
 }
--- LVM2/libdm/libdm-file.c	2010/07/27 21:56:14	1.13
+++ LVM2/libdm/libdm-file.c	2010/10/20 15:12:12	1.14
@@ -92,6 +92,7 @@
 	ssize_t write_out;
 	struct flock lock;
 	char buffer[50];
+	int retries = 0;
 
 	if((fd = open(lockfile, O_CREAT | O_WRONLY,
 		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0) {
@@ -112,9 +113,15 @@
 			break;
 		case EACCES:
 		case EAGAIN:
-			log_error("Cannot lock lockfile [%s], error was [%s]",
-				   lockfile, strerror(errno));
-			break;
+			if (retries == 20) {
+				log_error("Cannot lock lockfile [%s], error was [%s]",
+					  lockfile, strerror(errno));
+				break;
+			} else {
+				++ retries;
+				usleep(1000);
+				goto retry_fcntl;
+			}
 		default:
 			log_error("process is already running");
 		}


