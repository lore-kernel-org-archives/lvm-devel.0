From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 5 Oct 2010 16:31:57 -0500
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <87sk0kncit.fsf@twilight.int.mornfall.net.>
References: <87sk0kncit.fsf@twilight.int.mornfall.net.>
Message-ID: <BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are some uncovered races if a couple of these get going at  
once.  Those don't really bother me, so I'll let someone else chime in  
if it's important to them.

Idea seems good, and patch looks fine (aside from cosmetic NULL vs '0').

  brassow

On Oct 5, 2010, at 5:45 AM, Petr Rockai wrote:

> Hi,
>
> the attached patch implements dmeventd -R, which allows us to restart
> dmeventd without losing the monitoring state. The version that is
> already running needs to support a (new) "get status" command for this
> to work. This means that upgrade scripts can't use dmeventd -R if they
> are upgrading from a version that does not provide this mechanism,
> without losing the monitoring status.
>
> I believe a reasonable solution (for upgrades) is to:
>
> - check the existing version of dmeventd
> - if new, use dmeventd -R
> - if old, kill dmeventd, start the new one and enable monitoring for  
> all
>  devices in the system
>
> IIRC, RPM provides the version number of the package you are upgrading
> from to the post-installation script, which would make the above  
> fairly
> easy. If no, you can run dmeventd -V in pre-install (and store it
> somewhere) and use that in the post-install to decide what to do.
>
> The patch provides an automated test for the -R functionality, in
> test/t-dmeventd-restart.sh.
>
> Yours,
>   Petr.
>
> PS: The other option is to just use dmeventd -R unconditionally. It
> should fail if the running dmeventd is too old, but should not cause  
> any
> other harm. This needs some extra testing, though.
>
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/dmeventd.c new- 
> dmeventd-restart/daemons/dmeventd/dmeventd.c
> --- old-dmeventd-restart/daemons/dmeventd/dmeventd.c	2010-10-05  
> 12:44:15.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/dmeventd.c	2010-10-05  
> 12:44:16.000000000 +0200
> @@ -99,6 +99,8 @@ static pthread_mutex_t _global_mutex;
>
> int dmeventd_debug = 0;
> static int _foreground = 0;
> +static int _restart = 0;
> +static char **_initial_registrations = 0;
>
> /* Data kept about a DSO. */
> struct dso_data {
> @@ -444,6 +446,55 @@ static struct thread_status *_lookup_thr
> 	return NULL;
> }
>
> +static int _get_status(struct message_data *message_data)
> +{
> +	struct dm_event_daemon_message *msg = message_data->msg;
> +	struct thread_status *thread;
> +	int i = 0, j = 0;
> +	int ret = -1;
> +	int count = dm_list_size(&_thread_registry);
> +	int size = 0, current = 0;
> +	char *buffers[count];
> +	char *message;
> +
> +	dm_free(msg->data);
> +
> +	_lock_mutex();
> +	dm_list_iterate_items(thread, &_thread_registry) {
> +		if ((current = dm_asprintf(buffers + i, "0:%d %s %s %u %" PRIu32  
> ";",
> +					   i, thread->dso_data->dso_name,
> +					   thread->device.uuid, thread->events,
> +					   thread->timeout)) < 0)
> +			goto out;
> +		++ i;
> +		size += current;
> +	}
> +	_unlock_mutex();
> +
> +	msg->size = size + strlen(message_data->id) + 1;
> +	msg->data = dm_malloc(msg->size);
> +	*msg->data = 0;
> +	if (!msg->data)
> +		goto out;
> +
> +	message = msg->data;
> +	strcpy(message, message_data->id);
> +	message += strlen(message_data->id);
> +	*message = ' ';
> +	message ++;
> +	for (j = 0; j < i; ++j) {
> +		strcpy(message, buffers[j]);
> +		message += strlen(buffers[j]);
> +	}
> +
> +	ret = 0;
> + out:
> +	/* for (j = 0; j < i; ++j)
> +	   dm_free(buffers + j); */
> +	return ret;
> +
> +}
> +
> /* Cleanup at exit. */
> static void _exit_dm_lib(void)
> {
> @@ -1343,6 +1394,7 @@ static int _handle_request(struct dm_eve
> 		{ DM_EVENT_CMD_SET_TIMEOUT, _set_timeout},
> 		{ DM_EVENT_CMD_GET_TIMEOUT, _get_timeout},
> 		{ DM_EVENT_CMD_ACTIVE, _active},
> +		{ DM_EVENT_CMD_GET_STATUS, _get_status},
> 	}, *req;
>
> 	for (req = requests; req < requests + sizeof(requests); req++)
> @@ -1411,6 +1463,21 @@ static void _process_request(struct dm_e
> 	dm_free(msg.data);
> }
>
> +static void _process_initial_registrations()
> +{
> +	int i = 0;
> +	char *reg;
> +	struct dm_event_daemon_message msg = { 0, 0, NULL };
> +
> +	while ((reg = _initial_registrations[i])) {
> +		msg.cmd = DM_EVENT_CMD_REGISTER_FOR_EVENT;
> +		msg.size = strlen(reg);
> +		msg.data = reg;
> +		_do_process_request(&msg);
> +		++ i;
> +	}
> +}
> +
> static void _cleanup_unused_threads(void)
> {
> 	int ret;
> @@ -1616,6 +1683,70 @@ static void _daemonize(void)
> 	setsid();
> }
>
> +static void restart()
> +{
> +	char buffer[32];
> +	pid_t pid;
> +	struct dm_event_fifos fifos;
> +	struct dm_event_daemon_message msg = { 0, 0, NULL };
> +	FILE *pidf = fopen(DMEVENTD_PIDFILE, "r");
> +	int i, count = 0;
> +	char *message;
> +
> +	/* First, get the PID of the daemon we are going to replace. */
> +
> +	if (!pidf) {
> +		fprintf(stderr, "Could not open %s.\n", DMEVENTD_PIDFILE);
> +		exit(EXIT_FAILURE);
> +	}
> +	fgets(buffer, 32, pidf);
> +	pid = atoi(buffer);
> +	if (!pid) {
> +		fprintf(stderr, "Could not read dmeventd PID from %s.\n",  
> DMEVENTD_PIDFILE);
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	/* Get the list of registrations from the running daemon. */
> +
> +	if (!init_fifos(&fifos)) {
> +		fprintf(stderr, "Could not initiate communication with existing  
> dmeventd.\n");
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0)) {
> +		fprintf(stderr, "Could not communicate with existing dmeventd.\n");
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-",  
> 0, 0)) {
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	message = msg.data;
> +	message = strchr(message, ' ');
> +	++ message;
> +	int length = strlen(msg.data);
> +	for (i = 0; i < length; ++i) {
> +		if (msg.data[i] == ';') {
> +			msg.data[i] = 0;
> +			++count;
> +		}
> +	}
> +
> +	_initial_registrations = dm_malloc(sizeof(char*) * (count + 1));
> +	for (i = 0; i < count; ++i) {
> +		_initial_registrations[i] = dm_strdup(message);
> +		message += strlen(message) + 1;
> +	}
> +	_initial_registrations[count] = 0;
> +
> +	fini_fifos(&fifos);
> +
> +	/* We kill previous dmeventd rather rashly. */
> +	kill(pid, 9);
> +	unlink(DMEVENTD_PIDFILE);
> +}
> +
> static void usage(char *prog, FILE *file)
> {
> 	fprintf(file, "Usage:\n");
> @@ -1638,7 +1769,7 @@ int main(int argc, char *argv[])
> 	opterr = 0;
> 	optind = 0;
>
> -	while ((opt = getopt(argc, argv, "?fhVd")) != EOF) {
> +	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
> 		switch (opt) {
> 		case 'h':
> 			usage(argv[0], stdout);
> @@ -1646,6 +1777,9 @@ int main(int argc, char *argv[])
> 		case '?':
> 			usage(argv[0], stderr);
> 			exit(0);
> +		case 'R':
> +			_restart++;
> +			break;
> 		case 'f':
> 			_foreground++;
> 			break;
> @@ -1667,6 +1801,9 @@ int main(int argc, char *argv[])
> 	if (setenv("LANG", "C", 1))
> 		perror("Cannot set LANG to C");
>
> +	if (_restart)
> +		restart();
> +
> 	if (!_foreground)
> 		_daemonize();
>
> @@ -1706,6 +1843,9 @@ int main(int argc, char *argv[])
> 		kill(getppid(), SIGTERM);
> 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
>
> +	if (_initial_registrations)
> +		_process_initial_registrations();
> +
> 	while (!_exit_now) {
> 		_process_request(&fifos);
> 		_cleanup_unused_threads();
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/dmeventd.h new- 
> dmeventd-restart/daemons/dmeventd/dmeventd.h
> --- old-dmeventd-restart/daemons/dmeventd/dmeventd.h	2010-10-05  
> 12:44:15.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/dmeventd.h	2010-10-05  
> 12:44:16.000000000 +0200
> @@ -35,6 +35,7 @@ enum dm_event_command {
> 	DM_EVENT_CMD_SET_TIMEOUT,
> 	DM_EVENT_CMD_GET_TIMEOUT,
> 	DM_EVENT_CMD_HELLO,
> +	DM_EVENT_CMD_GET_STATUS,
> };
>
> /* Message passed between client and daemon. */
> @@ -63,4 +64,12 @@ struct dm_event_fifos {
> #define EXIT_FIFO_FAILURE        6
> #define EXIT_CHDIR_FAILURE       7
>
> +/* Implemented in libdevmapper-event.c, but not part of public API.  
> */
> +int daemon_talk(struct dm_event_fifos *fifos,
> +		struct dm_event_daemon_message *msg, int cmd,
> +		const char *dso_name, const char *dev_name,
> +		enum dm_event_mask evmask, uint32_t timeout);
> +int init_fifos(struct dm_event_fifos *fifos);
> +void fini_fifos(struct dm_event_fifos *fifos);
> +
> #endif /* __DMEVENTD_DOT_H__ */
> diff -rN -u -p old-dmeventd-restart/daemons/ 
> dmeventd/.exported_symbols new-dmeventd-restart/daemons/ 
> dmeventd/.exported_symbols
> --- old-dmeventd-restart/daemons/dmeventd/.exported_symbols	 
> 2010-10-05 12:44:15.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/.exported_symbols	 
> 2010-10-05 12:44:16.000000000 +0200
> @@ -0,0 +1,3 @@
> +init_fifos
> +fini_fifos
> +daemon_talk
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/libdevmapper- 
> event.c new-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c
> --- old-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c	 
> 2010-10-05 12:44:15.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c	 
> 2010-10-05 12:44:16.000000000 +0200
> @@ -276,7 +276,6 @@ static int _daemon_read(struct dm_event_
> 		dm_free(msg->data);
> 		msg->data = NULL;
> 	}
> -
> 	return bytes == size;
> }
>
> @@ -341,13 +340,13 @@ static int _daemon_write(struct dm_event
> 	return bytes == size;
> }
>
> -static int _daemon_talk(struct dm_event_fifos *fifos,
> -			struct dm_event_daemon_message *msg, int cmd,
> -			const char *dso_name, const char *dev_name,
> -			enum dm_event_mask evmask, uint32_t timeout)
> +int daemon_talk(struct dm_event_fifos *fifos,
> +		struct dm_event_daemon_message *msg, int cmd,
> +		const char *dso_name, const char *dev_name,
> +		enum dm_event_mask evmask, uint32_t timeout)
> {
> -	const char *dso = dso_name ? dso_name : "";
> -	const char *dev = dev_name ? dev_name : "";
> +	const char *dso = dso_name ? dso_name : "-";
> +	const char *dev = dev_name ? dev_name : "-";
> 	const char *fmt = "%d:%d %s %s %u %" PRIu32;
> 	int msg_size;
> 	memset(msg, 0, sizeof(*msg));
> @@ -452,6 +451,7 @@ static int _start_daemon(char *dmeventd_
>
> 	else if (!pid) {
> 		execvp(args[0], args);
> +		log_error("Unable to exec dmeventd: %s", strerror(errno));
> 		_exit(EXIT_FAILURE);
> 	} else {
> 		if (waitpid(pid, &status, 0) < 0)
> @@ -466,24 +466,15 @@ static int _start_daemon(char *dmeventd_
> 	return ret;
> }
>
> -/* Initialize client. */
> -static int _init_client(char *dmeventd_path, struct dm_event_fifos  
> *fifos)
> +int init_fifos(struct dm_event_fifos *fifos)
> {
> 	/* FIXME? Is fifo the most suitable method? Why not share
> 	   comms/daemon code with something else e.g. multipath? */
>
> -	/* init fifos */
> -	memset(fifos, 0, sizeof(*fifos));
> -
> 	/* FIXME Make these either configurable or depend directly on  
> dmeventd_path */
> 	fifos->client_path = DM_EVENT_FIFO_CLIENT;
> 	fifos->server_path = DM_EVENT_FIFO_SERVER;
>
> -	if (!_start_daemon(dmeventd_path, fifos)) {
> -		stack;
> -		return 0;
> -	}
> -
> 	/* Open the fifo used to read from the daemon. */
> 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
> 		log_error("%s: open server fifo %s",
> @@ -511,7 +502,25 @@ static int _init_client(char *dmeventd_p
> 	return 1;
> }
>
> -static void _dtr_client(struct dm_event_fifos *fifos)
> +/* Initialize client. */
> +static int _init_client(char *dmeventd_path, struct dm_event_fifos  
> *fifos)
> +{
> +	/* init fifos */
> +	memset(fifos, 0, sizeof(*fifos));
> +
> +	/* FIXME Make these either configurable or depend directly on  
> dmeventd_path */
> +	fifos->client_path = DM_EVENT_FIFO_CLIENT;
> +	fifos->server_path = DM_EVENT_FIFO_SERVER;
> +
> +	if (!_start_daemon(dmeventd_path, fifos)) {
> +		stack;
> +		return 0;
> +	}
> +
> +	return init_fifos(fifos);
> +}
> +
> +void fini_fifos(struct dm_event_fifos *fifos)
> {
> 	if (flock(fifos->server, LOCK_UN))
> 		log_error("flock unlock %s", fifos->server_path);
> @@ -576,16 +585,16 @@ static int _do_event(int cmd, char *dmev
> 		return -ESRCH;
> 	}
>
> -	ret = _daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0);
> +	ret = daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0);
>
> 	dm_free(msg->data);
> 	msg->data = 0;
>
> 	if (!ret)
> -		ret = _daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask,  
> timeout);
> +		ret = daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask,  
> timeout);
>
> 	/* what is the opposite of init? */
> -	_dtr_client(&fifos);
> +	fini_fifos(&fifos);
>
> 	return ret;
> }
> diff -rN -u -p old-dmeventd-restart/test/t-dmeventd-restart.sh new- 
> dmeventd-restart/test/t-dmeventd-restart.sh
> --- old-dmeventd-restart/test/t-dmeventd-restart.sh	1970-01-01  
> 01:00:00.000000000 +0100
> +++ new-dmeventd-restart/test/t-dmeventd-restart.sh	2010-10-05  
> 12:44:16.000000000 +0200
> @@ -0,0 +1,32 @@
> +#!/bin/bash
> +# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
> +#
> +# This copyrighted material is made available to anyone wishing to  
> use,
> +# modify, copy, or redistribute it subject to the terms and  
> conditions
> +# of the GNU General Public License v.2.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software  
> Foundation,
> +# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> +
> +. ./test-utils.sh
> +
> +prepare_vg 5
> +prepare_dmeventd
> +
> +which mkfs.ext2 || exit 200
> +
> +lvcreate -m 3 --ig -L 1 -n 4way $vg
> +lvchange --monitor y $vg/4way
> +lvcreate -m 2 --ig -L 1 -n 3way $vg
> +lvchange --monitor y $vg/3way
> +
> +dmeventd -R -f &
> +LOCAL_DMEVENTD="$!"
> +
> +sleep 1 # wait a bit, so we talk to the new dmeventd later
> +
> +lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
> +grep 'already monitored' lvchange.out
> +lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
> +grep 'already monitored' lvchange.out
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


