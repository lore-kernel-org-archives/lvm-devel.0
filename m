From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Oct 2010 16:51:25 +0200
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <87bp77l8j2.fsf@twilight.int.mornfall.net.>
References: <87sk0kncit.fsf@twilight.int.mornfall.net.>	<BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>	<20101005234945.GG1200@agk-dp.fab.redhat.com>
	<87bp77l8j2.fsf@twilight.int.mornfall.net.>
Message-ID: <4CBDB06D.3010104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.10.2010 16:07, Petr Rockai napsal(a):
> Hi,
> 
> Alasdair G Kergon <agk@redhat.com> writes:
> 
>>>> >>> +	kill(pid, 9);
>> >
>> > I'm paranoid about code like that, and want to see everything reasonably
>> > possible done to ensure it can only kill the process it should and
>> > any possible races are clearly documented and defended against.
> the attached version avoids the kill, instead relying on the remote end
> committing suicide upon a special DIE message. It turns out to simplify
> the code as well, at the expense of having to modify the lock-file
> function slightly (it now tries a little harder, waiting for a couple
> seconds before failing, periodically re-trying to grab the lock). This
> also addresses some (all?) of the races.
> 

Source reading review - comments follow:



> dmeventd-restart.diff
> 
> 
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/dmeventd.c new-dmeventd-restart/daemons/dmeventd/dmeventd.c
> --- old-dmeventd-restart/daemons/dmeventd/dmeventd.c	2010-10-06 16:06:18.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/dmeventd.c	2010-10-06 16:06:18.000000000 +0200
> @@ -99,6 +99,8 @@ static pthread_mutex_t _global_mutex;
>  
>  int dmeventd_debug = 0;
>  static int _foreground = 0;
> +static int _restart = 0;
> +static char **_initial_registrations = 0;

these static are 0 by default.

>  
>  /* Data kept about a DSO. */
>  struct dso_data {
> @@ -444,6 +446,55 @@ static struct thread_status *_lookup_thr
>  	return NULL;
>  }
>  
> +static int _get_status(struct message_data *message_data)
> +{
> +	struct dm_event_daemon_message *msg = message_data->msg;
> +	struct thread_status *thread;
> +	int i = 0, j = 0;

,j;

(initialized later)

> +	int ret = -1;
> +	int count = dm_list_size(&_thread_registry);
> +	int size = 0, current = 0;
> +	char *buffers[count];

is this safe - i.e. cannot someone pass to long list here ?
maybe dm_malloc()

> +	char *message;
> +
> +	dm_free(msg->data);
> +
> +	_lock_mutex();
> +	dm_list_iterate_items(thread, &_thread_registry) {
> +		if ((current = dm_asprintf(buffers + i, "0:%d %s %s %u %" PRIu32 ";",
> +					   i, thread->dso_data->dso_name,
> +					   thread->device.uuid, thread->events,
> +					   thread->timeout)) < 0)


+unlock_mutex();

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


hmmm
order?


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


Maybe we could use fmemopen (eventually open_memstream()) for the code above?



> +}
> +
>  /* Cleanup at exit. */
>  static void _exit_dm_lib(void)
>  {
> @@ -1343,6 +1394,7 @@ static int _handle_request(struct dm_eve
>  		{ DM_EVENT_CMD_SET_TIMEOUT, _set_timeout},
>  		{ DM_EVENT_CMD_GET_TIMEOUT, _get_timeout},
>  		{ DM_EVENT_CMD_ACTIVE, _active},
> +		{ DM_EVENT_CMD_GET_STATUS, _get_status},
>  	}, *req;
>  
>  	for (req = requests; req < requests + sizeof(requests); req++)
> @@ -1362,11 +1414,12 @@ static int _do_process_request(struct dm
>  	/* Parse the message. */
>  	memset(&message_data, 0, sizeof(message_data));
>  	message_data.msg = msg;
> -	if (msg->cmd == DM_EVENT_CMD_HELLO)  {
> +	if (msg->cmd == DM_EVENT_CMD_HELLO || msg->cmd == DM_EVENT_CMD_DIE)  {
>  		ret = 0;
>  		answer = msg->data;
>  		if (answer) {
> -			msg->size = dm_asprintf(&(msg->data), "%s HELLO", answer);
> +			msg->size = dm_asprintf(&(msg->data), "%s %s", answer,
> +						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO");
>  			dm_free(answer);
>  		} else {
>  			msg->size = 0;
> @@ -1390,6 +1443,7 @@ static int _do_process_request(struct dm
>  /* Only one caller at a time. */
>  static void _process_request(struct dm_event_fifos *fifos)
>  {
> +	int die = 0;
>  	struct dm_event_daemon_message msg;
>  
>  	memset(&msg, 0, sizeof(msg));
> @@ -1401,6 +1455,9 @@ static void _process_request(struct dm_e
>  	if (!_client_read(fifos, &msg))
>  		return;
>  
> +	if (msg.cmd == DM_EVENT_CMD_DIE)
> +		die = 1;
> +
>  	/* _do_process_request fills in msg (if memory allows for
>  	   data, otherwise just cmd and size = 0) */
>  	_do_process_request(&msg);
> @@ -1408,9 +1465,26 @@ static void _process_request(struct dm_e
>  	if (!_client_write(fifos, &msg))
>  		stack;
>  
> +	if (die) raise(9);
> +
>  	dm_free(msg.data);
>  }
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
>  static void _cleanup_unused_threads(void)
>  {
>  	int ret;
> @@ -1616,6 +1690,55 @@ static void _daemonize(void)
>  	setsid();
>  }
>  
> +static void restart()
> +{
> +	struct dm_event_fifos fifos;
> +	struct dm_event_daemon_message msg = { 0, 0, NULL };
> +	int i, count = 0;
> +	char *message;
> +
> +	/* Get the list of registrations from the running daemon. */
> +
> +	if (!init_fifos(&fifos)) {
> +		fprintf(stderr, "Could not initiate communication with existing dmeventd.\n");
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)) {
> +		fprintf(stderr, "Could not communicate with existing dmeventd.\n");
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	message = msg.data;
> +	message = strchr(message, ' ');
> +	++ message;
> +	int length = strlen(msg.data);

declaration inside code;

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

looks like it could be easier to preallocate certain size - i.e. 16 array
elements and eventually reallocate if not enough - instead of this double
array scanning.



> +	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0)) {
> +		fprintf(stderr, "Old dmeventd refused to die.\n");
> +		exit(EXIT_FAILURE);
> +	}
> +
> +	fini_fifos(&fifos);
> +}
> +
>  static void usage(char *prog, FILE *file)
>  {
>  	fprintf(file, "Usage:\n");
> @@ -1638,7 +1761,7 @@ int main(int argc, char *argv[])
>  	opterr = 0;
>  	optind = 0;
>  
> -	while ((opt = getopt(argc, argv, "?fhVd")) != EOF) {
> +	while ((opt = getopt(argc, argv, "?fhVdR")) != EOF) {
>  		switch (opt) {
>  		case 'h':
>  			usage(argv[0], stdout);
> @@ -1646,6 +1769,9 @@ int main(int argc, char *argv[])
>  		case '?':
>  			usage(argv[0], stderr);
>  			exit(0);
> +		case 'R':
> +			_restart++;
> +			break;
>  		case 'f':
>  			_foreground++;
>  			break;
> @@ -1667,6 +1793,9 @@ int main(int argc, char *argv[])
>  	if (setenv("LANG", "C", 1))
>  		perror("Cannot set LANG to C");
>  
> +	if (_restart)
> +		restart();
> +
>  	if (!_foreground)
>  		_daemonize();
>  
> @@ -1706,6 +1835,9 @@ int main(int argc, char *argv[])
>  		kill(getppid(), SIGTERM);
>  	syslog(LOG_NOTICE, "dmeventd ready for processing.");
>  
> +	if (_initial_registrations)
> +		_process_initial_registrations();
> +
>  	while (!_exit_now) {
>  		_process_request(&fifos);
>  		_cleanup_unused_threads();
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/dmeventd.h new-dmeventd-restart/daemons/dmeventd/dmeventd.h
> --- old-dmeventd-restart/daemons/dmeventd/dmeventd.h	2010-10-06 16:06:18.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/dmeventd.h	2010-10-06 16:06:18.000000000 +0200
> @@ -35,6 +35,8 @@ enum dm_event_command {
>  	DM_EVENT_CMD_SET_TIMEOUT,
>  	DM_EVENT_CMD_GET_TIMEOUT,
>  	DM_EVENT_CMD_HELLO,
> +	DM_EVENT_CMD_DIE,
> +	DM_EVENT_CMD_GET_STATUS,
>  };
>  
>  /* Message passed between client and daemon. */
> @@ -63,4 +65,12 @@ struct dm_event_fifos {
>  #define EXIT_FIFO_FAILURE        6
>  #define EXIT_CHDIR_FAILURE       7
>  
> +/* Implemented in libdevmapper-event.c, but not part of public API. */
> +int daemon_talk(struct dm_event_fifos *fifos,
> +		struct dm_event_daemon_message *msg, int cmd,
> +		const char *dso_name, const char *dev_name,
> +		enum dm_event_mask evmask, uint32_t timeout);
> +int init_fifos(struct dm_event_fifos *fifos);
> +void fini_fifos(struct dm_event_fifos *fifos);
> +
>  #endif /* __DMEVENTD_DOT_H__ */
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/.exported_symbols new-dmeventd-restart/daemons/dmeventd/.exported_symbols
> --- old-dmeventd-restart/daemons/dmeventd/.exported_symbols	2010-10-06 16:06:18.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/.exported_symbols	2010-10-06 16:06:18.000000000 +0200
> @@ -0,0 +1,3 @@
> +init_fifos
> +fini_fifos
> +daemon_talk
> diff -rN -u -p old-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c new-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c
> --- old-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c	2010-10-06 16:06:18.000000000 +0200
> +++ new-dmeventd-restart/daemons/dmeventd/libdevmapper-event.c	2010-10-06 16:06:18.000000000 +0200
> @@ -276,7 +276,6 @@ static int _daemon_read(struct dm_event_
>  		dm_free(msg->data);
>  		msg->data = NULL;
>  	}
> -

Why ?

>  	return bytes == size;
>  }
>  
> @@ -341,13 +340,13 @@ static int _daemon_write(struct dm_event
>  	return bytes == size;
>  }
>  
> -static int _daemon_talk(struct dm_event_fifos *fifos,
> -			struct dm_event_daemon_message *msg, int cmd,
> -			const char *dso_name, const char *dev_name,
> -			enum dm_event_mask evmask, uint32_t timeout)
> +int daemon_talk(struct dm_event_fifos *fifos,
> +		struct dm_event_daemon_message *msg, int cmd,
> +		const char *dso_name, const char *dev_name,
> +		enum dm_event_mask evmask, uint32_t timeout)
>  {
> -	const char *dso = dso_name ? dso_name : "";
> -	const char *dev = dev_name ? dev_name : "";
> +	const char *dso = dso_name ? dso_name : "-";
> +	const char *dev = dev_name ? dev_name : "-";
>  	const char *fmt = "%d:%d %s %s %u %" PRIu32;
>  	int msg_size;
>  	memset(msg, 0, sizeof(*msg));
> @@ -452,6 +451,7 @@ static int _start_daemon(char *dmeventd_
>  
>  	else if (!pid) {
>  		execvp(args[0], args);
> +		log_error("Unable to exec dmeventd: %s", strerror(errno));
>  		_exit(EXIT_FAILURE);
>  	} else {
>  		if (waitpid(pid, &status, 0) < 0)
> @@ -466,24 +466,15 @@ static int _start_daemon(char *dmeventd_
>  	return ret;
>  }
>  
> -/* Initialize client. */
> -static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
> +int init_fifos(struct dm_event_fifos *fifos)
>  {
>  	/* FIXME? Is fifo the most suitable method? Why not share
>  	   comms/daemon code with something else e.g. multipath? */
>  
> -	/* init fifos */
> -	memset(fifos, 0, sizeof(*fifos));
> -
>  	/* FIXME Make these either configurable or depend directly on dmeventd_path */
>  	fifos->client_path = DM_EVENT_FIFO_CLIENT;
>  	fifos->server_path = DM_EVENT_FIFO_SERVER;
>  
> -	if (!_start_daemon(dmeventd_path, fifos)) {
> -		stack;
> -		return 0;

return_0;

> -	}
> -
>  	/* Open the fifo used to read from the daemon. */
>  	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
>  		log_error("%s: open server fifo %s",
> @@ -511,7 +502,25 @@ static int _init_client(char *dmeventd_p
>  	return 1;
>  }
>  
> -static void _dtr_client(struct dm_event_fifos *fifos)
> +/* Initialize client. */
> +static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
> +{
> +	/* init fifos */
> +	memset(fifos, 0, sizeof(*fifos));
> +
> +	/* FIXME Make these either configurable or depend directly on dmeventd_path */
> +	fifos->client_path = DM_EVENT_FIFO_CLIENT;
> +	fifos->server_path = DM_EVENT_FIFO_SERVER;
> +
> +	if (!_start_daemon(dmeventd_path, fifos)) {
> +		stack;
> +		return 0;

return_0;

> +	}
> +
> +	return init_fifos(fifos);
> +}
> +
> +void fini_fifos(struct dm_event_fifos *fifos)
>  {
>  	if (flock(fifos->server, LOCK_UN))
>  		log_error("flock unlock %s", fifos->server_path);
> @@ -576,16 +585,16 @@ static int _do_event(int cmd, char *dmev
>  		return -ESRCH;
>  	}
>  
> -	ret = _daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0);
> +	ret = daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
>  
>  	dm_free(msg->data);
>  	msg->data = 0;
>  
>  	if (!ret)
> -		ret = _daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
> +		ret = daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
>  
>  	/* what is the opposite of init? */
> -	_dtr_client(&fifos);
> +	fini_fifos(&fifos);
>  
>  	return ret;
>  }
> diff -rN -u -p old-dmeventd-restart/libdm/libdm-file.c new-dmeventd-restart/libdm/libdm-file.c
> --- old-dmeventd-restart/libdm/libdm-file.c	2010-10-06 16:06:18.000000000 +0200
> +++ new-dmeventd-restart/libdm/libdm-file.c	2010-10-06 16:06:18.000000000 +0200
> @@ -92,6 +92,7 @@ int dm_create_lockfile(const char *lockf
>  	ssize_t write_out;
>  	struct flock lock;
>  	char buffer[50];
> +	int retries = 0;
>  
>  	if((fd = open(lockfile, O_CREAT | O_WRONLY,
>  		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0) {
> @@ -112,9 +113,15 @@ retry_fcntl:
>  			break;
>  		case EACCES:
>  		case EAGAIN:
> -			log_error("Cannot lock lockfile [%s], error was [%s]",
> -				   lockfile, strerror(errno));
> -			break;
> +			if (retries == 20) {
> +				log_error("Cannot lock lockfile [%s], error was [%s]",
> +					  lockfile, strerror(errno));
> +				break;
> +			} else {
> +				++ retries;
> +				usleep(1000);
> +				goto retry_fcntl;
> +			}
>  		default:
>  			log_error("process is already running");
>  		}
> diff -rN -u -p old-dmeventd-restart/test/t-dmeventd-restart.sh new-dmeventd-restart/test/t-dmeventd-restart.sh
> --- old-dmeventd-restart/test/t-dmeventd-restart.sh	1970-01-01 01:00:00.000000000 +0100
> +++ new-dmeventd-restart/test/t-dmeventd-restart.sh	2010-10-06 16:06:18.000000000 +0200
> @@ -0,0 +1,32 @@
> +#!/bin/bash
> +# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
> +#
> +# This copyrighted material is made available to anyone wishing to use,
> +# modify, copy, or redistribute it subject to the terms and conditions
> +# of the GNU General Public License v.2.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software Foundation,
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
> 
>

Tested & passed

Zdenek


