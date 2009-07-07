From: Thomas Woerner <twoerner@redhat.com>
Date: Tue,  7 Jul 2009 22:20:01 +0200
Subject: [PATCH 2/2] Add error code for all log_err and log_error calls. Replace log_err with log_error.
In-Reply-To: <1246998001-17258-2-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
	<1246998001-17258-2-git-send-email-twoerner@redhat.com>
Message-ID: <1246998001-17258-3-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: twoerner <twoerner@redhat.com>

Fixed all log_error calls using the script.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 daemons/clvmd/clvmd-cman.c            |    8 +-
 daemons/clvmd/clvmd-command.c         |    2 +-
 daemons/clvmd/clvmd-gulm.c            |    4 +-
 daemons/clvmd/clvmd.c                 |   26 ++--
 daemons/clvmd/lvm-functions.c         |    8 +-
 daemons/dmeventd/libdevmapper-event.c |   50 ++++----
 lib/activate/activate.c               |   26 ++--
 lib/activate/dev_manager.c            |   64 +++++-----
 lib/activate/fs.c                     |   24 ++--
 lib/cache/lvmcache.c                  |   70 +++++-----
 lib/commands/toolcontext.c            |   86 ++++++------
 lib/config/config.c                   |   38 +++---
 lib/device/dev-cache.c                |   50 ++++----
 lib/device/dev-io.c                   |   22 ++--
 lib/device/dev-md.c                   |    8 +-
 lib/device/device.c                   |   12 +-
 lib/display/display.c                 |    4 +-
 lib/error/errseg.c                    |    2 +-
 lib/filters/filter-composite.c        |    4 +-
 lib/filters/filter-md.c               |    2 +-
 lib/filters/filter-persistent.c       |    6 +-
 lib/filters/filter-regex.c            |    4 +-
 lib/filters/filter-sysfs.c            |   10 +-
 lib/filters/filter.c                  |   10 +-
 lib/format1/disk-rep.c                |   30 ++--
 lib/format1/format1.c                 |   22 ++--
 lib/format1/import-export.c           |   22 ++--
 lib/format1/import-extents.c          |   24 ++--
 lib/format1/layout.c                  |   10 +-
 lib/format1/lvm1-label.c              |    4 +-
 lib/format_pool/disk_rep.c            |    4 +-
 lib/format_pool/format_pool.c         |   20 ++--
 lib/format_pool/import_export.c       |   14 +-
 lib/format_pool/pool_label.c          |    4 +-
 lib/format_text/archive.c             |   16 +-
 lib/format_text/archiver.c            |   32 +++---
 lib/format_text/export.c              |   12 +-
 lib/format_text/flags.c               |    8 +-
 lib/format_text/format-text.c         |   96 +++++++-------
 lib/format_text/import.c              |    2 +-
 lib/format_text/import_vsn1.c         |  120 ++++++++--------
 lib/format_text/tags.c                |    2 +-
 lib/format_text/text_label.c          |   16 +-
 lib/label/label.c                     |   14 +-
 lib/locking/cluster_locking.c         |   20 ++--
 lib/locking/external_locking.c        |    4 +-
 lib/locking/file_locking.c            |    6 +-
 lib/locking/locking.c                 |   18 ++--
 lib/locking/no_locking.c              |    2 +-
 lib/metadata/lv_manip.c               |  176 ++++++++++++------------
 lib/metadata/merge.c                  |   46 +++---
 lib/metadata/metadata.c               |  238 ++++++++++++++++----------------
 lib/metadata/mirror.c                 |  156 +++++++++++-----------
 lib/metadata/pv_manip.c               |   32 +++---
 lib/metadata/pv_map.c                 |    4 +-
 lib/metadata/segtype.c                |    2 +-
 lib/metadata/snapshot_manip.c         |    6 +-
 lib/mirror/mirrored.c                 |   34 +++---
 lib/misc/lvm-exec.c                   |    8 +-
 lib/misc/lvm-file.c                   |   16 +-
 lib/misc/lvm-string.c                 |    2 +-
 lib/misc/sharedlib.c                  |    4 +-
 lib/mm/memlock.c                      |    4 +-
 lib/report/report.c                   |   58 ++++----
 lib/snapshot/snapshot.c               |   14 +-
 lib/striped/striped.c                 |    8 +-
 lib/uuid/uuid.c                       |    8 +-
 lib/zero/zero.c                       |    2 +-
 libdm/ioctl/libdm-iface.c             |   94 +++++++-------
 libdm/libdm-common.c                  |   36 +++---
 libdm/libdm-deptree.c                 |  154 +++++++++++-----------
 libdm/libdm-file.c                    |    2 +-
 libdm/libdm-report.c                  |  104 +++++++-------
 libdm/mm/dbg_malloc.c                 |    8 +-
 libdm/mm/pool-debug.c                 |    8 +-
 libdm/mm/pool-fast.c                  |    6 +-
 libdm/mm/pool.c                       |    6 +-
 libdm/regex/matcher.c                 |    4 +-
 libdm/regex/parse_rx.c                |   10 +-
 liblvm/lvm_base.c                     |    2 +-
 old-tests/datastruct/hash_t.c         |    4 +-
 old-tests/dev-mgr/dev_cache_t.c       |    6 +-
 old-tests/device/dev_cache_t.c        |    6 +-
 old-tests/device/random.c             |    4 +-
 old-tests/filters/pfilter_t.c         |    4 +-
 old-tests/filters/rfilter_t.c         |    2 +-
 tools/dmsetup.c                       |   42 +++---
 tools/lvchange.c                      |  100 +++++++-------
 tools/lvconvert.c                     |  112 ++++++++--------
 tools/lvcreate.c                      |  156 +++++++++++-----------
 tools/lvdisplay.c                     |    6 +-
 tools/lvm.c                           |   10 +-
 tools/lvmcmdlib.c                     |    8 +-
 tools/lvmcmdline.c                    |   52 ++++----
 tools/lvmdiskscan.c                   |   10 +-
 tools/lvremove.c                      |    2 +-
 tools/lvrename.c                      |   18 ++--
 tools/lvresize.c                      |   68 +++++-----
 tools/lvscan.c                        |    2 +-
 tools/polldaemon.c                    |   16 +-
 tools/pvchange.c                      |   44 +++---
 tools/pvcreate.c                      |   58 ++++----
 tools/pvdisplay.c                     |   10 +-
 tools/pvmove.c                        |   64 +++++-----
 tools/pvremove.c                      |   20 ++--
 tools/pvresize.c                      |   28 ++--
 tools/pvscan.c                        |    4 +-
 tools/reporter.c                      |   10 +-
 tools/stub.h                          |    8 +-
 tools/toollib.c                       |  116 ++++++++--------
 tools/vgcfgbackup.c                   |    8 +-
 tools/vgcfgrestore.c                  |   10 +-
 tools/vgchange.c                      |   66 +++++-----
 tools/vgconvert.c                     |   38 +++---
 tools/vgcreate.c                      |   14 +-
 tools/vgdisplay.c                     |    8 +-
 tools/vgexport.c                      |    6 +-
 tools/vgextend.c                      |    6 +-
 tools/vgimport.c                      |    8 +-
 tools/vgmerge.c                       |    6 +-
 tools/vgreduce.c                      |   58 ++++----
 tools/vgremove.c                      |    4 +-
 tools/vgrename.c                      |   14 +-
 tools/vgscan.c                        |    4 +-
 tools/vgsplit.c                       |   28 ++--
 125 files changed, 1791 insertions(+), 1791 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index dec6331..b047095 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -157,7 +157,7 @@ static int _cluster_send_message(const void *buf, int msglen, const char *csid,
 
 	if (cman_send_data(c_handle, buf, msglen, 0, CLUSTER_PORT_CLVMD, nodeid) <= 0)
 	{
-		log_error("%s", errtext);
+		log_error(0, "%s", errtext);
 	}
 	return msglen;
 }
@@ -310,7 +310,7 @@ static void get_members()
 
 	num_nodes = cman_get_node_count(c_handle);
 	if (num_nodes == -1) {
-		log_error("Unable to get node count");
+		log_error(0, "Unable to get node count");
 		return;
 	}
 
@@ -324,14 +324,14 @@ static void get_members()
 		count_nodes = num_nodes + 10; /* Overallocate a little */
 		nodes = malloc(count_nodes * sizeof(struct cman_node));
 		if (!nodes) {
-			log_error("Unable to allocate nodes array\n");
+			log_error(0, "Unable to allocate nodes array\n");
 			exit(5);
 		}
 	}
 
 	status = cman_get_nodes(c_handle, count_nodes, &retnodes, nodes);
 	if (status < 0) {
-		log_error("Unable to get node details");
+		log_error(0, "Unable to get node details");
 		exit(6);
 	}
 
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 2266a2b..0b8aede 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -291,7 +291,7 @@ int do_pre_command(struct local_client *client)
 		break;
 
 	default:
-		log_error("Unknown command %d received\n", header->cmd);
+		log_error(0, "Unknown command %d received\n", header->cmd);
 		status = EINVAL;
 	}
 	return status;
diff --git a/daemons/clvmd/clvmd-gulm.c b/daemons/clvmd/clvmd-gulm.c
index 4bb1b65..3d75733 100644
--- a/daemons/clvmd/clvmd-gulm.c
+++ b/daemons/clvmd/clvmd-gulm.c
@@ -897,7 +897,7 @@ static int get_all_cluster_nodes()
     ctree = ccs_force_connect(NULL, 1);
     if (ctree < 0)
     {
-	log_error("Error connecting to CCS");
+	log_error(0, "Error connecting to CCS");
 	return -1;
     }
 
@@ -950,7 +950,7 @@ static int get_all_cluster_nodes()
 		}
 		else {
 			DEBUGLOG("Cannot resolve host name %s\n", nodename);
-			log_err("Cannot resolve host name %s\n", nodename);
+			log_error(0, "Cannot resolve host name %s\n", nodename);
 		}
 	}
 	free(nodename);
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index b6c4034..a07242a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -429,7 +429,7 @@ int main(int argc, char *argv[])
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
-		log_error("Can't initialise cluster interface\n");
+		log_error(0, "Can't initialise cluster interface\n");
 		child_init_signal(DFAIL_CLUSTER_IF);
 	}
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
@@ -915,11 +915,11 @@ static void be_daemon(int timeout)
 	if (dup2(devnull, 0) < 0 || dup2(devnull, 1) < 0
 	    || dup2(devnull, 2) < 0) {
 		perror("Error setting terminal FDs to /dev/null");
-		log_error("Error setting terminal FDs to /dev/null: %m");
+		log_error(0, "Error setting terminal FDs to /dev/null: %m");
 		exit(5);
 	}
 	if (chdir("/")) {
-		log_error("Error setting current directory to /: %m");
+		log_error(0, "Error setting current directory to /: %m");
 		exit(6);
 	}
 
@@ -1280,7 +1280,7 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 	if (msg->cmd == CLVMD_CMD_GOAWAY) {
 
 		DEBUGLOG("Told to go away by %s\n", nodename);
-		log_error("Told to go away by %s\n", nodename);
+		log_error(0, "Told to go away by %s\n", nodename);
 		exit(99);
 	}
 
@@ -1482,7 +1482,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 			if (write_status < 0 &&
 			    (errno == EINTR || errno == EAGAIN))
 				continue;
-			log_error("Error sending to pipe: %m\n");
+			log_error(0, "Error sending to pipe: %m\n");
 			break;
 		} while(1);
 
@@ -1515,7 +1515,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 			if (write_status < 0 &&
 			    (errno == EINTR || errno == EAGAIN))
 				continue;
-			log_error("Error sending to pipe: %m\n");
+			log_error(0, "Error sending to pipe: %m\n");
 			break;
 		} while(1);
 next_pre:
@@ -1577,7 +1577,7 @@ static int process_reply(const struct clvm_header *msg, int msglen, const char *
 	if (!client) {
 		DEBUGLOG("Got message for unknown client 0x%x\n",
 			 msg->clientid);
-		log_error("Got message for unknown client 0x%x\n",
+		log_error(0, "Got message for unknown client 0x%x\n",
 			  msg->clientid);
 		return -1;
 	}
@@ -1739,7 +1739,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 			if (retry_cnt > MAX_RETRIES)
 			{
 				errno = saved_errno;
-				log_error("%s", errtext);
+				log_error(0, "%s", errtext);
 				errno = saved_errno;
 				break;
 			}
@@ -1763,7 +1763,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 
 					continue;
 				}
-				log_error("%s", errtext);
+				log_error(0, "%s", errtext);
 				break;
 			}
 			ptr += len;
@@ -1856,7 +1856,7 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 	if (msglen) {
 		cmd->msg = malloc(msglen);
 		if (!cmd->msg) {
-			log_error("Unable to allocate buffer space\n");
+			log_error(0, "Unable to allocate buffer space\n");
 			free(cmd);
 			return -1;
 		}
@@ -1924,7 +1924,7 @@ static int open_local_sock()
 		unlink(CLVMD_SOCKNAME);
 	local_socket = socket(PF_UNIX, SOCK_STREAM, 0);
 	if (local_socket < 0) {
-		log_error("Can't create local socket: %m");
+		log_error(0, "Can't create local socket: %m");
 		return -1;
 	}
 	/* Set Close-on-exec & non-blocking */
@@ -1935,12 +1935,12 @@ static int open_local_sock()
 	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
 	sockaddr.sun_family = AF_UNIX;
 	if (bind(local_socket, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
-		log_error("can't bind local socket: %m");
+		log_error(0, "can't bind local socket: %m");
 		close(local_socket);
 		return -1;
 	}
 	if (listen(local_socket, 1) != 0) {
-		log_error("listen local: %m");
+		log_error(0, "listen local: %m");
 		close(local_socket);
 		return -1;
 	}
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index ab90ea6..d29d390 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -467,7 +467,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (do_refresh_cache()) {
-			log_error("Updated config file invalid. Aborting.");
+			log_error(0, "Updated config file invalid. Aborting.");
 			return EINVAL;
 		}
 	}
@@ -755,10 +755,10 @@ static void check_config()
 		if (strstr(libname, "liblvm2clusterlock.so"))
 			return;
 
-		log_error("Incorrect LVM locking library specified in lvm.conf, cluster operations may not work.");
+		log_error(0, "Incorrect LVM locking library specified in lvm.conf, cluster operations may not work.");
 		return;
 	}
-	log_error("locking_type not set correctly in lvm.conf, cluster operations will not work.");
+	log_error(0, "locking_type not set correctly in lvm.conf, cluster operations will not work.");
 }
 
 /* Backups up the LVM metadata if it's changed */
@@ -776,7 +776,7 @@ void lvm_do_backup(const char *vgname)
 	if (vg && consistent)
 		check_current_backup(vg);
 	else
-		log_error("Error backing up metadata, can't find VG for group %s", vgname);
+		log_error(0, "Error backing up metadata, can't find VG for group %s", vgname);
 
 	vg_release(vg);
 	dm_pool_empty(cmd->mem);
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index ce0bb25..578caf7 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -190,7 +190,7 @@ static int _check_message_id(struct dm_event_daemon_message *msg)
 
 	if ((sscanf(msg->data, "%d:%d", &pid, &seq_nr) != 2) ||
 	    (pid != getpid()) || (seq_nr != _sequence_nr)) {
-		log_error("Ignoring out-of-sequence reply from dmeventd. "
+		log_error(0, "Ignoring out-of-sequence reply from dmeventd. "
 			  "Expected %d:%d but received %s", getpid(),
 			  _sequence_nr, msg->data);
 		return 0;
@@ -228,12 +228,12 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 			ret = select(fifos->server + 1, &fds, NULL, NULL,
 				     &tval);
 			if (ret < 0 && errno != EINTR) {
-				log_error("Unable to read from event server");
+				log_error(0, "Unable to read from event server");
 				return 0;
 			}
 		}
 		if (ret < 1) {
-			log_error("Unable to read from event server.");
+			log_error(0, "Unable to read from event server.");
 			return 0;
 		}
 
@@ -242,7 +242,7 @@ static int _daemon_read(struct dm_event_fifos *fifos,
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
 			else {
-				log_error("Unable to read from event server.");
+				log_error(0, "Unable to read from event server.");
 				return 0;
 			}
 		}
@@ -291,7 +291,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 		tval.tv_usec = 100;
 		ret = select(fifos->server + 1, &fds, NULL, NULL, &tval);
 		if ((ret < 0) && (errno != EINTR)) {
-			log_error("Unable to talk to event daemon");
+			log_error(0, "Unable to talk to event daemon");
 			return 0;
 		}
 		if (ret == 0)
@@ -306,7 +306,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 			FD_SET(fifos->client, &fds);
 			ret = select(fifos->client + 1, NULL, &fds, NULL, NULL);
 			if ((ret < 0) && (errno != EINTR)) {
-				log_error("Unable to talk to event daemon");
+				log_error(0, "Unable to talk to event daemon");
 				return 0;
 			}
 		} while (ret < 1);
@@ -317,7 +317,7 @@ static int _daemon_write(struct dm_event_fifos *fifos,
 			if ((errno == EINTR) || (errno == EAGAIN))
 				continue;
 			else {
-				log_error("Unable to talk to event daemon");
+				log_error(0, "Unable to talk to event daemon");
 				return 0;
 			}
 		}
@@ -348,7 +348,7 @@ static int _daemon_talk(struct dm_event_fifos *fifos,
 		fmt = "%d:%d HELLO";
 	if ((msg_size = dm_asprintf(&(msg->data), fmt, getpid(), _sequence_nr,
 				    dso, dev, evmask, timeout)) < 0) {
-		log_error("_daemon_talk: message allocation failed");
+		log_error(0, "_daemon_talk: message allocation failed");
 		return -ENOMEM;
 	}
 	msg->size = msg_size;
@@ -403,7 +403,7 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 		goto start_server;
 
 	if (!S_ISFIFO(statbuf.st_mode)) {
-		log_error("%s is not a fifo.", fifos->client_path);
+		log_error(0, "%s is not a fifo.", fifos->client_path);
 		return 0;
 	}
 
@@ -417,7 +417,7 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 	} else if (errno != ENXIO) {
 		/* problem */
 
-		log_error("%s: Can't open client fifo %s: %s",
+		log_error(0, "%s: Can't open client fifo %s: %s",
 			  __func__, fifos->client_path, strerror(errno));
 		stack;
 		return 0;
@@ -427,24 +427,24 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 	/* server is not running */
 
 	if (!strncmp(DMEVENTD_PATH, "/", 1) && stat(DMEVENTD_PATH, &statbuf)) {
-		log_error("Unable to find dmeventd.");
+		log_error(0, "Unable to find dmeventd.");
 		return_0;
 	}
 
 	pid = fork();
 
 	if (pid < 0)
-		log_error("Unable to fork.");
+		log_error(0, "Unable to fork.");
 
 	else if (!pid) {
 		execvp(DMEVENTD_PATH, NULL);
 		exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)
-			log_error("Unable to start dmeventd: %s",
+			log_error(0, "Unable to start dmeventd: %s",
 				  strerror(errno));
 		else if (WEXITSTATUS(status))
-			log_error("Unable to start dmeventd.");
+			log_error(0, "Unable to start dmeventd.");
 		else
 			ret = 1;
 	}
@@ -470,7 +470,7 @@ static int _init_client(struct dm_event_fifos *fifos)
 
 	/* Open the fifo used to read from the daemon. */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
-		log_error("%s: open server fifo %s",
+		log_error(0, "%s: open server fifo %s",
 			  __func__, fifos->server_path);
 		stack;
 		return 0;
@@ -478,14 +478,14 @@ static int _init_client(struct dm_event_fifos *fifos)
 
 	/* Lock out anyone else trying to do communication with the daemon. */
 	if (flock(fifos->server, LOCK_EX) < 0) {
-		log_error("%s: flock %s", __func__, fifos->server_path);
+		log_error(0, "%s: flock %s", __func__, fifos->server_path);
 		close(fifos->server);
 		return 0;
 	}
 
 /*	if ((fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK)) < 0) {*/
 	if ((fifos->client = open(fifos->client_path, O_RDWR | O_NONBLOCK)) < 0) {
-		log_error("%s: Can't open client fifo %s: %s",
+		log_error(0, "%s: Can't open client fifo %s: %s",
 			  __func__, fifos->client_path, strerror(errno));
 		close(fifos->server);
 		stack;
@@ -498,7 +498,7 @@ static int _init_client(struct dm_event_fifos *fifos)
 static void _dtr_client(struct dm_event_fifos *fifos)
 {
 	if (flock(fifos->server, LOCK_UN))
-		log_error("flock unlock %s", fifos->server_path);
+		log_error(0, "flock unlock %s", fifos->server_path);
 
 	close(fifos->client);
 	close(fifos->server);
@@ -511,7 +511,7 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 	struct dm_info info;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_get_device_info: dm_task creation for info failed");
+		log_error(0, "_get_device_info: dm_task creation for info failed");
 		return NULL;
 	}
 
@@ -526,17 +526,17 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 
 	/* FIXME Add name or uuid or devno to messages */
 	if (!dm_task_run(dmt)) {
-		log_error("_get_device_info: dm_task_run() failed");
+		log_error(0, "_get_device_info: dm_task_run() failed");
 		goto failed;
 	}
 
 	if (!dm_task_get_info(dmt, &info)) {
-		log_error("_get_device_info: failed to get info for device");
+		log_error(0, "_get_device_info: failed to get info for device");
 		goto failed;
 	}
 
 	if (!info.exists) {
-		log_error("_get_device_info: device not found");
+		log_error(0, "_get_device_info: device not found");
 		goto failed;
 	}
 
@@ -592,7 +592,7 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 
 	if ((err = _do_event(DM_EVENT_CMD_REGISTER_FOR_EVENT, &msg,
 			     dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
-		log_error("%s: event registration failed: %s",
+		log_error(0, "%s: event registration failed: %s",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
 		ret = 0;
@@ -622,7 +622,7 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 
 	if ((err = _do_event(DM_EVENT_CMD_UNREGISTER_FOR_EVENT, &msg,
 			    dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
-		log_error("%s: event deregistration failed: %s",
+		log_error(0, "%s: event deregistration failed: %s",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
 		ret = 0;
@@ -802,7 +802,7 @@ int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 			     0, 0))) {
 		char *p = _skip_string(msg.data, ' ');
 		if (!p) {
-			log_error("malformed reply from dmeventd '%s'\n",
+			log_error(0, "malformed reply from dmeventd '%s'\n",
 				  msg.data);
 			return -EIO;
 		}
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index aa75e5b..80df249 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -41,7 +41,7 @@ int lvm1_present(struct cmd_context *cmd)
 
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/global", cmd->proc_dir)
 	    < 0) {
-		log_error("LVM1 proc global snprintf failed");
+		log_error(0, "LVM1 proc global snprintf failed");
 		return 0;
 	}
 
@@ -60,7 +60,7 @@ int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 
 	if (seg->segtype->ops->modules_needed &&
 	    !seg->segtype->ops->modules_needed(mem, seg, modules)) {
-		log_error("module string allocation failed");
+		log_error(0, "module string allocation failed");
 		return 0;
 	}
 
@@ -78,7 +78,7 @@ int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 		if (snap_seg->segtype->ops->modules_needed &&
 		    !snap_seg->segtype->ops->modules_needed(mem, snap_seg,
 							    modules)) {
-			log_error("snap_seg module string allocation failed");
+			log_error(0, "snap_seg module string allocation failed");
 			return 0;
 		}
 	}
@@ -119,7 +119,7 @@ void set_activation(int act)
 	if (warned || !act)
 		return;
 
-	log_error("Compiled without libdevmapper support. "
+	log_error(0, "Compiled without libdevmapper support. "
 		  "Can't enable activation.");
 
 	warned = 1;
@@ -279,13 +279,13 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
-			log_error("Ignoring invalid string in config file "
+			log_error(0, "Ignoring invalid string in config file "
 				  "activation/volume_list");
 			continue;
 		}
 		str = cv->v.str;
 		if (!*str) {
-			log_error("Ignoring empty string in config file "
+			log_error(0, "Ignoring empty string in config file "
 				  "activation/volume_list");
 			continue;
 		}
@@ -294,7 +294,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		if (*str == '@') {
 			str++;
 			if (!*str) {
-				log_error("Ignoring empty tag in config file "
+				log_error(0, "Ignoring empty tag in config file "
 					  "activation/volume_list");
 				continue;
 			}
@@ -324,7 +324,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		/* vgname/lvname */
 		if (dm_snprintf(path, sizeof(path), "%s/%s", lv->vg->name,
 				 lv->name) < 0) {
-			log_error("dm_snprintf error from %s/%s", lv->vg->name,
+			log_error(0, "dm_snprintf error from %s/%s", lv->vg->name,
 				  lv->name);
 			continue;
 		}
@@ -400,7 +400,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	const char *argv[3];
 
 	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
-		log_error("module_present module name too long: %s",
+		log_error(0, "module_present module name too long: %s",
 			  target_name);
 		return 0;
 	}
@@ -771,7 +771,7 @@ int monitor_dev_for_events(struct cmd_context *cmd,
 				continue;
 			if (!monitor_dev_for_events(cmd, seg_lv(seg, s),
 						    monitor)) {
-				log_error("Failed to %smonitor %s",
+				log_error(0, "Failed to %smonitor %s",
 					  monitor ? "" : "un",
 					  seg_lv(seg, s)->name);
 				r = 0;
@@ -814,7 +814,7 @@ int monitor_dev_for_events(struct cmd_context *cmd,
 
 		/* FIXME specify events */
 		if (!monitor_fn(seg, 0)) {
-			log_error("%s/%s: %s segment monitoring function failed.",
+			log_error(0, "%s/%s: %s segment monitoring function failed.",
 				  lv->vg->name, lv->name, seg->segtype->name);
 			return 0;
 		}
@@ -1002,7 +1002,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	}
 
 	if (info.open_count && lv_is_visible(lv)) {
-		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
+		log_error(0, "LV %s/%s in use: not deactivating", lv->vg->name,
 			  lv->name);
 		goto out;
 	}
@@ -1073,7 +1073,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
-		log_error("Refusing activation of partial LV %s. Use --partial to override.",
+		log_error(0, "Refusing activation of partial LV %s. Use --partial to override.",
 			  lv->name);
 		goto_out;
 	}
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 87a5c69..53252dc 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -70,7 +70,7 @@ static char *_build_dlid(struct dm_pool *mem, const char *lvid, const char *laye
 	len = sizeof(UUID_PREFIX) + sizeof(union lvid) + strlen(layer);
 
 	if (!(dlid = dm_pool_alloc(mem, len))) {
-		log_error("_build_dlid: pool allocation failed for %" PRIsize_t
+		log_error(0, "_build_dlid: pool allocation failed for %" PRIsize_t
 			  " %s %s.", len, lvid, layer);
 		return NULL;
 	}
@@ -132,7 +132,7 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 
 	if (!with_open_count)
 		if (!dm_task_no_open_count(dmt))
-			log_error("Failed to disable open_count");
+			log_error(0, "Failed to disable open_count");
 
 	if (!dm_task_run(dmt))
 		goto_out;
@@ -165,7 +165,7 @@ int device_is_usable(dev_t dev)
 	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		log_error("Failed to allocate dm_task struct to check dev status");
+		log_error(0, "Failed to allocate dm_task struct to check dev status");
 		return 0;
 	}
 
@@ -173,7 +173,7 @@ int device_is_usable(dev_t dev)
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
-		log_error("Failed to get state of mapped device");
+		log_error(0, "Failed to get state of mapped device");
 		goto out;
 	}
 
@@ -241,7 +241,7 @@ int dev_manager_info(struct dm_pool *mem, const char *name,
 	const char *dlid;
 
 	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
-		log_error("dlid build failed for %s", lv->name);
+		log_error(0, "dlid build failed for %s", lv->name);
 		return 0;
 	}
 
@@ -266,7 +266,7 @@ static int _status_run(const char *name, const char *uuid,
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if (!dm_task_run(dmt))
 		goto_out;
@@ -353,7 +353,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if (!dm_task_run(dmt))
 		goto_out;
@@ -369,7 +369,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 					  &params);
 		if (lv) {
 			if (!(segh = dm_list_next(&lv->segments, segh))) {
-				log_error("Number of segments in active LV %s "
+				log_error(0, "Number of segments in active LV %s "
 					  "does not match metadata", lv->name);
 				goto out;
 			}
@@ -392,7 +392,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	} while (next);
 
 	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
-		log_error("Number of segments in active LV %s does not "
+		log_error(0, "Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
 	}
@@ -525,7 +525,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	/* FIXME dm_pool_free ? */
 
 	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL))) {
-		log_error("dlid build failed for %s", lv->name);
+		log_error(0, "dlid build failed for %s", lv->name);
 		return 0;
 	}
 
@@ -630,7 +630,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
 	if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
-		log_error("Failed to get info for %s [%s].", name, dlid);
+		log_error(0, "Failed to get info for %s [%s].", name, dlid);
 		return 0;
 	}
 
@@ -643,7 +643,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 * FIXME compare info.major with lv->major if multiple major support
 		 */
 		if (info.exists && (info.minor != lv->minor)) {
-			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
+			log_error(0, "Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
 				  "(%" PRIu32 ":%" PRIu32")",
 				  lv->name, lv->major, lv->minor, info.major, info.minor);
@@ -651,7 +651,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 		if (!info.exists && _info_by_dev(lv->major, lv->minor, &info2) &&
 		    info2.exists) {
-			log_error("The requested major:minor pair "
+			log_error(0, "The requested major:minor pair "
 				  "(%" PRIu32 ":%" PRIu32") is already used",
 				  lv->major, lv->minor);
 			return 0;
@@ -659,7 +659,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (info.exists && !dm_tree_add_dev(dtree, info.major, info.minor)) {
-		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
+		log_error(0, "Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);
 		return 0;
 	}
@@ -696,7 +696,7 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 	uint32_t s;
 
 	if (!(dtree = dm_tree_create())) {
-		log_error("Partial dtree creation failed for %s.", lv->name);
+		log_error(0, "Partial dtree creation failed for %s.", lv->name);
 		return NULL;
 	}
 
@@ -740,7 +740,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (segno < 0) {
-		log_error("_add_error_device called with bad segment");
+		log_error(0, "_add_error_device called with bad segment");
 		return_NULL;
 	}
 
@@ -815,7 +815,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 			dm_tree_node_add_target_area(node, NULL, dlid,
 							extent_size * seg_le(seg, s));
 		} else {
-			log_error("Internal error: Unassigned area found in LV %s.",
+			log_error(0, "Internal error: Unassigned area found in LV %s.",
 				  seg->lv->name);
 			return 0;
 		}
@@ -849,7 +849,7 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 	uint64_t size;
 
 	if (!(snap_seg = find_cow(lv))) {
-		log_error("Couldn't find snapshot for '%s'.", lv->name);
+		log_error(0, "Couldn't find snapshot for '%s'.", lv->name);
 		return 0;
 	}
 
@@ -874,7 +874,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 	uint64_t extent_size = seg->lv->vg->extent_size;
 
 	if (!seg->segtype->ops->add_target_line) {
-		log_error("_emit_target: Internal error: Can't handle "
+		log_error(0, "_emit_target: Internal error: Can't handle "
 			  "segment type %s", seg->segtype->name);
 		return 0;
 	}
@@ -909,7 +909,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	if (seg_present->segtype->ops->target_present &&
 	    !seg_present->segtype->ops->target_present(seg_present->lv->vg->cmd,
 						       seg_present, NULL)) {
-		log_error("Can't expand LV %s: %s target support missing "
+		log_error(0, "Can't expand LV %s: %s target support missing "
 			  "from kernel?", seg->lv->name, seg_present->segtype->name);
 		return 0;
 	}
@@ -922,7 +922,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	/* If this is a snapshot origin, add real LV */
 	if (lv_is_origin(seg->lv) && !layer) {
 		if (vg_is_clustered(seg->lv->vg)) {
-			log_error("Clustered snapshots are not yet supported");
+			log_error(0, "Clustered snapshots are not yet supported");
 			return 0;
 		}
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "real"))
@@ -980,7 +980,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
-		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv->name, layer);
+		log_error(0, "_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv->name, layer);
 		return 0;
 	}
 
@@ -1056,11 +1056,11 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 
 		if (name && lvlayer->old_name && *lvlayer->old_name && strcmp(name, lvlayer->old_name)) {
 			if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &old_vgname, &old_lvname, &old_layer)) {
-				log_error("_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
+				log_error(0, "_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
 				return 0;
 			}
 			if (!dm_split_lvm_name(dm->mem, name, &new_vgname, &new_lvname, &new_layer)) {
-				log_error("_create_lv_symlinks: Couldn't split up new device name %s", name);
+				log_error(0, "_create_lv_symlinks: Couldn't split up new device name %s", name);
 				return 0;
 			}
 			if (!fs_rename_lv(lvlayer->lv, name, old_vgname, old_lvname))
@@ -1123,7 +1123,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root)
 			continue;
 
 		if (!dm_split_lvm_name(dm->mem, name, &vgname, &lvname, &layer)) {
-			log_error("_clean_tree: Couldn't split up device name %s.", name);
+			log_error(0, "_clean_tree: Couldn't split up device name %s.", name);
 			return 0;
 		}
 
@@ -1149,7 +1149,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		return_0;
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
-		log_error("Lost dependency tree root node");
+		log_error(0, "Lost dependency tree root node");
 		goto out;
 	}
 
@@ -1168,7 +1168,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		if (!dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
 		if (!_remove_lv_symlinks(dm, root))
-			log_error("Failed to remove all device symlinks associated with %s.", lv->name);
+			log_error(0, "Failed to remove all device symlinks associated with %s.", lv->name);
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
@@ -1196,12 +1196,12 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 			goto_out;
 
 		if (!_create_lv_symlinks(dm, root)) {
-			log_error("Failed to create symlinks for %s.", lv->name);
+			log_error(0, "Failed to create symlinks for %s.", lv->name);
 			goto out;
 		}
 		break;
 	default:
-		log_error("_tree_action: Action %u not supported.", action);
+		log_error(0, "_tree_action: Action %u not supported.", action);
 		goto out;
 	}	
 
@@ -1268,12 +1268,12 @@ int dev_manager_device_uses_vg(struct device *dev,
 	int r = 1;
 
 	if (!(dtree = dm_tree_create())) {
-		log_error("partial dtree creation failed");
+		log_error(0, "partial dtree creation failed");
 		return r;
 	}
 
 	if (!dm_tree_add_dev(dtree, (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev))) {
-		log_error("Failed to add device %s (%" PRIu32 ":%" PRIu32") to dtree",
+		log_error(0, "Failed to add device %s (%" PRIu32 ":%" PRIu32") to dtree",
 			  dev_name(dev), (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev));
 		goto out;
 	}
@@ -1282,7 +1282,7 @@ int dev_manager_device_uses_vg(struct device *dev,
 	memcpy(dlid + sizeof(UUID_PREFIX) - 1, &vg->id.uuid[0], sizeof(vg->id));
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
-		log_error("Lost dependency tree root node");
+		log_error(0, "Lost dependency tree root node");
 		goto out;
 	}
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 6b83581..8b65935 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -32,7 +32,7 @@ static int _mk_dir(const char *dev_dir, const char *vg_name)
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
-		log_error("Couldn't construct name of volume "
+		log_error(0, "Couldn't construct name of volume "
 			  "group directory.");
 		return 0;
 	}
@@ -55,7 +55,7 @@ static int _rm_dir(const char *dev_dir, const char *vg_name)
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
-		log_error("Couldn't construct name of volume "
+		log_error(0, "Couldn't construct name of volume "
 			  "group directory.");
 		return 0;
 	}
@@ -88,7 +88,7 @@ static void _rm_blks(const char *dir)
 			continue;
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir, name) == -1) {
-			log_error("Couldn't create path for %s", name);
+			log_error(0, "Couldn't create path for %s", name);
 			continue;
 		}
 
@@ -111,28 +111,28 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
-		log_error("Couldn't create path for volume group dir %s",
+		log_error(0, "Couldn't create path for volume group dir %s",
 			  vg_name);
 		return 0;
 	}
 
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s/%s", vg_path,
 			 lv_name) == -1) {
-		log_error("Couldn't create source pathname for "
+		log_error(0, "Couldn't create source pathname for "
 			  "logical volume link %s", lv_name);
 		return 0;
 	}
 
 	if (dm_snprintf(link_path, sizeof(link_path), "%s/%s",
 			 dm_dir(), dev) == -1) {
-		log_error("Couldn't create destination pathname for "
+		log_error(0, "Couldn't create destination pathname for "
 			  "logical volume link for %s", lv_name);
 		return 0;
 	}
 
 	if (dm_snprintf(lvm1_group_path, sizeof(lvm1_group_path), "%s/group",
 			 vg_path) == -1) {
-		log_error("Couldn't create pathname for LVM1 group file for %s",
+		log_error(0, "Couldn't create pathname for LVM1 group file for %s",
 			  vg_name);
 		return 0;
 	}
@@ -143,7 +143,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 	 * (as well as any existing LVM2 symlink). */
 	if (!lstat(lvm1_group_path, &buf)) {
 		if (!S_ISCHR(buf.st_mode)) {
-			log_error("Non-LVM1 character device found at %s",
+			log_error(0, "Non-LVM1 character device found at %s",
 				  lvm1_group_path);
 		} else {
 			_rm_blks(vg_path);
@@ -156,7 +156,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 
 	if (!lstat(lv_path, &buf)) {
 		if (!S_ISLNK(buf.st_mode) && !S_ISBLK(buf.st_mode)) {
-			log_error("Symbolic link %s not created: file exists",
+			log_error(0, "Symbolic link %s not created: file exists",
 				  link_path);
 			return 0;
 		}
@@ -190,14 +190,14 @@ static int _rm_link(const char *dev_dir, const char *vg_name,
 
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s",
 			 dev_dir, vg_name, lv_name) == -1) {
-		log_error("Couldn't determine link pathname.");
+		log_error(0, "Couldn't determine link pathname.");
 		return 0;
 	}
 
 	if (lstat(lv_path, &buf) || !S_ISLNK(buf.st_mode)) {
 		if (errno == ENOENT)
 			return 1;
-		log_error("%s not symbolic link - not removing", lv_path);
+		log_error(0, "%s not symbolic link - not removing", lv_path);
 		return 0;
 	}
 
@@ -273,7 +273,7 @@ static int _stack_fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 	char *pos;
 
 	if (!(fsp = dm_malloc(sizeof(*fsp) + len))) {
-		log_error("No space to stack fs operation");
+		log_error(0, "No space to stack fs operation");
 		return 0;
 	}
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 94954b2..043b77e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -189,16 +189,16 @@ void lvmcache_drop_metadata(const char *vgname)
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
+		log_error(0, "Internal cache initialisation failed");
 		return;
 	}
 
 	if (dm_hash_lookup(_lock_hash, vgname))
-		log_error("Internal error: Nested locking attempted on VG %s.",
+		log_error(0, "Internal error: Nested locking attempted on VG %s.",
 			  vgname);
 		
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
-		log_error("Cache locking failure for %s", vgname);
+		log_error(0, "Cache locking failure for %s", vgname);
 
 	_update_cache_lock_state(vgname, 1);
 
@@ -217,7 +217,7 @@ int vgname_is_locked(const char *vgname)
 void lvmcache_unlock_vgname(const char *vgname)
 {
 	if (!dm_hash_lookup(_lock_hash, vgname))
-		log_error("Internal error: Attempt to unlock unlocked VG %s.",
+		log_error(0, "Internal error: Attempt to unlock unlocked VG %s.",
 			  vgname);
 
 	_update_cache_lock_state(vgname, 0);
@@ -295,7 +295,7 @@ const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
 	dm_list_init(&devs);
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(devl = dm_malloc(sizeof(*devl)))) {
-			log_error("device_list element allocation failed");
+			log_error(0, "device_list element allocation failed");
 			return NULL;
 		}
 		devl->dev = info->dev;
@@ -451,7 +451,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	_scanning_in_progress = 1;
 
 	if (!_vgname_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
+		log_error(0, "Internal cache initialisation failed");
 		goto out;
 	}
 
@@ -461,7 +461,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	}
 
 	if (!(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
-		log_error("dev_iter creation failed");
+		log_error(0, "dev_iter creation failed");
 		goto out;
 	}
 
@@ -540,14 +540,14 @@ struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
 	lvmcache_label_scan(cmd, full_scan);
 
 	if (!(vgids = str_list_create(cmd->mem))) {
-		log_error("vgids list allocation failed");
+		log_error(0, "vgids list allocation failed");
 		return NULL;
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!str_list_add(cmd->mem, vgids,
 				  dm_pool_strdup(cmd->mem, vginfo->vgid))) {
-			log_error("strlist allocation failed");
+			log_error(0, "strlist allocation failed");
 			return NULL;
 		}
 	}
@@ -563,14 +563,14 @@ struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
 	lvmcache_label_scan(cmd, full_scan);
 
 	if (!(vgnames = str_list_create(cmd->mem))) {
-		log_error("vgnames list allocation failed");
+		log_error(0, "vgnames list allocation failed");
 		return NULL;
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
-			log_error("strlist allocation failed");
+			log_error(0, "strlist allocation failed");
 			return NULL;
 		}
 	}
@@ -586,7 +586,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 	struct lvmcache_info *info;
 
 	if (!(pvids = str_list_create(cmd->mem))) {
-		log_error("pvids list allocation failed");
+		log_error(0, "pvids list allocation failed");
 		return NULL;
 	}
 
@@ -596,7 +596,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!str_list_add(cmd->mem, pvids,
 				  dm_pool_strdup(cmd->mem, info->dev->pvid))) {
-			log_error("strlist allocation failed");
+			log_error(0, "strlist allocation failed");
 			return NULL;
 		}
 	}
@@ -659,7 +659,7 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 		dm_hash_remove(_vgname_hash, vginfo->vgname);
 		if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
 						    vginfo->next)) {
-			log_error("_vgname_hash re-insertion for %s failed",
+			log_error(0, "_vgname_hash re-insertion for %s failed",
 				  vginfo->vgname);
 			r = 0;
 		}
@@ -733,7 +733,7 @@ static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
 	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
 	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
-		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
+		log_error(0, "_lvmcache_update: pvid insertion failed: %s", pvid);
 		return 0;
 	}
 
@@ -761,7 +761,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 	strncpy(vginfo->vgid, vgid, ID_LEN);
 	vginfo->vgid[ID_LEN] = '\0';
 	if (!dm_hash_insert(_vgid_hash, vginfo->vgid, vginfo)) {
-		log_error("_lvmcache_update: vgid hash insertion failed: %s",
+		log_error(0, "_lvmcache_update: vgid hash insertion failed: %s",
 			  vginfo->vgid);
 		return 0;
 	}
@@ -802,13 +802,13 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 		 */
 		if (!(primary_vginfo->status & EXPORTED_VG) &&
 		    (vgstatus & EXPORTED_VG))
-			log_error("WARNING: Duplicate VG name %s: "
+			log_error(0, "WARNING: Duplicate VG name %s: "
 				  "Existing %s takes precedence over "
 				  "exported %s", new_vginfo->vgname,
 				  uuid_primary, uuid_new);
 		else if ((primary_vginfo->status & EXPORTED_VG) &&
 			   !(vgstatus & EXPORTED_VG)) {
-			log_error("WARNING: Duplicate VG name %s: "
+			log_error(0, "WARNING: Duplicate VG name %s: "
 				  "%s takes precedence over exported %s",
 				  new_vginfo->vgname, uuid_new,
 				  uuid_primary);
@@ -816,12 +816,12 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 		} else if (primary_vginfo->creation_host &&
 			   !strcmp(primary_vginfo->creation_host,
 				   primary_vginfo->fmt->cmd->hostname))
-			log_error("WARNING: Duplicate VG name %s: "
+			log_error(0, "WARNING: Duplicate VG name %s: "
 				  "Existing %s (created here) takes precedence "
 				  "over %s", new_vginfo->vgname, uuid_primary,
 				  uuid_new);
 		else if (!primary_vginfo->creation_host && creation_host) {
-			log_error("WARNING: Duplicate VG name %s: "
+			log_error(0, "WARNING: Duplicate VG name %s: "
 				  "%s (with creation_host) takes precedence over %s",
 				  new_vginfo->vgname, uuid_new,
 				  uuid_primary);
@@ -829,7 +829,7 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 		} else if (creation_host &&
 			   !strcmp(creation_host,
 				   primary_vginfo->fmt->cmd->hostname)) {
-			log_error("WARNING: Duplicate VG name %s: "
+			log_error(0, "WARNING: Duplicate VG name %s: "
 				  "%s (created here) takes precedence over %s",
 				  new_vginfo->vgname, uuid_new,
 				  uuid_primary);
@@ -847,7 +847,7 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 	}
 
 	if (!dm_hash_insert(_vgname_hash, new_vginfo->vgname, new_vginfo)) {
-		log_error("cache_update: vg hash insertion failed: %s",
+		log_error(0, "cache_update: vg hash insertion failed: %s",
 		  	new_vginfo->vgname);
 		return 0;
 	}
@@ -886,7 +886,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 				dm_hash_remove(_vgname_hash, old_vginfo->vgname);
 				if (old_vginfo->next) {
 					if (!dm_hash_insert(_vgname_hash, old_vginfo->vgname, old_vginfo->next)) {
-						log_error("vg hash re-insertion failed: %s",
+						log_error(0, "vg hash re-insertion failed: %s",
 							  old_vginfo->vgname);
 						return 0;
 					}
@@ -901,26 +901,26 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 
 			dm_free(vginfo->vgname);
 			if (!(vginfo->vgname = dm_strdup(vgname))) {
-				log_error("cache vgname alloc failed for %s", vgname);
+				log_error(0, "cache vgname alloc failed for %s", vgname);
 				return 0;
 			}
 
 			// Rename so can assume new name does not already exist
 			if (!dm_hash_insert(_vgname_hash, vginfo->vgname, vginfo->next)) {
-				log_error("vg hash re-insertion failed: %s",
+				log_error(0, "vg hash re-insertion failed: %s",
 					  vginfo->vgname);
 		      		return 0;
 			}
 		} else {
 ***/
 		if (!(vginfo = dm_malloc(sizeof(*vginfo)))) {
-			log_error("lvmcache_update_vgname: list alloc failed");
+			log_error(0, "lvmcache_update_vgname: list alloc failed");
 			return 0;
 		}
 		memset(vginfo, 0, sizeof(*vginfo));
 		if (!(vginfo->vgname = dm_strdup(vgname))) {
 			dm_free(vginfo);
-			log_error("cache vgname alloc failed for %s", vgname);
+			log_error(0, "cache vgname alloc failed for %s", vgname);
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
@@ -1013,7 +1013,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 		dm_free(info->vginfo->creation_host);
 
 	if (!(info->vginfo->creation_host = dm_strdup(creation_host))) {
-		log_error("cache creation host alloc failed for %s",
+		log_error(0, "cache creation host alloc failed for %s",
 			  creation_host);
 		return 0;
 	}
@@ -1027,7 +1027,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 {
 	if (!_lock_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
+		log_error(0, "Internal cache initialisation failed");
 		return 0;
 	}
 
@@ -1039,7 +1039,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  uint32_t vgstatus, const char *creation_host)
 {
 	if (!vgname && !info->vginfo) {
-		log_error("Internal error: NULL vgname handed to cache");
+		log_error(0, "Internal error: NULL vgname handed to cache");
 		/* FIXME Remove this */
 		vgname = info->fmt->orphan_vg_name;
 		vgid = vgname;
@@ -1098,7 +1098,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	char pvid_s[ID_LEN + 1] __attribute((aligned(8)));
 
 	if (!_vgname_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
+		log_error(0, "Internal cache initialisation failed");
 		return NULL;
 	}
 
@@ -1110,7 +1110,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		if (!(label = label_create(labeller)))
 			return_NULL;
 		if (!(info = dm_malloc(sizeof(*info)))) {
-			log_error("lvmcache_info allocation failed");
+			log_error(0, "lvmcache_info allocation failed");
 			label_destroy(label);
 			return NULL;
 		}
@@ -1154,7 +1154,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
 			else if (!strcmp(pvid_s, existing->dev->pvid)) 
-				log_error("Found duplicate PV %s: using %s not "
+				log_error(0, "Found duplicate PV %s: using %s not "
 					  "%s", pvid, dev_name(dev),
 					  dev_name(existing->dev));
 		}
@@ -1231,7 +1231,7 @@ static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 	if (!strcmp(vgname, VG_GLOBAL))
 		_vg_global_lock_held = 1;
 	else
-		log_error("Internal error: Volume Group %s was not unlocked",
+		log_error(0, "Internal error: Volume Group %s was not unlocked",
 			  dm_hash_get_key(_lock_hash, n));
 }
 
@@ -1268,7 +1268,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 	}
 
 	if (!dm_list_empty(&_vginfos))
-		log_error("Internal error: _vginfos list should be empty");
+		log_error(0, "Internal error: _vginfos list should be empty");
 	dm_list_init(&_vginfos);
 
 	if (retain_orphans)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 12b881b..ad17283 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -66,7 +66,7 @@ static int _get_env_vars(struct cmd_context *cmd)
 	if ((e = getenv("LVM_SYSTEM_DIR"))) {
 		if (dm_snprintf(cmd->system_dir, sizeof(cmd->system_dir),
 				 "%s", e) < 0) {
-			log_error("LVM_SYSTEM_DIR environment variable "
+			log_error(0, "LVM_SYSTEM_DIR environment variable "
 				  "is too long.");
 			return 0;
 		}
@@ -90,7 +90,7 @@ static void _get_sysfs_dir(struct cmd_context *cmd)
 
 	if (dm_snprintf(proc_mounts, sizeof(proc_mounts),
 			 "%s/mounts", cmd->proc_dir) < 0) {
-		log_error("Failed to create /proc/mounts string for sysfs detection");
+		log_error(0, "Failed to create /proc/mounts string for sysfs detection");
 		return;
 	}
 
@@ -111,7 +111,7 @@ static void _get_sysfs_dir(struct cmd_context *cmd)
 		log_sys_error("fclose", proc_mounts);
 
 	if (!sys_mnt) {
-		log_error("Failed to find sysfs mount point");
+		log_error(0, "Failed to find sysfs mount point");
 		return;
 	}
 
@@ -213,7 +213,7 @@ static int _process_config(struct cmd_context *cmd)
 	if (dm_snprintf(cmd->dev_dir, sizeof(cmd->dev_dir), "%s/",
 			 find_config_tree_str(cmd, "devices/dir",
 					 DEFAULT_DEV_DIR)) < 0) {
-		log_error("Device directory given in config file too long");
+		log_error(0, "Device directory given in config file too long");
 		return 0;
 	}
 #ifdef DEVMAPPER_SUPPORT
@@ -224,12 +224,12 @@ static int _process_config(struct cmd_context *cmd)
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
 			 find_config_tree_str(cmd, "global/proc",
 					 DEFAULT_PROC_DIR)) < 0) {
-		log_error("Device directory given in config file too long");
+		log_error(0, "Device directory given in config file too long");
 		return 0;
 	}
 
 	if (*cmd->proc_dir && !dir_exists(cmd->proc_dir)) {
-		log_error("WARNING: proc dir %s not found - some checks will be bypassed",
+		log_error(0, "WARNING: proc dir %s not found - some checks will be bypassed",
 			  cmd->proc_dir);
 		cmd->proc_dir[0] = '\0';
 	}
@@ -251,7 +251,7 @@ static int _process_config(struct cmd_context *cmd)
 					     "global/units",
 					     DEFAULT_UNITS),
 			     &cmd->default_settings.unit_type))) {
-		log_error("Invalid units specification");
+		log_error(0, "Invalid units specification");
 		return 0;
 	}
 
@@ -261,7 +261,7 @@ static int _process_config(struct cmd_context *cmd)
 	else if (!strcasecmp(read_ahead, "none"))
 		cmd->default_settings.read_ahead = DM_READ_AHEAD_NONE;
 	else {
-		log_error("Invalid readahead specification");
+		log_error(0, "Invalid readahead specification");
 		return 0;
 	}
 
@@ -297,7 +297,7 @@ static int _set_tag(struct cmd_context *cmd, const char *tag)
 	log_very_verbose("Setting host tag: %s", dm_pool_strdup(cmd->libmem, tag));
 
 	if (!str_list_add(cmd->libmem, &cmd->tags, tag)) {
-		log_error("_set_tag: str_list_add %s failed", tag);
+		log_error(0, "_set_tag: str_list_add %s failed", tag);
 		return 0;
 	}
 
@@ -321,7 +321,7 @@ static int _check_host_filters(struct cmd_context *cmd, struct config_node *hn,
 				continue;
 			for (cv = cn->v; cv; cv = cv->next) {
 				if (cv->type != CFG_STRING) {
-					log_error("Invalid hostname string "
+					log_error(0, "Invalid hostname string "
 						  "for tag %s", cn->key);
 					return 0;
 				}
@@ -332,7 +332,7 @@ static int _check_host_filters(struct cmd_context *cmd, struct config_node *hn,
 			}
 		}
 		if (!strcmp(cn->key, "host_filter")) {
-			log_error("host_filter not supported yet");
+			log_error(0, "host_filter not supported yet");
 			return 0;
 		}
 	}
@@ -365,7 +365,7 @@ static int _init_tags(struct cmd_context *cmd, struct config_tree *cft)
 		if (*tag == '@')
 			tag++;
 		if (!validate_name(tag)) {
-			log_error("Invalid tag in config file: %s", cn->key);
+			log_error(0, "Invalid tag in config file: %s", cn->key);
 			return 0;
 		}
 		if (cn->child) {
@@ -394,17 +394,17 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 
 	if (dm_snprintf(config_file, sizeof(config_file), "%s/lvm%s%s.conf",
 			 cmd->system_dir, filler, tag) < 0) {
-		log_error("LVM_SYSTEM_DIR or tag was too long");
+		log_error(0, "LVM_SYSTEM_DIR or tag was too long");
 		return 0;
 	}
 
 	if (!(cfl = dm_pool_alloc(cmd->libmem, sizeof(*cfl)))) {
-		log_error("config_tree_list allocation failed");
+		log_error(0, "config_tree_list allocation failed");
 		return 0;
 	}
 
 	if (!(cfl->cft = create_config_tree(config_file, 0))) {
-		log_error("config_tree allocation failed");
+		log_error(0, "config_tree allocation failed");
 		return 0;
 	}
 
@@ -421,7 +421,7 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 
 	log_very_verbose("Loading config file: %s", config_file);
 	if (!read_config_file(cfl->cft)) {
-		log_error("Failed to load config file %s", config_file);
+		log_error(0, "Failed to load config file %s", config_file);
 		destroy_config_tree(cfl->cft);
 		return 0;
 	}
@@ -444,7 +444,7 @@ static int _init_lvm_conf(struct cmd_context *cmd)
 	/* No config file if LVM_SYSTEM_DIR is empty */
 	if (!*cmd->system_dir) {
 		if (!(cmd->cft = create_config_tree(NULL, 0))) {
-			log_error("Failed to create config tree");
+			log_error(0, "Failed to create config tree");
 			return 0;
 		}
 		return 1;
@@ -477,7 +477,7 @@ static int _merge_config_files(struct cmd_context *cmd)
 	/* Replace temporary duplicate copy of lvm.conf */
 	if (cmd->cft->root) {
 		if (!(cmd->cft = create_config_tree(NULL, 0))) {
-			log_error("Failed to create config tree");
+			log_error(0, "Failed to create config tree");
 			return 0;
 		}
 	}
@@ -540,7 +540,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
 		if (!dev_cache_add_dir("/dev")) {
-			log_error("Failed to add /dev to internal "
+			log_error(0, "Failed to add /dev to internal "
 				  "device cache");
 			return 0;
 		}
@@ -551,13 +551,13 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
-			log_error("Invalid string in config file: "
+			log_error(0, "Invalid string in config file: "
 				  "devices/scan");
 			return 0;
 		}
 
 		if (!dev_cache_add_dir(cv->v.str)) {
-			log_error("Failed to add %s to internal device cache",
+			log_error(0, "Failed to add %s to internal device cache",
 				  cv->v.str);
 			return 0;
 		}
@@ -568,13 +568,13 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
-			log_error("Invalid string in config file: "
+			log_error(0, "Invalid string in config file: "
 				  "devices/loopfiles");
 			return 0;
 		}
 
 		if (!dev_cache_add_loopfile(cv->v.str)) {
-			log_error("Failed to add loopfile %s to internal "
+			log_error(0, "Failed to add loopfile %s to internal "
 				  "device cache", cv->v.str);
 			return 0;
 		}
@@ -617,14 +617,14 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 				 "no regex filter installed");
 
 	else if (!(filters[nr_filt++] = regex_filter_create(cn->v))) {
-		log_error("Failed to create regex device filter");
+		log_error(0, "Failed to create regex device filter");
 		return NULL;
 	}
 
 	/* device type filter. Required. */
 	cn = find_config_tree_node(cmd, "devices/types");
 	if (!(filters[nr_filt++] = lvm_type_filter_create(cmd->proc_dir, cn))) {
-		log_error("Failed to create lvm type filter");
+		log_error(0, "Failed to create lvm type filter");
 		return NULL;
 	}
 
@@ -669,7 +669,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		    cache_dir ? "" : "/",
 		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
 		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
-			log_error("Persistent cache filename too long.");
+			log_error(0, "Persistent cache filename too long.");
 			return 0;
 		}
 	} else if (!(dev_cache = find_config_tree_str(cmd, "devices/cache", NULL)) &&
@@ -677,7 +677,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 				"%s/%s/%s.cache",
 				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
 				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
-		log_error("Persistent cache filename too long.");
+		log_error(0, "Persistent cache filename too long.");
 		return 0;
 	}
 
@@ -685,7 +685,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		dev_cache = cache_file;
 
 	if (!(f4 = persistent_filter_create(f3, dev_cache))) {
-		log_error("Failed to create persistent device filter");
+		log_error(0, "Failed to create persistent device filter");
 		return 0;
 	}
 
@@ -749,7 +749,7 @@ static int _init_formats(struct cmd_context *cmd)
 
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
-				log_error("Invalid string in config file: "
+				log_error(0, "Invalid string in config file: "
 					  "global/format_libraries");
 				return 0;
 			}
@@ -758,7 +758,7 @@ static int _init_formats(struct cmd_context *cmd)
 				return_0;
 
 			if (!(init_format_fn = dlsym(lib, "init_format"))) {
-				log_error("Shared library %s does not contain "
+				log_error(0, "Shared library %s does not contain "
 					  "format functions", cv->v.str);
 				dlclose(lib);
 				return 0;
@@ -791,7 +791,7 @@ static int _init_formats(struct cmd_context *cmd)
 		}
 	}
 
-	log_error("_init_formats: Default format (%s) not found", format);
+	log_error(0, "_init_formats: Default format (%s) not found", format);
 	return 0;
 }
 
@@ -860,7 +860,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
-				log_error("Invalid string in config file: "
+				log_error(0, "Invalid string in config file: "
 					  "global/segment_libraries");
 				return 0;
 			}
@@ -869,7 +869,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 				return_0;
 
 			if (!(init_segtype_fn = dlsym(lib, "init_segtype"))) {
-				log_error("Shared library %s does not contain "
+				log_error(0, "Shared library %s does not contain "
 					  "segment type functions", cv->v.str);
 				dlclose(lib);
 				return 0;
@@ -884,7 +884,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 				if ((segtype == segtype2) ||
 				     strcmp(segtype2->name, segtype->name))
 					continue;
-				log_error("Duplicate segment type %s: "
+				log_error(0, "Duplicate segment type %s: "
 					  "unloading shared library %s",
 					  segtype->name, cv->v.str);
 				dm_list_del(&segtype->list);
@@ -908,12 +908,12 @@ static int _init_hostname(struct cmd_context *cmd)
 	}
 
 	if (!(cmd->hostname = dm_pool_strdup(cmd->libmem, uts.nodename))) {
-		log_error("_init_hostname: dm_pool_strdup failed");
+		log_error(0, "_init_hostname: dm_pool_strdup failed");
 		return 0;
 	}
 
 	if (!(cmd->kernel_vsn = dm_pool_strdup(cmd->libmem, uts.release))) {
-		log_error("_init_hostname: dm_pool_strdup kernel_vsn failed");
+		log_error(0, "_init_hostname: dm_pool_strdup kernel_vsn failed");
 		return 0;
 	}
 
@@ -947,7 +947,7 @@ static int _init_backup(struct cmd_context *cmd)
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_ARCHIVE_SUBDIR) == -1) {
-		log_err("Couldn't create default archive path '%s/%s'.",
+		log_error(0, "Couldn't create default archive path '%s/%s'.",
 			cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
 		return 0;
 	}
@@ -969,7 +969,7 @@ static int _init_backup(struct cmd_context *cmd)
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_BACKUP_SUBDIR) == -1) {
-		log_err("Couldn't create default backup path '%s/%s'.",
+		log_error(0, "Couldn't create default backup path '%s/%s'.",
 			cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
 		return 0;
 	}
@@ -1019,7 +1019,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	init_syslog(DEFAULT_LOG_FACILITY);
 
 	if (!(cmd = dm_malloc(sizeof(*cmd)))) {
-		log_error("Failed to allocate command context");
+		log_error(0, "Failed to allocate command context");
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
@@ -1047,15 +1047,15 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 
 	/* Create system directory if it doesn't already exist */
 	if (*cmd->system_dir && !dm_create_dir(cmd->system_dir)) {
-		log_error("Failed to create LVM2 system dir for metadata backups, config "
+		log_error(0, "Failed to create LVM2 system dir for metadata backups, config "
 			  "files and internal cache.");
-		log_error("Set environment variable LVM_SYSTEM_DIR to alternative location "
+		log_error(0, "Set environment variable LVM_SYSTEM_DIR to alternative location "
 			  "or empty string.");
 		goto error;
 	}
 
 	if (!(cmd->libmem = dm_pool_create("library", 4 * 1024))) {
-		log_error("Library memory pool creation failed");
+		log_error(0, "Library memory pool creation failed");
 		goto error;
 	}
 
@@ -1086,7 +1086,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		goto error;
 
 	if (!(cmd->mem = dm_pool_create("command", 4 * 1024))) {
-		log_error("Command memory pool creation failed");
+		log_error(0, "Command memory pool creation failed");
 		goto error;
 	}
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 224f2ce..fb120eb 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -90,7 +90,7 @@ static const int sep = '/';
 
 #define match(t) do {\
    if (!_match_aux(p, (t))) {\
-	log_error("Parse error at byte %" PRIptrdiff_t " (line %d): unexpected token", \
+	log_error(0, "Parse error at byte %" PRIptrdiff_t " (line %d): unexpected token", \
 		  p->tb - p->fb + 1, p->line); \
       return 0;\
    } \
@@ -115,12 +115,12 @@ struct config_tree *create_config_tree(const char *filename, int keep_open)
 	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);
 
 	if (!mem) {
-		log_error("Failed to allocate config pool.");
+		log_error(0, "Failed to allocate config pool.");
 		return 0;
 	}
 
 	if (!(c = dm_pool_zalloc(mem, sizeof(*c)))) {
-		log_error("Failed to allocate config tree.");
+		log_error(0, "Failed to allocate config tree.");
 		dm_pool_destroy(mem);
 		return 0;
 	}
@@ -169,7 +169,7 @@ struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __att
 
 	c = (struct cs *) cft;
 	if (!(p = dm_pool_alloc(c->mem, sizeof(*p)))) {
-		log_error("Failed to allocate config tree parser.");
+		log_error(0, "Failed to allocate config tree parser.");
 		destroy_config_tree(cft);
 		return NULL;
 	}
@@ -228,7 +228,7 @@ int read_config_fd(struct config_tree *cft, struct device *dev,
 	if (checksum_fn && checksum !=
 	    (checksum_fn(checksum_fn(INITIAL_CRC, p->fb, size),
 			 p->fb + size, size2))) {
-		log_error("%s: Checksum error", dev_name(dev));
+		log_error(0, "%s: Checksum error", dev_name(dev));
 		goto out;
 	}
 
@@ -266,7 +266,7 @@ int read_config_file(struct config_tree *cft)
 	}
 
 	if (!S_ISREG(info.st_mode)) {
-		log_error("%s is not a regular file", c->filename);
+		log_error(0, "%s is not a regular file", c->filename);
 		c->exists = 0;
 		return 0;
 	}
@@ -327,12 +327,12 @@ int config_file_changed(struct config_tree *cft)
 			goto reload;
 		}
 		log_sys_error("stat", c->filename);
-		log_error("Failed to reload configuration files");
+		log_error(0, "Failed to reload configuration files");
 		return 0;
 	}
 
 	if (!S_ISREG(info.st_mode)) {
-		log_error("Configuration file %s is not a regular file",
+		log_error(0, "Configuration file %s is not a regular file",
 			  c->filename);
 		goto reload;
 	}
@@ -349,7 +349,7 @@ int config_file_changed(struct config_tree *cft)
 static int _line_start(struct output_line *outline)
 {
 	if (!dm_pool_begin_object(outline->mem, 128)) {
-		log_error("dm_pool_begin_object failed for config line");
+		log_error(0, "dm_pool_begin_object failed for config line");
 		return 0;
 	}
 
@@ -367,13 +367,13 @@ static int _line_append(struct output_line *outline, const char *fmt, ...)
 	va_start(ap, fmt);
 	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
 	if (n < 0 || n > (int) sizeof buf - 1) {
-		log_error("vsnprintf failed for config line");
+		log_error(0, "vsnprintf failed for config line");
 		return 0;
 	}
 	va_end(ap);
 
 	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
-		log_error("dm_pool_grow_object failed for config line");
+		log_error(0, "dm_pool_grow_object failed for config line");
 		return 0;
 	}
 
@@ -387,7 +387,7 @@ static int _line_end(struct output_line *outline)
 	const char *line;
 
 	if (!dm_pool_grow_object(outline->mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed for config line");
+		log_error(0, "dm_pool_grow_object failed for config line");
 		return 0;
 	}
 
@@ -407,7 +407,7 @@ static int _write_value(struct output_line *outline, struct config_value *v)
 	switch (v->type) {
 	case CFG_STRING:
 		if (!(buf = alloca(escaped_len(v->v.str)))) {
-			log_error("temporary stack allocation for a config "
+			log_error(0, "temporary stack allocation for a config "
 				  "string failed");
 			return 0;
 		}
@@ -427,7 +427,7 @@ static int _write_value(struct output_line *outline, struct config_value *v)
 		break;
 
 	default:
-		log_error("_write_value: Unknown value type: %d", v->type);
+		log_error(0, "_write_value: Unknown value type: %d", v->type);
 
 	}
 
@@ -507,17 +507,17 @@ int write_config_file(struct config_tree *cft, const char *file,
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
 		if (!_write_config(cft->root, 0, &outline, 0)) {
-			log_error("Failure while writing to %s", file);
+			log_error(0, "Failure while writing to %s", file);
 			r = 0;
 		}
 	} else while (argc--) {
 		if ((cn = find_config_node(cft->root, *argv))) {
 			if (!_write_config(cn, 1, &outline, 0)) {
-				log_error("Failure while writing to %s", file);
+				log_error(0, "Failure while writing to %s", file);
 				r = 0;
 			}
 		} else {
-			log_error("Configuration node %s not found", *argv);
+			log_error(0, "Configuration node %s not found", *argv);
 			r = 0;
 		}
 		argv++;
@@ -664,7 +664,7 @@ static struct config_value *_type(struct parser *p)
 		break;
 
 	default:
-		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
+		log_error(0, "Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
 			  p->tb - p->fb + 1, p->line);
 		return 0;
 	}
@@ -876,7 +876,7 @@ static struct config_node *_find_config_node(const struct config_node *cn,
 				if (!cn_found)
 					cn_found = cn;
 				else
-					log_error("WARNING: Ignoring duplicate"
+					log_error(0, "WARNING: Ignoring duplicate"
 						  " config node: %s ("
 						  "seeking %s)", cn->key, path);
 			}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index dd4ce6a..622dbd4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -61,16 +61,16 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 	if (allocate) {
 		if (use_malloc) {
 			if (!(dev = dm_malloc(sizeof(*dev)))) {
-				log_error("struct device allocation failed");
+				log_error(0, "struct device allocation failed");
 				return NULL;
 			}
 			if (!(alias = dm_malloc(sizeof(*alias)))) {
-				log_error("struct str_list allocation failed");
+				log_error(0, "struct str_list allocation failed");
 				dm_free(dev);
 				return NULL;
 			}
 			if (!(alias->str = dm_strdup(filename))) {
-				log_error("filename strdup failed");
+				log_error(0, "filename strdup failed");
 				dm_free(dev);
 				dm_free(alias);
 				return NULL;
@@ -78,21 +78,21 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 			dev->flags = DEV_ALLOCED;
 		} else {
 			if (!(dev = _alloc(sizeof(*dev)))) {
-				log_error("struct device allocation failed");
+				log_error(0, "struct device allocation failed");
 				return NULL;
 			}
 			if (!(alias = _alloc(sizeof(*alias)))) {
-				log_error("struct str_list allocation failed");
+				log_error(0, "struct str_list allocation failed");
 				_free(dev);
 				return NULL;
 			}
 			if (!(alias->str = _strdup(filename))) {
-				log_error("filename strdup failed");
+				log_error(0, "filename strdup failed");
 				return NULL;
 			}
 		}
 	} else if (!(alias->str = dm_strdup(filename))) {
-		log_error("filename strdup failed");
+		log_error(0, "filename strdup failed");
 		return NULL;
 	}
 
@@ -116,7 +116,7 @@ static struct device *_dev_create(dev_t d)
 	struct device *dev;
 
 	if (!(dev = _alloc(sizeof(*dev)))) {
-		log_error("struct device allocation failed");
+		log_error(0, "struct device allocation failed");
 		return NULL;
 	}
 	dev->flags = 0;
@@ -298,19 +298,19 @@ static int _insert_dev(const char *path, dev_t d)
 			return_0;
 
 		if (!(btree_insert(_cache.devices, (uint32_t) d, dev))) {
-			log_err("Couldn't insert device into binary tree.");
+			log_error(0, "Couldn't insert device into binary tree.");
 			_free(dev);
 			return 0;
 		}
 	}
 
 	if (!loopfile && !_add_alias(dev, path)) {
-		log_err("Couldn't add alias to dev cache.");
+		log_error(0, "Couldn't add alias to dev cache.");
 		return 0;
 	}
 
 	if (!dm_hash_insert(_cache.names, path, dev)) {
-		log_err("Couldn't add name to hash in dev cache.");
+		log_error(0, "Couldn't add name to hash in dev cache.");
 		return 0;
 	}
 
@@ -488,7 +488,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	for (v = cn->v; v; v = v->next) {
 		if (v->type != CFG_STRING) {
-			log_error("preferred_names patterns must be enclosed in quotes");
+			log_error(0, "preferred_names patterns must be enclosed in quotes");
 			return 0;
 		}
 
@@ -499,14 +499,14 @@ static int _init_preferred_names(struct cmd_context *cmd)
 		return_0;
 
 	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count))) {
-		log_error("Failed to allocate preferred device name "
+		log_error(0, "Failed to allocate preferred device name "
 			  "pattern list.");
 		goto out;
 	}
 
 	for (v = cn->v, i = count - 1; v; v = v->next, i--) {
 		if (!(regex[i] = dm_pool_strdup(scratch, v->v.str))) {
-			log_error("Failed to allocate a preferred device name "
+			log_error(0, "Failed to allocate a preferred device name "
 				  "pattern.");
 			goto out;
 		}
@@ -514,7 +514,7 @@ static int _init_preferred_names(struct cmd_context *cmd)
 
 	if (!(_cache.preferred_names_matcher =
 		dm_regex_create(_cache.mem,(const char **) regex, count))) {
-		log_error("Preferred device name pattern matcher creation failed.");
+		log_error(0, "Preferred device name pattern matcher creation failed.");
 		goto out;
 	}
 
@@ -541,7 +541,7 @@ int dev_cache_init(struct cmd_context *cmd)
 	}
 
 	if (!(_cache.devices = btree_create(_cache.mem))) {
-		log_err("Couldn't create binary tree for dev-cache.");
+		log_error(0, "Couldn't create binary tree for dev-cache.");
 		goto bad;
 	}
 
@@ -561,7 +561,7 @@ int dev_cache_init(struct cmd_context *cmd)
 static void _check_closed(struct device *dev)
 {
 	if (dev->fd >= 0)
-		log_err("Device '%s' has been left open.", dev_name(dev));
+		log_error(0, "Device '%s' has been left open.", dev_name(dev));
 }
 
 static void _check_for_open_devices(void)
@@ -599,18 +599,18 @@ int dev_cache_add_dir(const char *path)
 	struct stat st;
 
 	if (stat(path, &st)) {
-		log_error("Ignoring %s: %s", path, strerror(errno));
+		log_error(0, "Ignoring %s: %s", path, strerror(errno));
 		/* But don't fail */
 		return 1;
 	}
 
 	if (!S_ISDIR(st.st_mode)) {
-		log_error("Ignoring %s: Not a directory", path);
+		log_error(0, "Ignoring %s: Not a directory", path);
 		return 1;
 	}
 
 	if (!(dl = _alloc(sizeof(*dl) + strlen(path) + 1))) {
-		log_error("dir_list allocation failed");
+		log_error(0, "dir_list allocation failed");
 		return 0;
 	}
 
@@ -625,18 +625,18 @@ int dev_cache_add_loopfile(const char *path)
 	struct stat st;
 
 	if (stat(path, &st)) {
-		log_error("Ignoring %s: %s", path, strerror(errno));
+		log_error(0, "Ignoring %s: %s", path, strerror(errno));
 		/* But don't fail */
 		return 1;
 	}
 
 	if (!S_ISREG(st.st_mode)) {
-		log_error("Ignoring %s: Not a regular file", path);
+		log_error(0, "Ignoring %s: Not a regular file", path);
 		return 1;
 	}
 
 	if (!(dl = _alloc(sizeof(*dl) + strlen(path) + 1))) {
-		log_error("dir_list allocation failed for file");
+		log_error(0, "dir_list allocation failed for file");
 		return 0;
 	}
 
@@ -672,7 +672,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 				  name, (int) MAJOR(dev->dev),
 				  (int) MINOR(dev->dev));
 		else
-			log_error("Path %s no longer valid for device(%d,%d)",
+			log_error(0, "Path %s no longer valid for device(%d,%d)",
 				  name, (int) MAJOR(dev->dev),
 				  (int) MINOR(dev->dev));
 
@@ -730,7 +730,7 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 	struct dev_iter *di = dm_malloc(sizeof(*di));
 
 	if (!di) {
-		log_error("dev_iter allocation failed");
+		log_error(0, "dev_iter allocation failed");
 		return NULL;
 	}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 06675e2..c5bd56d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -64,7 +64,7 @@ static int _io(struct device_area *where, void *buffer, int should_write)
 	size_t total = 0;
 
 	if (fd < 0) {
-		log_error("Attempt to read an unopened device (%s).",
+		log_error(0, "Attempt to read an unopened device (%s).",
 			  dev_name(where->dev));
 		return 0;
 	}
@@ -76,12 +76,12 @@ static int _io(struct device_area *where, void *buffer, int should_write)
 		return 1;
 
 	if (where->size > SSIZE_MAX) {
-		log_error("Read size too large: %" PRIu64, where->size);
+		log_error(0, "Read size too large: %" PRIu64, where->size);
 		return 0;
 	}
 
 	if (lseek(fd, (off_t) where->start, SEEK_SET) < 0) {
-		log_error("%s: lseek %" PRIu64 " failed: %s",
+		log_error(0, "%s: lseek %" PRIu64 " failed: %s",
 			  dev_name(where->dev), (uint64_t) where->start,
 			  strerror(errno));
 		return 0;
@@ -95,7 +95,7 @@ static int _io(struct device_area *where, void *buffer, int should_write)
 		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
 
 		if (n < 0)
-			log_error("%s: %s failed after %" PRIu64 " of %" PRIu64
+			log_error(0, "%s: %s failed after %" PRIu64 " of %" PRIu64
 				  "@%" PRIu64 ": %s", dev_name(where->dev),
 				  should_write ? "write" : "read",
 				  (uint64_t) total,
@@ -186,7 +186,7 @@ static int _aligned_io(struct device_area *where, void *buffer,
 
 	/* Allocate a bounce buffer with an extra block */
 	if (!(bounce = alloca((size_t) widened.size + block_size))) {
-		log_error("Bounce buffer alloca failed");
+		log_error(0, "Bounce buffer alloca failed");
 		return 0;
 	}
 
@@ -392,7 +392,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	}
 
 	if (memlock())
-		log_error("WARNING: dev_open(%s) called while suspended",
+		log_error(0, "WARNING: dev_open(%s) called while suspended",
 			  dev_name(dev));
 
 	if (dev->flags & DEV_REGULAR)
@@ -406,7 +406,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 			return 0;
 		}
 		if (buf.st_rdev != dev->dev) {
-			log_error("%s: device changed", name);
+			log_error(0, "%s: device changed", name);
 			return 0;
 		}
 	}
@@ -465,7 +465,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 
 	if (!(dev->flags & DEV_REGULAR) &&
 	    ((fstat(dev->fd, &buf) < 0) || (buf.st_rdev != dev->dev))) {
-		log_error("%s: fstat failed: Has device name changed?", name);
+		log_error(0, "%s: fstat failed: Has device name changed?", name);
 		dev_close_immediate(dev);
 		return 0;
 	}
@@ -544,7 +544,7 @@ static int _dev_close(struct device *dev, int immediate)
 	struct lvmcache_info *info;
 
 	if (dev->fd < 0) {
-		log_error("Attempt to close device '%s' "
+		log_error(0, "Attempt to close device '%s' "
 			  "which is not open.", dev_name(dev));
 		return 0;
 	}
@@ -617,7 +617,7 @@ int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		      uint64_t offset2, size_t len2, void *buf)
 {
 	if (!dev_read(dev, offset, len, buf)) {
-		log_error("Read from %s failed", dev_name(dev));
+		log_error(0, "Read from %s failed", dev_name(dev));
 		return 0;
 	}
 
@@ -629,7 +629,7 @@ int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		return 1;
 
 	if (!dev_read(dev, offset2, len2, buf + len)) {
-		log_error("Circular read from %s failed",
+		log_error(0, "Circular read from %s failed",
 			  dev_name(dev));
 		return 0;
 	}
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 618509d..31a1e5b 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -142,7 +142,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s",
 	      sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev), attribute);
 	if (ret < 0) {
-		log_error("dm_snprintf md %s failed", attribute);
+		log_error(0, "dm_snprintf md %s failed", attribute);
 		return ret;
 	}
 
@@ -151,7 +151,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
 				  sysfs_dir, MINOR(dev->dev), attribute);
 		if (ret < 0) {
-			log_error("dm_snprintf old md %s failed", attribute);
+			log_error(0, "dm_snprintf old md %s failed", attribute);
 			return ret;
 		}
 	}
@@ -184,7 +184,7 @@ static int _md_sysfs_attribute_scanf(const char *sysfs_dir,
 	}
 
 	if ((ret = sscanf(buffer, attribute_fmt, attribute_value)) != 1) {
-		log_error("%s sysfs attr %s not in expected format: %s",
+		log_error(0, "%s sysfs attr %s not in expected format: %s",
 			  dev_name(dev), attribute_name, buffer);
 		goto out;
 	}
@@ -293,7 +293,7 @@ unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev)
 		data_disks = raid_disks - 2;
 		break;
 	default:
-		log_error("Device %s has an unknown md raid level: %d",
+		log_error(0, "Device %s has an unknown md raid level: %d",
 			  dev_name(dev), level);
 		return 0;
 	}
diff --git a/lib/device/device.c b/lib/device/device.c
index 9d3c1cf..8963f10 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -155,13 +155,13 @@ int partition_type_is_lvm(struct dev_mgr *dm, struct device *d)
 	}
 
 	if (is_whole_disk(dm, d)) {
-		log_error("%s: looks to possess partition table", d->name);
+		log_error(0, "%s: looks to possess partition table", d->name);
 		return 0;
 	}
 
 	/* check part type */
 	if (pt != LVM_PARTITION && pt != LVM_NEW_PARTITION) {
-		log_error("%s: invalid partition type 0x%x "
+		log_error(0, "%s: invalid partition type 0x%x "
 			  "(must be 0x%x)", d->name, pt, LVM_NEW_PARTITION);
 		return 0;
 	}
@@ -201,13 +201,13 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 	}
 
 	if (!(buffer = dm_malloc(SECTOR_SIZE))) {
-		log_error("Failed to allocate partition table buffer");
+		log_error(0, "Failed to allocate partition table buffer");
 		return 0;
 	}
 
 	/* Get partition table */
 	if ((pv_handle = open(primary->name, O_RDONLY)) < 0) {
-		log_error("%s: open failed: %s", primary->name,
+		log_error(0, "%s: open failed: %s", primary->name,
 			  strerror(errno));
 		return 0;
 	}
@@ -220,7 +220,7 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 		bytes_read = 0;
 
 		if (llseek(pv_handle, offset * SECTOR_SIZE, SEEK_SET) == -1) {
-			log_error("%s: llseek failed: %s",
+			log_error(0, "%s: llseek failed: %s",
 				  primary->name, strerror(errno));
 			return 0;
 		}
@@ -232,7 +232,7 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 			bytes_read += read_ret;
 
 		if (read_ret == -1) {
-			log_error("%s: read failed: %s", primary->name,
+			log_error(0, "%s: read failed: %s", primary->name,
 				  strerror(errno));
 			return 0;
 		}
diff --git a/lib/display/display.c b/lib/display/display.c
index 0de0a8e..a8269ff 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -142,7 +142,7 @@ alloc_policy_t get_alloc_from_string(const char *str)
 	if(!strcmp("next free", str))
 		return ALLOC_NORMAL;
 
-	log_error("Unrecognised allocation policy %s", str);
+	log_error(0, "Unrecognised allocation policy %s", str);
 	return ALLOC_INVALID;
 }
 
@@ -170,7 +170,7 @@ static const char *_display_size(const struct cmd_context *cmd,
 	};
 
 	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
-		log_error("no memory for size display buffer");
+		log_error(0, "no memory for size display buffer");
 		return "";
 	}
 
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index fa90a8e..21a87de 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -74,7 +74,7 @@ static int _errseg_modules_needed(struct dm_pool *mem,
 				  struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "error")) {
-		log_error("error module string list allocation failed");
+		log_error(0, "error module string list allocation failed");
 		return 0;
 	}
 
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index d1606d3..e89317b 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -54,7 +54,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 		return_NULL;
 
 	if (!(filters_copy = dm_malloc(sizeof(*filters) * (n + 1)))) {
-		log_error("composite filters allocation failed");
+		log_error(0, "composite filters allocation failed");
 		return NULL;
 	}
 
@@ -62,7 +62,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	filters_copy[n] = NULL;
 
 	if (!(cft = dm_malloc(sizeof(*cft)))) {
-		log_error("compsoite filters allocation failed");
+		log_error(0, "compsoite filters allocation failed");
 		dm_free(filters_copy);
 		return NULL;
 	}
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index c1ecff7..f7cf8ab 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -53,7 +53,7 @@ struct dev_filter *md_filter_create(void)
 	struct dev_filter *f;
 
 	if (!(f = dm_malloc(sizeof(*f)))) {
-		log_error("md filter allocation failed");
+		log_error(0, "md filter allocation failed");
 		return NULL;
 	}
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index b545a55..49b846d 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -162,7 +162,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 
 		str = dm_hash_get_key(pf->devices, n);
 		if (!(buf = alloca(escaped_len(str)))) {
-			log_error("persistent filter device path stack "
+			log_error(0, "persistent filter device path stack "
 				  "allocation failed");
 			return;
 		}
@@ -249,7 +249,7 @@ int persistent_filter_dump(struct dev_filter *f)
 		goto_out;
 
 	if (rename(tmp_file, pf->file))
-		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
+		log_error(0, "%s: rename to %s failed: %s", tmp_file, pf->file,
 			  strerror(errno));
 
 	r = 1;
@@ -310,7 +310,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 	pf->real = real;
 
 	if (!(_init_hash(pf))) {
-		log_error("Couldn't create hash table for persistent filter.");
+		log_error(0, "Couldn't create hash table for persistent filter.");
 		goto bad;
 	}
 
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 1d415a4..0257211 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -103,7 +103,7 @@ static int _build_matcher(struct rfilter *rf, struct config_value *val)
 	 */
 	for (v = val; v; v = v->next) {
 		if (v->type != CFG_STRING) {
-			log_error("filter patterns must be enclosed in quotes");
+			log_error(0, "filter patterns must be enclosed in quotes");
 			goto out;
 		}
 
@@ -128,7 +128,7 @@ static int _build_matcher(struct rfilter *rf, struct config_value *val)
 	 */
 	for (v = val, i = count - 1; v; v = v->next, i--)
 		if (!_extract_pattern(scratch, v->v.str, regex, rf->accept, i)) {
-			log_error("invalid filter pattern");
+			log_error(0, "invalid filter pattern");
 			goto out;
 		}
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 1220b3a..30b85cd 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -164,7 +164,7 @@ static int _parse_dev(const char *file, FILE *fp, dev_t *result)
 	char buffer[64];
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
-		log_error("Empty sysfs device file: %s", file);
+		log_error(0, "Empty sysfs device file: %s", file);
 		return 0;
 	}
 
@@ -219,14 +219,14 @@ static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir,
 				 d->d_name) < 0) {
-			log_error("sysfs path name too long: %s in %s",
+			log_error(0, "sysfs path name too long: %s in %s",
 				  d->d_name, dir);
 			continue;
 		}
 
 		/* devices have a "dev" file */
 		if (dm_snprintf(file, sizeof(file), "%s/dev", path) < 0) {
-			log_error("sysfs path name too long: %s in %s",
+			log_error(0, "sysfs path name too long: %s in %s",
 				  d->d_name, dir);
 			continue;
 		}
@@ -302,12 +302,12 @@ struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
 		return NULL;
 
 	if (!(mem = dm_pool_create("sysfs", 256))) {
-		log_error("sysfs pool creation failed");
+		log_error(0, "sysfs pool creation failed");
 		return NULL;
 	}
 
 	if (!(ds = _dev_set_create(mem, sys_block, sysfs_depth))) {
-		log_error("sysfs dev_set creation failed");
+		log_error(0, "sysfs dev_set creation failed");
 		goto bad;
 	}
 
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index bc07cb6..8bd3f88 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -160,7 +160,7 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 
 	if (dm_snprintf(proc_devices, sizeof(proc_devices),
 			 "%s/devices", proc) < 0) {
-		log_error("Failed to create /proc/devices string");
+		log_error(0, "Failed to create /proc/devices string");
 		return 0;
 	}
 
@@ -219,7 +219,7 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 		/* Check devices/types for local variations */
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
-				log_error("Expecting string in devices/types "
+				log_error(0, "Expecting string in devices/types "
 					  "in config file");
 				if (fclose(pd))
 					log_sys_error("fclose", proc_devices);
@@ -229,7 +229,7 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 			name = cv->v.str;
 			cv = cv->next;
 			if (!cv || cv->type != CFG_INT) {
-				log_error("Max partition count missing for %s "
+				log_error(0, "Max partition count missing for %s "
 					  "in devices/types in config file",
 					  name);
 				if (fclose(pd))
@@ -237,7 +237,7 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 				return 0;
 			}
 			if (!cv->v.i) {
-				log_error("Zero partition count invalid for "
+				log_error(0, "Zero partition count invalid for "
 					  "%s in devices/types in config file",
 					  name);
 				if (fclose(pd))
@@ -270,7 +270,7 @@ struct dev_filter *lvm_type_filter_create(const char *proc,
 	struct dev_filter *f;
 
 	if (!(f = dm_malloc(sizeof(struct dev_filter)))) {
-		log_error("LVM type filter allocation failed");
+		log_error(0, "LVM type filter allocation failed");
 		return NULL;
 	}
 
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 24a1629..8329665 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -369,7 +369,7 @@ static struct disk_list *__read_disk(const struct format_type *fmt,
 	}
 
 	if (!read_vgd(dl->dev, &dl->vgd, &dl->pvd)) {
-		log_error("Failed to read VG data from PV (%s)", name);
+		log_error(0, "Failed to read VG data from PV (%s)", name);
 		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
 		goto bad;
 	}
@@ -385,17 +385,17 @@ static struct disk_list *__read_disk(const struct format_type *fmt,
 			  dl->vgd.vg_status & VG_EXPORTED);
 
 	if (!_read_uuids(dl)) {
-		log_error("Failed to read PV uuid list from %s", name);
+		log_error(0, "Failed to read PV uuid list from %s", name);
 		goto bad;
 	}
 
 	if (!_read_lvs(dl)) {
-		log_error("Failed to read LV's from %s", name);
+		log_error(0, "Failed to read LV's from %s", name);
 		goto bad;
 	}
 
 	if (!_read_extents(dl)) {
-		log_error("Failed to read extents from %s", name);
+		log_error(0, "Failed to read extents from %s", name);
 		goto bad;
 	}
 
@@ -487,7 +487,7 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 	}
 
 	if (!(iter = dev_iter_create(filter, 1))) {
-		log_error("read_pvs_in_vg: dev_iter_create failed");
+		log_error(0, "read_pvs_in_vg: dev_iter_create failed");
 		return 0;
 	}
 
@@ -530,7 +530,7 @@ static int _write_uuids(struct disk_list *data)
 
 	dm_list_iterate_items(ul, &data->uuids) {
 		if (pos >= end) {
-			log_error("Too many uuids to fit on %s",
+			log_error(0, "Too many uuids to fit on %s",
 				  dev_name(data->dev));
 			return 0;
 		}
@@ -571,7 +571,7 @@ static int _write_lvs(struct disk_list *data)
 	pos = data->pvd.lv_on_disk.base;
 
 	if (!dev_set(data->dev, pos, data->pvd.lv_on_disk.size, 0)) {
-		log_error("Couldn't zero lv area on device '%s'",
+		log_error(0, "Couldn't zero lv area on device '%s'",
 			  dev_name(data->dev));
 		return 0;
 	}
@@ -579,7 +579,7 @@ static int _write_lvs(struct disk_list *data)
 	dm_list_iterate_items(ll, &data->lvds) {
 		offset = sizeof(struct lv_disk) * ll->lvd.lv_number;
 		if (offset + sizeof(struct lv_disk) > data->pvd.lv_on_disk.size) {
-			log_error("lv_number %d too large", ll->lvd.lv_number);
+			log_error(0, "lv_number %d too large", ll->lvd.lv_number);
 			return 0;
 		}
 
@@ -616,7 +616,7 @@ static int _write_pvd(struct disk_list *data)
 	size_t size = data->pvd.pv_on_disk.size;
 
 	if (size < sizeof(struct pv_disk)) {
-		log_error("Invalid PV structure size.");
+		log_error(0, "Invalid PV structure size.");
 		return 0;
 	}
 
@@ -625,7 +625,7 @@ static int _write_pvd(struct disk_list *data)
 	   happy (idea from AED) */
 	buf = dm_malloc(size);
 	if (!buf) {
-		log_err("Couldn't allocate temporary PV buffer.");
+		log_error(0, "Couldn't allocate temporary PV buffer.");
 		return 0;
 	}
 
@@ -655,7 +655,7 @@ static int __write_all_pvd(const struct format_type *fmt __attribute((unused)),
 	const char *pv_name = dev_name(data->dev);
 
 	if (!_write_pvd(data)) {
-		log_error("Failed to write PV structure onto %s", pv_name);
+		log_error(0, "Failed to write PV structure onto %s", pv_name);
 		return 0;
 	}
 
@@ -674,22 +674,22 @@ static int __write_all_pvd(const struct format_type *fmt __attribute((unused)),
 	   fmt); */
 
 	if (!_write_vgd(data)) {
-		log_error("Failed to write VG data to %s", pv_name);
+		log_error(0, "Failed to write VG data to %s", pv_name);
 		return 0;
 	}
 
 	if (!_write_uuids(data)) {
-		log_error("Failed to write PV uuid list to %s", pv_name);
+		log_error(0, "Failed to write PV uuid list to %s", pv_name);
 		return 0;
 	}
 
 	if (!_write_lvs(data)) {
-		log_error("Failed to write LV's to %s", pv_name);
+		log_error(0, "Failed to write LV's to %s", pv_name);
 		return 0;
 	}
 
 	if (!_write_extents(data)) {
-		log_error("Failed to write extents to %s", pv_name);
+		log_error(0, "Failed to write extents to %s", pv_name);
 		return 0;
 	}
 
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index c8f9519..b7a181d 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -64,7 +64,7 @@ static int _check_vgs(struct dm_list *pvs)
 			first = dl;
 
 		else if (memcmp(&first->vgd, &dl->vgd, sizeof(first->vgd))) {
-			log_error("VG data differs between PVs %s and %s",
+			log_error(0, "VG data differs between PVs %s and %s",
 				  dev_name(first->dev), dev_name(dl->dev));
 			log_debug("VG data on %s: %s %s %" PRIu32 " %" PRIu32
 				  "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
@@ -103,7 +103,7 @@ static int _check_vgs(struct dm_list *pvs)
 
 	/* On entry to fn, list known to be non-empty */
 	if (pv_count != first->vgd.pv_cur) {
-		log_error("%d PV(s) found for VG %s: expected %d",
+		log_error(0, "%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
 	}
 
@@ -303,7 +303,7 @@ static int _format1_pv_setup(const struct format_type *fmt,
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
 	if (pv->size > MAX_PV_SIZE) {
-		log_error("Physical volumes cannot be bigger than %s",
+		log_error(0, "Physical volumes cannot be bigger than %s",
 			  display_size(fmt->cmd, (uint64_t) MAX_PV_SIZE));
 		return 0;
 	}
@@ -321,7 +321,7 @@ static int _format1_pv_setup(const struct format_type *fmt,
 	/* Retain existing extent locations exactly */
 	if (((pe_start || extent_count) && (pe_start != pv->pe_start)) ||
 	    (extent_count && (extent_count != pv->pe_count))) {
-		log_error("Metadata would overwrite physical extents");
+		log_error(0, "Metadata would overwrite physical extents");
 		return 0;
 	}
 
@@ -336,12 +336,12 @@ static int _format1_lv_setup(struct format_instance *fid, struct logical_volume
 		lvid_from_lvnum(&lv->lvid, &lv->vg->id, find_free_lvnum(lv));
 
 	if (lv->le_count > MAX_LE_TOTAL) {
-		log_error("logical volumes cannot contain more than "
+		log_error(0, "logical volumes cannot contain more than "
 			  "%d extents.", MAX_LE_TOTAL);
 		return 0;
 	}
 	if (lv->size > max_size) {
-		log_error("logical volumes cannot be larger than %s",
+		log_error(0, "logical volumes cannot be larger than %s",
 			  display_size(fid->fmt->cmd, max_size));
 		return 0;
 	}
@@ -413,7 +413,7 @@ static int _format1_vg_setup(struct format_instance *fid, struct volume_group *v
 		vg->max_pv = MAX_PV - 1;
 
 	if (vg->extent_size > MAX_PE_SIZE || vg->extent_size < MIN_PE_SIZE) {
-		log_error("Extent size must be between %s and %s",
+		log_error(0, "Extent size must be between %s and %s",
 			  display_size(fid->fmt->cmd, (uint64_t) MIN_PE_SIZE),
 			  display_size(fid->fmt->cmd, (uint64_t) MAX_PE_SIZE));
 
@@ -421,14 +421,14 @@ static int _format1_vg_setup(struct format_instance *fid, struct volume_group *v
 	}
 
 	if (vg->extent_size % MIN_PE_SIZE) {
-		log_error("Extent size must be multiple of %s",
+		log_error(0, "Extent size must be multiple of %s",
 			  display_size(fid->fmt->cmd, (uint64_t) MIN_PE_SIZE));
 		return 0;
 	}
 
 	/* Redundant? */
 	if (vg->extent_size & (vg->extent_size - 1)) {
-		log_error("Extent size must be power of 2");
+		log_error(0, "Extent size must be power of 2");
 		return 0;
 	}
 
@@ -520,12 +520,12 @@ struct format_type *init_format(struct cmd_context *cmd)
 	fmt->private = NULL;
 
 	if (!(fmt->labeller = lvm1_labeller_create(fmt))) {
-		log_error("Couldn't create lvm1 label handler.");
+		log_error(0, "Couldn't create lvm1 label handler.");
 		return NULL;
 	}
 
 	if (!(label_register_handler(FMT_LVM1_NAME, fmt->labeller))) {
-		log_error("Couldn't register lvm1 label handler.");
+		log_error(0, "Couldn't register lvm1 label handler.");
 		return NULL;
 	}
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index c0a89c5..79ee87a 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -64,7 +64,7 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 	if (!*pvd->vg_name)
 		pv->vg_name = fmt->orphan_vg_name;
 	else if (!(pv->vg_name = dm_pool_strdup(mem, (char *)pvd->vg_name))) {
-		log_error("Volume Group name allocation failed.");
+		log_error(0, "Volume Group name allocation failed.");
 		return 0;
 	}
 
@@ -100,7 +100,7 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 	/* Fix up pv size if missing or impossibly large */
 	if (!pv->size || pv->size > (1ULL << 62)) {
 		if (!dev_get_size(dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", pv_dev_name(pv));
+			log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 			return 0;
 		}
 		log_verbose("Fixing up missing format1 size (%s) "
@@ -110,7 +110,7 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 			size = pv->pe_count * (uint64_t) vg->extent_size +
 			       pv->pe_start;
 			if (size > pv->size)
-				log_error("WARNING: Physical Volume %s is too "
+				log_error(0, "WARNING: Physical Volume %s is too "
 					  "large for underlying device",
 					  pv_dev_name(pv));
 		}
@@ -130,7 +130,7 @@ static int _system_id(struct cmd_context *cmd, char *s, const char *prefix)
 
 	if (dm_snprintf(s, NAME_LEN, "%s%s%lu",
 			 prefix, cmd->hostname, time(NULL)) < 0) {
-		log_error("Generated system_id too long");
+		log_error(0, "Generated system_id too long");
 		return 0;
 	}
 
@@ -170,7 +170,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute((unused))
 		}
 		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
 		    sizeof(pvd->vg_name)) {
-			log_error("Volume group name %s too long to export",
+			log_error(0, "Volume group name %s too long to export",
 				  pvd->vg_name);
 			return 0;
 		}
@@ -402,13 +402,13 @@ int export_extents(struct disk_list *dl, uint32_t lv_num,
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (!(seg->segtype->flags & SEG_FORMAT1_SUPPORT)) {
-				log_error("Segment type %s in LV %s: "
+				log_error(0, "Segment type %s in LV %s: "
 					  "unsupported by format1",
 					  seg->segtype->name, lv->name);
 				return 0;
 			}
 			if (seg_type(seg, s) != AREA_PV) {
-				log_error("Non-PV stripe found in LV %s: "
+				log_error(0, "Non-PV stripe found in LV %s: "
 					  "unsupported by format1", lv->name);
 				return 0;
 			}
@@ -579,14 +579,14 @@ int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_gr
 			lvnum = lvd->lv_number;
 
 			if (lvnum >= MAX_LV) {
-				log_err("Logical volume number "
+				log_error(0, "Logical volume number "
 					"out of bounds.");
 				return 0;
 			}
 
 			if (!lvs[lvnum] &&
 			    !(lvs[lvnum] = find_lv(vg, (char *)lvd->lv_name))) {
-				log_err("Couldn't find logical volume '%s'.",
+				log_error(0, "Couldn't find logical volume '%s'.",
 					lvd->lv_name);
 				return 0;
 			}
@@ -606,7 +606,7 @@ int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_gr
 			lvnum = lvd->lv_number;
 			cow = lvs[lvnum];
 			if (!(org = lvs[lvd->lv_snapshot_minor])) {
-				log_err("Couldn't find origin logical volume "
+				log_error(0, "Couldn't find origin logical volume "
 					"for snapshot '%s'.", lvd->lv_name);
 				return 0;
 			}
@@ -619,7 +619,7 @@ int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_gr
 			if (!vg_add_snapshot(org, cow, NULL,
 					     org->le_count,
 					     lvd->lv_chunk_size)) {
-				log_err("Couldn't add snapshot.");
+				log_error(0, "Couldn't add snapshot.");
 				return 0;
 			}
 		}
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index ded0a8e..99617af 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -50,7 +50,7 @@ static struct dm_hash_table *_create_lv_maps(struct dm_pool *mem,
 	struct lv_map *lvm;
 
 	if (!maps) {
-		log_err("Unable to create hash table for holding "
+		log_error(0, "Unable to create hash table for holding "
 			"extent maps.");
 		return NULL;
 	}
@@ -89,7 +89,7 @@ static int _fill_lv_array(struct lv_map **lvs,
 	dm_list_iterate_items(ll, &dl->lvds) {
 		if (!(lvm = dm_hash_lookup(maps, strrchr((char *)ll->lvd.lv_name, '/')
 					+ 1))) {
-			log_err("Physical volume (%s) contains an "
+			log_error(0, "Physical volume (%s) contains an "
 				"unknown logical volume (%s).",
 				dev_name(dl->dev), ll->lvd.lv_name);
 			return 0;
@@ -132,7 +132,7 @@ static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
 				lvm = lvms[lv_num];
 
 				if (!lvm) {
-					log_error("Invalid LV in extent map "
+					log_error(0, "Invalid LV in extent map "
 						  "(PV %s, PE %" PRIu32
 						  ", LV %" PRIu32
 						  ", LE %" PRIu32 ")",
@@ -144,13 +144,13 @@ static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
 				le = e[i].le_num;
 
 				if (le >= lvm->lv->le_count) {
-					log_err("logical extent number "
+					log_error(0, "logical extent number "
 						"out of bounds");
 					return 0;
 				}
 
 				if (lvm->map[le].pv) {
-					log_err("logical extent (%u) "
+					log_error(0, "logical extent (%u) "
 						"already mapped.", le);
 					return 0;
 				}
@@ -170,7 +170,7 @@ static int _check_single_map(struct lv_map *lvm)
 
 	for (i = 0; i < lvm->lv->le_count; i++) {
 		if (!lvm->map[i].pv) {
-			log_err("Logical volume (%s) contains an incomplete "
+			log_error(0, "Logical volume (%s) contains an incomplete "
 				"mapping table.", lvm->lv->name);
 			return 0;
 		}
@@ -220,7 +220,7 @@ static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
 					     len, 0, 0, NULL, 1, len, 0, 0, 0))) {
-			log_error("Failed to allocate linear segment.");
+			log_error(0, "Failed to allocate linear segment.");
 			return 0;
 		}
 
@@ -267,7 +267,7 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 	 * Work out overall striped length
 	 */
 	if (lvm->lv->le_count % lvm->stripes) {
-		log_error("Number of stripes (%u) incompatible "
+		log_error(0, "Number of stripes (%u) incompatible "
 			  "with logical extent count (%u) for %s",
 			  lvm->stripes, lvm->lv->le_count, lvm->lv->name);
 	}
@@ -294,7 +294,7 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
 					     area_len, 0, 0, 0))) {
-			log_error("Failed to allocate striped segment.");
+			log_error(0, "Failed to allocate striped segment.");
 			return 0;
 		}
 
@@ -346,12 +346,12 @@ int import_extents(struct cmd_context *cmd, struct volume_group *vg,
 		return_0;
 
 	if (!(maps = _create_lv_maps(scratch, vg))) {
-		log_err("Couldn't allocate logical volume maps.");
+		log_error(0, "Couldn't allocate logical volume maps.");
 		goto out;
 	}
 
 	if (!_fill_maps(maps, vg, pvds)) {
-		log_err("Couldn't fill logical volume maps.");
+		log_error(0, "Couldn't fill logical volume maps.");
 		goto out;
 	}
 
@@ -359,7 +359,7 @@ int import_extents(struct cmd_context *cmd, struct volume_group *vg,
 		goto_out;
 
 	if (!_build_all_segments(cmd, maps)) {
-		log_err("Couldn't build extent segments.");
+		log_error(0, "Couldn't build extent segments.");
 		goto out;
 	}
 	r = 1;
diff --git a/lib/format1/layout.c b/lib/format1/layout.c
index de9b206..73c3e39 100644
--- a/lib/format1/layout.c
+++ b/lib/format1/layout.c
@@ -76,14 +76,14 @@ static void _calc_simple_layout(struct pv_disk *pvd)
 static int _check_vg_limits(struct disk_list *dl)
 {
 	if (dl->vgd.lv_max > MAX_LV) {
-		log_error("MaxLogicalVolumes of %d exceeds format limit of %d "
+		log_error(0, "MaxLogicalVolumes of %d exceeds format limit of %d "
 			  "for VG '%s'", dl->vgd.lv_max, MAX_LV - 1,
 			  dl->pvd.vg_name);
 		return 0;
 	}
 
 	if (dl->vgd.pv_max > MAX_PV) {
-		log_error("MaxPhysicalVolumes of %d exceeds format limit of %d "
+		log_error(0, "MaxPhysicalVolumes of %d exceeds format limit of %d "
 			  "for VG '%s'", dl->vgd.pv_max, MAX_PV - 1,
 			  dl->pvd.vg_name);
 		return 0;
@@ -102,7 +102,7 @@ int calculate_layout(struct disk_list *dl)
 
 	_calc_simple_layout(pvd);
 	if (!_adjust_pe_on_disk(pvd)) {
-		log_error("Insufficient space for metadata and PE's.");
+		log_error(0, "Insufficient space for metadata and PE's.");
 		return 0;
 	}
 
@@ -136,7 +136,7 @@ int calculate_extent_count(struct physical_volume *pv, uint32_t extent_size,
 		pvd->pe_total = (pv->size / extent_size);
 
 	if (pvd->pe_total < PE_SIZE_PV_SIZE_REL) {
-		log_error("Too few extents on %s.  Try smaller extent size.",
+		log_error(0, "Too few extents on %s.  Try smaller extent size.",
 			  pv_dev_name(pv));
 		dm_free(pvd);
 		return 0;
@@ -157,7 +157,7 @@ int calculate_extent_count(struct physical_volume *pv, uint32_t extent_size,
 		 > pv->size);
 
 	if (pvd->pe_total > MAX_PE_TOTAL) {
-		log_error("Metadata extent limit (%u) exceeded for %s - "
+		log_error(0, "Metadata extent limit (%u) exceeded for %s - "
 			  "%u required", MAX_PE_TOTAL, pv_dev_name(pv),
 			  pvd->pe_total);
 		dm_free(pvd);
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 28b0840..d61e446 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -26,7 +26,7 @@
 
 static void _not_supported(const char *op)
 {
-	log_err("The '%s' operation is not supported for the lvm1 labeller.",
+	log_error(0, "The '%s' operation is not supported for the lvm1 labeller.",
 		op);
 }
 
@@ -119,7 +119,7 @@ struct labeller *lvm1_labeller_create(struct format_type *fmt)
 	struct labeller *l;
 
 	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_err("Couldn't allocate labeller object.");
+		log_error(0, "Couldn't allocate labeller object.");
 		return NULL;
 	}
 
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 802bf52..c8b6cb5 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -266,7 +266,7 @@ static int _read_vg_pds(const struct format_type *fmt, struct dm_pool *mem,
 			if (!(sp_devs =
 			      dm_pool_zalloc(tmpmem,
 					  sizeof(uint32_t) * sp_count))) {
-				log_error("Unable to allocate %d 32-bit uints",
+				log_error(0, "Unable to allocate %d 32-bit uints",
 					  sp_count);
 				dm_pool_destroy(tmpmem);
 				return 0;
@@ -353,7 +353,7 @@ struct pool_list *read_pool_disk(const struct format_type *fmt,
 		return_NULL;
 
 	if (!(pl = dm_pool_zalloc(mem, sizeof(*pl)))) {
-		log_error("Unable to allocate pool list structure");
+		log_error(0, "Unable to allocate pool list structure");
 		return 0;
 	}
 
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 3f31bba..249a8ad 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -39,7 +39,7 @@ static struct user_subpool *_build_usp(struct dm_list *pls, struct dm_pool *mem,
 	dm_list_iterate_items(pl, pls) {
 		*sps = pl->pd.pl_subpools;
 		if (!usp && (!(usp = dm_pool_zalloc(mem, sizeof(*usp) * (*sps))))) {
-			log_error("Unable to allocate %d subpool structures",
+			log_error(0, "Unable to allocate %d subpool structures",
 				  *sps);
 			return 0;
 		}
@@ -59,7 +59,7 @@ static struct user_subpool *_build_usp(struct dm_list *pls, struct dm_pool *mem,
 		       dm_pool_zalloc(mem,
 				   sizeof(*usp->devs) * pl->pd.pl_sp_devs)))) {
 
-			log_error("Unable to allocate %d pool_device "
+			log_error(0, "Unable to allocate %d pool_device "
 				  "structures", pl->pd.pl_sp_devs);
 			return 0;
 		}
@@ -82,12 +82,12 @@ static int _check_usp(char *vgname, struct user_subpool *usp, int sp_count)
 
 	for (i = 0; i < sp_count; i++) {
 		if (!usp[i].initialized) {
-			log_error("Missing subpool %d in pool %s", i, vgname);
+			log_error(0, "Missing subpool %d in pool %s", i, vgname);
 			return 0;
 		}
 		for (j = 0; j < usp[i].num_devs; j++) {
 			if (!usp[i].devs[j].initialized) {
-				log_error("Missing device %u for subpool %d"
+				log_error(0, "Missing device %u for subpool %d"
 					  " in pool %s", j, i, vgname);
 				return 0;
 			}
@@ -108,7 +108,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	int sp_count;
 
 	if (!(vg = dm_pool_zalloc(smem, sizeof(*vg)))) {
-		log_error("Unable to allocate volume group structure");
+		log_error(0, "Unable to allocate volume group structure");
 		return NULL;
 	}
 
@@ -254,7 +254,7 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 	struct metadata_area *mda;
 
 	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Unable to allocate format instance structure for "
+		log_error(0, "Unable to allocate format instance structure for "
 			  "pool format");
 		return NULL;
 	}
@@ -264,7 +264,7 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
-		log_error("Unable to allocate metadata area structure "
+		log_error(0, "Unable to allocate metadata area structure "
 			  "for pool format");
 		dm_pool_free(fmt->cmd->mem, fid);
 		return NULL;
@@ -307,7 +307,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
 
 	if (!fmt) {
-		log_error("Unable to allocate format type structure for pool "
+		log_error(0, "Unable to allocate format type structure for pool "
 			  "format");
 		return NULL;
 	}
@@ -321,12 +321,12 @@ struct format_type *init_format(struct cmd_context *cmd)
 	fmt->private = NULL;
 
 	if (!(fmt->labeller = pool_labeller_create(fmt))) {
-		log_error("Couldn't create pool label handler.");
+		log_error(0, "Couldn't create pool label handler.");
 		return NULL;
 	}
 
 	if (!(label_register_handler(FMT_POOL_NAME, fmt->labeller))) {
-		log_error("Couldn't register pool label handler.");
+		log_error(0, "Couldn't register pool label handler.");
 		return NULL;
 	}
 
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 0ddf881..467cd5c 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -60,7 +60,7 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 	struct logical_volume *lv;
 
 	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
-		log_error("Unable to allocate logical volume structure");
+		log_error(0, "Unable to allocate logical volume structure");
 		return 0;
 	}
 
@@ -118,11 +118,11 @@ int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
 
 	dm_list_iterate_items(pl, pls) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
-			log_error("Unable to allocate pv list structure");
+			log_error(0, "Unable to allocate pv list structure");
 			return 0;
 		}
 		if (!(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv)))) {
-			log_error("Unable to allocate pv structure");
+			log_error(0, "Unable to allocate pv structure");
 			return 0;
 		}
 		if (!import_pool_pv(fmt, mem, vg, pvl->pv, pl)) {
@@ -150,7 +150,7 @@ int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
 
 	pv->dev = pl->dev;
 	if (!(pv->vg_name = dm_pool_strdup(mem, pd->pl_pool_name))) {
-		log_error("Unable to duplicate vg_name string");
+		log_error(0, "Unable to duplicate vg_name string");
 		return 0;
 	}
 	if (vg != NULL)
@@ -195,7 +195,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 	uint32_t area_len;
 
 	if (usp->striping & (usp->striping - 1)) {
-		log_error("Stripe size must be a power of 2");
+		log_error(0, "Stripe size must be a power of 2");
 		return 0;
 	}
 
@@ -209,7 +209,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 				     area_len * usp->num_devs, 0,
 				     usp->striping, NULL, usp->num_devs,
 				     area_len, 0, 0, 0))) {
-		log_error("Unable to allocate striped lv_segment structure");
+		log_error(0, "Unable to allocate striped lv_segment structure");
 		return 0;
 	}
 
@@ -246,7 +246,7 @@ static int _add_linear_seg(struct dm_pool *mem,
 					     area_len, 0, usp->striping,
 					     NULL, 1, area_len,
 					     POOL_PE_SIZE, 0, 0))) {
-			log_error("Unable to allocate linear lv_segment "
+			log_error(0, "Unable to allocate linear lv_segment "
 				  "structure");
 			return 0;
 		}
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 5b43375..5022edc 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -25,7 +25,7 @@
 
 static void _pool_not_supported(const char *op)
 {
-	log_error("The '%s' operation is not supported for the pool labeller.",
+	log_error(0, "The '%s' operation is not supported for the pool labeller.",
 		  op);
 }
 
@@ -96,7 +96,7 @@ struct labeller *pool_labeller_create(struct format_type *fmt)
 	struct labeller *l;
 
 	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_error("Couldn't allocate labeller object.");
+		log_error(0, "Couldn't allocate labeller object.");
 		return NULL;
 	}
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 0077f14..7a43206 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -139,7 +139,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 
 	/* Sort fails beyond 5-digit indexes */
 	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
-		log_err("Couldn't scan the archive directory (%s).", dir);
+		log_error(0, "Couldn't scan the archive directory (%s).", dir);
 		return 0;
 	}
 
@@ -164,7 +164,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 		 * Create a new archive_file.
 		 */
 		if (!(af = dm_pool_alloc(mem, sizeof(*af)))) {
-			log_err("Couldn't create new archive file.");
+			log_error(0, "Couldn't create new archive file.");
 			results = NULL;
 			goto out;
 		}
@@ -238,12 +238,12 @@ int archive_vg(struct volume_group *vg,
 	 */
 	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd,
 			      &vg->cmd->rand_seed)) {
-		log_err("Couldn't create temporary archive name.");
+		log_error(0, "Couldn't create temporary archive name.");
 		return 0;
 	}
 
 	if (!(fp = fdopen(fd, "w"))) {
-		log_err("Couldn't create FILE object for archive.");
+		log_error(0, "Couldn't create FILE object for archive.");
 		if (close(fd))
 			log_sys_error("close", temp_file);
 		return 0;
@@ -274,7 +274,7 @@ int archive_vg(struct volume_group *vg,
 	for (i = 0; i < 10; i++) {
 		if (dm_snprintf(archive_name, sizeof(archive_name),
 				 "%s/%s_%05u.vg", dir, vg->name, ix) < 0) {
-			log_error("Archive file name too long.");
+			log_error(0, "Archive file name too long.");
 			return 0;
 		}
 
@@ -285,7 +285,7 @@ int archive_vg(struct volume_group *vg,
 	}
 
 	if (!renamed)
-		log_error("Archive rename failed for %s", temp_file);
+		log_error(0, "Archive rename failed for %s", temp_file);
 
 	_remove_expired(archives, dm_list_size(archives) + renamed, retain_days,
 			min_archive);
@@ -307,7 +307,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	if (!(context = create_text_context(cmd, af->path, NULL)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
 							 NULL, context))) {
-		log_error("Couldn't create text instance object.");
+		log_error(0, "Couldn't create text instance object.");
 		return;
 	}
 
@@ -356,7 +356,7 @@ int archive_list_file(struct cmd_context *cmd, const char *file)
 	af.path = (char *)file;
 
 	if (!path_exists(af.path)) {
-		log_err("Archive file %s not found.", af.path);
+		log_error(0, "Archive file %s not found.", af.path);
 		return 0;
 	}
 
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index d80c0ba..a4d34ce 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -42,7 +42,7 @@ int archive_init(struct cmd_context *cmd, const char *dir,
 {
 	if (!(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
 						sizeof(*cmd->archive_params)))) {
-		log_error("archive_params alloc failed");
+		log_error(0, "archive_params alloc failed");
 		return 0;
 	}
 
@@ -52,7 +52,7 @@ int archive_init(struct cmd_context *cmd, const char *dir,
 		return 1;
 
 	if (!(cmd->archive_params->dir = dm_strdup(dir))) {
-		log_error("Couldn't copy archive directory name.");
+		log_error(0, "Couldn't copy archive directory name.");
 		return 0;
 	}
 
@@ -124,7 +124,7 @@ int archive(struct volume_group *vg)
 	log_verbose("Archiving volume group \"%s\" metadata (seqno %u).", vg->name,
 		    vg->seqno);
 	if (!__archive(vg)) {
-		log_error("Volume group \"%s\" metadata archive failed.",
+		log_error(0, "Volume group \"%s\" metadata archive failed.",
 			  vg->name);
 		return 0;
 	}
@@ -156,7 +156,7 @@ int backup_init(struct cmd_context *cmd, const char *dir,
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
 					       sizeof(*cmd->backup_params)))) {
-		log_error("backup_params alloc failed");
+		log_error(0, "backup_params alloc failed");
 		return 0;
 	}
 
@@ -165,7 +165,7 @@ int backup_init(struct cmd_context *cmd, const char *dir,
 		return 1;
 
 	if (!(cmd->backup_params->dir = dm_strdup(dir))) {
-		log_error("Couldn't copy backup directory name.");
+		log_error(0, "Couldn't copy backup directory name.");
 		return 0;
 	}
 	backup_enable(cmd, enabled);
@@ -195,7 +195,7 @@ static int __backup(struct volume_group *vg)
 
 	if (dm_snprintf(name, sizeof(name), "%s/%s",
 			 vg->cmd->backup_params->dir, vg->name) < 0) {
-		log_error("Failed to generate volume group metadata backup "
+		log_error(0, "Failed to generate volume group metadata backup "
 			  "filename.");
 		return 0;
 	}
@@ -224,7 +224,7 @@ int backup_locally(struct volume_group *vg)
 		return 0;
 
 	if (!__backup(vg)) {
-		log_error("Backup of volume group %s metadata failed.",
+		log_error(0, "Backup of volume group %s metadata failed.",
 			  vg->name);
 		return 0;
 	}
@@ -246,7 +246,7 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name)
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
 			 cmd->backup_params->dir, vg_name) < 0) {
-		log_err("Failed to generate backup filename (for removal).");
+		log_error(0, "Failed to generate backup filename (for removal).");
 		return 0;
 	}
 
@@ -269,7 +269,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 					    cmd->cmd_line)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
 							 NULL, context))) {
-		log_error("Couldn't create text format object.");
+		log_error(0, "Couldn't create text format object.");
 		return NULL;
 	}
 
@@ -298,7 +298,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 	/* Attempt to write out using currently active format */
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg->name,
 						       NULL, NULL))) {
-		log_error("Failed to allocate format instance");
+		log_error(0, "Failed to allocate format instance");
 		return 0;
 	}
 
@@ -306,19 +306,19 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
-			log_error("PV %s missing from cache",
+			log_error(0, "PV %s missing from cache",
 				  pv_dev_name(pv));
 			return 0;
 		}
 		if (cmd->fmt != info->fmt) {
-			log_error("PV %s is a different format (seqno %s)",
+			log_error(0, "PV %s is a different format (seqno %s)",
 				  pv_dev_name(pv), info->fmt->name);
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
 		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
-			log_error("Format-specific setup for %s failed",
+			log_error(0, "Format-specific setup for %s failed",
 				  pv_dev_name(pv));
 			return 0;
 		}
@@ -347,7 +347,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 	if (missing_pvs == 0)
 		r = backup_restore_vg(cmd, vg);
 	else
-		log_error("Cannot restore Volume Group %s with %i PVs "
+		log_error(0, "Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
 
 	vg_release(vg);
@@ -360,7 +360,7 @@ int backup_restore(struct cmd_context *cmd, const char *vg_name)
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
 			 cmd->backup_params->dir, vg_name) < 0) {
-		log_err("Failed to generate backup filename (for restore).");
+		log_error(0, "Failed to generate backup filename (for restore).");
 		return 0;
 	}
 
@@ -382,7 +382,7 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
 	if (!(context = create_text_context(cmd, file, desc)) ||
 	    !(tf = cmd->fmt_backup->ops->create_instance(cmd->fmt_backup, NULL,
 							 NULL, context))) {
-		log_error("Couldn't create backup object.");
+		log_error(0, "Couldn't create backup object.");
 		return 0;
 	}
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 482eea9..9746b4a 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -78,7 +78,7 @@ static void _init(void)
 		return;
 
 	if (uname(&_utsname)) {
-		log_error("uname failed: %s", strerror(errno));
+		log_error(0, "uname failed: %s", strerror(errno));
 		memset(&_utsname, 0, sizeof(_utsname));
 	}
 
@@ -99,7 +99,7 @@ static void _inc_indent(struct formatter *f)
 static void _dec_indent(struct formatter *f)
 {
 	if (!f->indent--) {
-		log_error("Internal error tracking indentation");
+		log_error(0, "Internal error tracking indentation");
 		f->indent = 0;
 	}
 }
@@ -122,7 +122,7 @@ static int _extend_buffer(struct formatter *f)
 		  f->data.buf.size * 2);
 	if (!(newbuf = dm_realloc(f->data.buf.start,
 				   f->data.buf.size * 2))) {
-		log_error("Buffer reallocation failed.");
+		log_error(0, "Buffer reallocation failed.");
 		return 0;
 	}
 	f->data.buf.start = newbuf;
@@ -307,7 +307,7 @@ static int _print_header(struct formatter *f,
 	outnl(f);
 
 	if (!(buf = alloca(escaped_len(desc)))) {
-		log_error("temporary stack allocation for description"
+		log_error(0, "temporary stack allocation for description"
 			  "string failed");
 		return 0;
 	}
@@ -420,7 +420,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 		outf(f, "id = \"%s\"", buffer);
 
 		if (!(buf = alloca(escaped_len(pv_dev_name(pv))))) {
-			log_error("temporary stack allocation for device name"
+			log_error(0, "temporary stack allocation for device name"
 				  "string failed");
 			return 0;
 		}
@@ -744,7 +744,7 @@ int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 
 	f->data.buf.size = 65536;	/* Initial metadata limit */
 	if (!(f->data.buf.start = dm_malloc(f->data.buf.size))) {
-		log_error("text_export buffer allocation failed");
+		log_error(0, "text_export buffer allocation failed");
 		goto out;
 	}
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 46bb95d..2e7a714 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -82,7 +82,7 @@ static struct flag *_get_flags(int type)
 		return _lv_flags;
 	}
 
-	log_err("Unknown flag set requested.");
+	log_error(0, "Unknown flag set requested.");
 	return NULL;
 }
 
@@ -129,7 +129,7 @@ int print_flags(uint32_t status, int type, char *buffer, size_t size)
 		return 0;
 
 	if (status)
-		log_error("Metadata inconsistency: Not all flags successfully "
+		log_error(0, "Metadata inconsistency: Not all flags successfully "
 			  "exported.");
 
 	return 1;
@@ -149,7 +149,7 @@ int read_flags(uint32_t *status, int type, struct config_value *cv)
 
 	while (cv) {
 		if (cv->type != CFG_STRING) {
-			log_err("Status value is not a string.");
+			log_error(0, "Status value is not a string.");
 			return 0;
 		}
 
@@ -169,7 +169,7 @@ int read_flags(uint32_t *status, int type, struct config_value *cv)
 			 */
 			s |= PARTIAL_VG;
 		} else if (!flags[f].description && (type & STATUS_FLAG)) {
-			log_err("Unknown status flag '%s'.", cv->v.str);
+			log_error(0, "Unknown status flag '%s'.", cv->v.str);
 			return 0;
 		}
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4181335..df5eb1e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -74,7 +74,7 @@ static int _text_vg_setup(struct format_instance *fid __attribute((unused)),
 			  struct volume_group *vg)
 {
 	if (vg->extent_size & (vg->extent_size - 1)) {
-		log_error("Extent size must be power of 2");
+		log_error(0, "Extent size must be power of 2");
 		return 0;
 	}
 
@@ -263,14 +263,14 @@ static int _text_lv_setup(struct format_instance *fid __attribute((unused)),
 
 	if (lv->size > max_size) {
 		char *dummy = display_size(max_size);
-		log_error("logical volumes cannot be larger than %s", dummy);
+		log_error(0, "logical volumes cannot be larger than %s", dummy);
 		dm_free(dummy);
 		return 0;
 	}
 */
 
 	if (!*lv->lvid.s && !lvid_create(&lv->lvid, &lv->vg->id)) {
-		log_error("Random lvid creation failed for %s/%s.",
+		log_error(0, "Random lvid creation failed for %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
@@ -301,7 +301,7 @@ static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
 	struct mda_header *mdah;
 
 	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
-		log_error("struct mda_header allocation failed");
+		log_error(0, "struct mda_header allocation failed");
 		return NULL;
 	}
 
@@ -311,25 +311,25 @@ static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
-		log_error("Incorrect metadata area header checksum");
+		log_error(0, "Incorrect metadata area header checksum");
 		goto bad;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
-		log_error("Wrong magic number in metadata area header");
+		log_error(0, "Wrong magic number in metadata area header");
 		goto bad;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
-		log_error("Incompatible metadata area header version: %d",
+		log_error(0, "Incompatible metadata area header version: %d",
 			  mdah->version);
 		goto bad;
 	}
 
 	if (mdah->start != dev_area->start) {
-		log_error("Incorrect start sector in metadata area header: %"
+		log_error(0, "Incorrect start sector in metadata area header: %"
 			  PRIu64, mdah->start);
 		goto bad;
 	}
@@ -466,7 +466,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("VG %s metadata too large for circular buffer",
+		log_error(0, "VG %s metadata too large for circular buffer",
 			  vg->name);
 		goto out;
 	}
@@ -548,7 +548,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!fidtc->raw_metadata_buf &&
 	    !(fidtc->raw_metadata_buf_size =
 			text_vg_export_raw(vg, "", &fidtc->raw_metadata_buf))) {
-		log_error("VG %s metadata writing failed", vg->name);
+		log_error(0, "VG %s metadata writing failed", vg->name);
 		goto out;
 	}
 
@@ -566,7 +566,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
 	    (mdac->rlocn.size >= mdah->size)) {
-		log_error("VG %s metadata too large for circular buffer",
+		log_error(0, "VG %s metadata too large for circular buffer",
 			  vg->name);
 		goto out;
 	}
@@ -685,7 +685,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
-		log_error("Failed to write metadata area header");
+		log_error(0, "Failed to write metadata area header");
 		goto out;
 	}
 
@@ -768,7 +768,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
-		log_error("Failed to write metadata area header");
+		log_error(0, "Failed to write metadata area header");
 		goto out;
 	}
 
@@ -799,7 +799,7 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
 		dm_pool_free(fid->fmt->cmd->mem, vg);
-		log_err("'%s' does not contain volume group '%s'.",
+		log_error(0, "'%s' does not contain volume group '%s'.",
 			read_path, vgname);
 		return NULL;
 	} else
@@ -852,13 +852,13 @@ static int _vg_write_file(struct format_instance *fid __attribute((unused)),
 		temp_dir[slash - tc->path_edit] = '\0';
 
 	} else {
-		log_error("Text format failed to determine directory.");
+		log_error(0, "Text format failed to determine directory.");
 		return 0;
 	}
 
 	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
 			      &vg->cmd->rand_seed)) {
-		log_err("Couldn't create temporary text file name.");
+		log_error(0, "Couldn't create temporary text file name.");
 		return 0;
 	}
 
@@ -872,7 +872,7 @@ static int _vg_write_file(struct format_instance *fid __attribute((unused)),
 	log_debug("Writing %s metadata to %s", vg->name, temp_file);
 
 	if (!text_vg_export_file(vg, tc->desc, fp)) {
-		log_error("Failed to write metadata to %s.", temp_file);
+		log_error(0, "Failed to write metadata to %s.", temp_file);
 		if (fclose(fp))
 			log_sys_error("fclose", temp_file);
 		return 0;
@@ -890,7 +890,7 @@ static int _vg_write_file(struct format_instance *fid __attribute((unused)),
 
 	if (rename(temp_file, tc->path_edit)) {
 		log_debug("Renaming %s to %s", temp_file, tc->path_edit);
-		log_error("%s: rename to %s failed: %s", temp_file,
+		log_error(0, "%s: rename to %s failed: %s", temp_file,
 			  tc->path_edit, strerror(errno));
 		return 0;
 	}
@@ -916,7 +916,7 @@ static int _vg_commit_file_backup(struct format_instance *fid __attribute((unuse
 		log_debug("Committing %s metadata (%u)", vg->name, vg->seqno);
 		log_debug("Renaming %s to %s", tc->path_edit, tc->path_live);
 		if (rename(tc->path_edit, tc->path_live)) {
-			log_error("%s: rename to %s failed: %s", tc->path_edit,
+			log_error(0, "%s: rename to %s failed: %s", tc->path_edit,
 				  tc->path_live, strerror(errno));
 			return 0;
 		}
@@ -953,7 +953,7 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 			log_verbose("Test mode: Skipping rename");
 		else {
 			if (rename(tc->path_live, new_name)) {
-				log_error("%s: rename to %s failed: %s",
+				log_error(0, "%s: rename to %s failed: %s",
 					  tc->path_live, new_name,
 					  strerror(errno));
 				sync_dir(new_name);
@@ -1014,7 +1014,7 @@ static int _scan_file(const struct format_type *fmt)
 				vgname = dirent->d_name;
 				if (dm_snprintf(path, PATH_MAX, "%s/%s",
 						 dl->dir, vgname) < 0) {
-					log_error("Name too long %s/%s",
+					log_error(0, "Name too long %s/%s",
 						  dl->dir, vgname);
 					break;
 				}
@@ -1087,7 +1087,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("%s: metadata too large for circular buffer",
+		log_error(0, "%s: metadata too large for circular buffer",
 			  dev_name(dev_area->dev));
 		goto out;
 	}
@@ -1195,7 +1195,7 @@ static int _mda_setup(const struct format_type *fmt,
 	pe_end <<= SECTOR_SHIFT;
 
 	if (pe_end > disk_size) {
-		log_error("Physical extents end beyond end of device %s!",
+		log_error(0, "Physical extents end beyond end of device %s!",
 			  pv_dev_name(pv));
 		return 0;
 	}
@@ -1247,7 +1247,7 @@ static int _mda_setup(const struct format_type *fmt,
 		if (!dev_set((struct device *) pv->dev, start1,
 			     (size_t) (mda_size1 >
 				       wipe_size ? : mda_size1), 0)) {
-			log_error("Failed to wipe new metadata area");
+			log_error(0, "Failed to wipe new metadata area");
 			return 0;
 		}
 
@@ -1292,7 +1292,7 @@ static int _mda_setup(const struct format_type *fmt,
 		if (!dev_set(pv->dev, start2,
 			     (size_t) (mda_size1 >
 				       wipe_size ? : mda_size1), 0)) {
-			log_error("Failed to wipe new metadata area");
+			log_error(0, "Failed to wipe new metadata area");
 			return 0;
 		}
 	} else
@@ -1427,7 +1427,7 @@ static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
 	}
 
 	if (!(rl = dm_malloc(sizeof(struct raw_list)))) {
-		log_error("_add_raw allocation failed");
+		log_error(0, "_add_raw allocation failed");
 		return 0;
 	}
 	memcpy(&rl->dev_area, dev_area, sizeof(*dev_area));
@@ -1475,7 +1475,7 @@ static int _populate_pv_fields(struct lvmcache_info *info,
 
 	/* Currently only support exactly one data area */
 	if (dm_list_size(&info->das) != 1) {
-		log_error("Must be exactly one data area (found %d) on PV %s",
+		log_error(0, "Must be exactly one data area (found %d) on PV %s",
 			  dm_list_size(&info->das), dev_name(info->dev));
 		return 0;
 	}
@@ -1513,11 +1513,11 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (!(mda_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda_new)))) {
-			log_error("metadata_area allocation failed");
+			log_error(0, "metadata_area allocation failed");
 			return 0;
 		}
 		if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac_new)))) {
-			log_error("metadata_area allocation failed");
+			log_error(0, "metadata_area allocation failed");
 			return 0;
 		}
 		memcpy(mda_new, mda, sizeof(*mda));
@@ -1676,7 +1676,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 			pe_count = (pv->size - pv->pe_start - mda_size2) /
 				   vg->extent_size;
 			if (pe_count > UINT32_MAX) {
-				log_error("PV %s too large for extent size %s.",
+				log_error(0, "PV %s too large for extent size %s.",
 					  pv_dev_name(pv),
 					  display_size(vg->cmd, (uint64_t) vg->extent_size));
 				return 0;
@@ -1733,13 +1733,13 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 	struct lvmcache_info *info;
 
 	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Couldn't allocate format instance object.");
+		log_error(0, "Couldn't allocate format instance object.");
 		return NULL;
 	}
 
 	if (!(fidtc = (struct text_fid_context *)
 			dm_pool_zalloc(fmt->cmd->mem,sizeof(*fidtc)))) {
-		log_error("Couldn't allocate text_fid_context.");
+		log_error(0, "Couldn't allocate text_fid_context.");
 		return NULL;
 	}
 
@@ -1761,7 +1761,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 		dm_list_iterate_items(dl, dir_list) {
 			if (dm_snprintf(path, PATH_MAX, "%s/%s",
 					 dl->dir, vgname) < 0) {
-				log_error("Name too long %s/%s", dl->dir,
+				log_error(0, "Name too long %s/%s", dl->dir,
 					  vgname);
 				return NULL;
 			}
@@ -1833,7 +1833,7 @@ void *create_text_context(struct cmd_context *cmd, const char *path,
 	char *tmp;
 
 	if ((tmp = strstr(path, ".tmp")) && (tmp == path + strlen(path) - 4)) {
-		log_error("%s: Volume group filename may not end in .tmp",
+		log_error(0, "%s: Volume group filename may not end in .tmp",
 			  path);
 		return NULL;
 	}
@@ -1860,7 +1860,7 @@ void *create_text_context(struct cmd_context *cmd, const char *path,
       bad:
 	dm_pool_free(cmd->mem, tc);
 
-	log_err("Couldn't allocate text format context object.");
+	log_error(0, "Couldn't allocate text format context object.");
 	return NULL;
 }
 
@@ -1882,7 +1882,7 @@ static int _add_dir(const char *dir, struct dm_list *dir_list)
 
 	if (dm_create_dir(dir)) {
 		if (!(dl = dm_malloc(sizeof(struct dm_list) + strlen(dir) + 1))) {
-			log_error("_add_dir allocation failed");
+			log_error(0, "_add_dir allocation failed");
 			return 0;
 		}
 		log_very_verbose("Adding text format metadata dir: %s", dir);
@@ -1902,32 +1902,32 @@ static int _get_config_disk_area(struct cmd_context *cmd,
 	struct id id;
 
 	if (!(cn = cn->child)) {
-		log_error("Empty metadata disk_area section of config file");
+		log_error(0, "Empty metadata disk_area section of config file");
 		return 0;
 	}
 
 	if (!get_config_uint64(cn, "start_sector", &dev_area.start)) {
-		log_error("Missing start_sector in metadata disk_area section "
+		log_error(0, "Missing start_sector in metadata disk_area section "
 			  "of config file");
 		return 0;
 	}
 	dev_area.start <<= SECTOR_SHIFT;
 
 	if (!get_config_uint64(cn, "size", &dev_area.size)) {
-		log_error("Missing size in metadata disk_area section "
+		log_error(0, "Missing size in metadata disk_area section "
 			  "of config file");
 		return 0;
 	}
 	dev_area.size <<= SECTOR_SHIFT;
 
 	if (!get_config_str(cn, "id", &id_str)) {
-		log_error("Missing uuid in metadata disk_area section "
+		log_error(0, "Missing uuid in metadata disk_area section "
 			  "of config file");
 		return 0;
 	}
 
 	if (!id_read_format(&id, id_str)) {
-		log_error("Invalid uuid in metadata disk_area section "
+		log_error(0, "Invalid uuid in metadata disk_area section "
 			  "of config file: %s", id_str);
 		return 0;
 	}
@@ -1936,9 +1936,9 @@ static int _get_config_disk_area(struct cmd_context *cmd,
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
-			log_err("Couldn't find device.");
+			log_error(0, "Couldn't find device.");
 		else
-			log_err("Couldn't find device with uuid '%s'.", buffer);
+			log_error(0, "Couldn't find device with uuid '%s'.", buffer);
 
 		return 0;
 	}
@@ -1966,7 +1966,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 			FMT_UNLIMITED_STRIPESIZE;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
-		log_error("Failed to allocate dir_list");
+		log_error(0, "Failed to allocate dir_list");
 		dm_free(fmt);
 		return NULL;
 	}
@@ -1978,13 +1978,13 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->private = (void *) mda_lists;
 
 	if (!(fmt->labeller = text_labeller_create(fmt))) {
-		log_error("Couldn't create text label handler.");
+		log_error(0, "Couldn't create text label handler.");
 		dm_free(fmt);
 		return NULL;
 	}
 
 	if (!(label_register_handler(FMT_TEXT_NAME, fmt->labeller))) {
-		log_error("Couldn't register text label handler.");
+		log_error(0, "Couldn't register text label handler.");
 		dm_free(fmt);
 		return NULL;
 	}
@@ -1992,13 +1992,13 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	if ((cn = find_config_tree_node(cmd, "metadata/dirs"))) {
 		for (cv = cn->v; cv; cv = cv->next) {
 			if (cv->type != CFG_STRING) {
-				log_error("Invalid string in config file: "
+				log_error(0, "Invalid string in config file: "
 					  "metadata/dirs");
 				goto err;
 			}
 
 			if (!_add_dir(cv->v.str, &mda_lists->dirs)) {
-				log_error("Failed to add %s to text format "
+				log_error(0, "Failed to add %s to text format "
 					  "metadata directory list ", cv->v.str);
 				goto err;
 			}
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 3bd6828..4ed4ea0 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -100,7 +100,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if ((!dev && !read_config_file(cft)) ||
 	    (dev && !read_config_fd(cft, dev, offset, size,
 				    offset2, size2, checksum_fn, checksum))) {
-		log_error("Couldn't read volume group metadata.");
+		log_error(0, "Couldn't read volume group metadata.");
 		goto out;
 	}
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d8d8fcb..13b9a60 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -43,7 +43,7 @@ typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
  */
 static void _invalid_format(const char *str)
 {
-	log_error("Can't process text format file - %s.", str);
+	log_error(0, "Can't process text format file - %s.", str);
 }
 
 /*
@@ -107,18 +107,18 @@ static int _read_id(struct id *id, struct config_node *cn, const char *path)
 	struct config_value *cv;
 
 	if (!(cn = find_config_node(cn, path))) {
-		log_error("Couldn't find uuid.");
+		log_error(0, "Couldn't find uuid.");
 		return 0;
 	}
 
 	cv = cn->v;
 	if (!cv || !cv->v.str) {
-		log_error("uuid must be a string.");
+		log_error(0, "uuid must be a string.");
 		return 0;
 	}
 
 	if (!id_read_format(id, cv->v.str)) {
-		log_error("Invalid uuid.");
+		log_error(0, "Invalid uuid.");
 		return 0;
 	}
 
@@ -131,18 +131,18 @@ static int _read_flag_config(struct config_node *n, uint32_t *status, int type)
 	*status = 0;
 
 	if (!(cn = find_config_node(n, "status"))) {
-		log_error("Could not find status flags.");
+		log_error(0, "Could not find status flags.");
 		return 0;
 	}
 
 	if (!(read_flags(status, type | STATUS_FLAG, cn->v))) {
-		log_error("Could not read status flags.");
+		log_error(0, "Could not read status flags.");
 		return 0;
 	}
 
 	if ((cn = find_config_node(n, "flags"))) {
 		if (!(read_flags(status, type, cn->v))) {
-			log_error("Could not read flags.");
+			log_error(0, "Could not read flags.");
 			return 0;
 		}
 	}
@@ -174,12 +174,12 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		return_0;
 
 	if (!(pvn = pvn->child)) {
-		log_error("Empty pv section.");
+		log_error(0, "Empty pv section.");
 		return 0;
 	}
 
 	if (!_read_id(&pv->id, pvn, "id")) {
-		log_error("Couldn't read uuid for physical volume.");
+		log_error(0, "Couldn't read uuid for physical volume.");
 		return 0;
 	}
 
@@ -190,9 +190,9 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			log_error("Couldn't find device.");
+			log_error(0, "Couldn't find device.");
 		else
-			log_error("Couldn't find device with uuid '%s'.",
+			log_error(0, "Couldn't find device with uuid '%s'.",
 				  buffer);
 	}
 
@@ -202,7 +202,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 
 	if (!_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
-		log_error("Couldn't read status flags for physical volume.");
+		log_error(0, "Couldn't read status flags for physical volume.");
 		return 0;
 	}
 
@@ -213,12 +213,12 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	_read_int64(pvn, "dev_size", &pv->size);
 
 	if (!_read_int64(pvn, "pe_start", &pv->pe_start)) {
-		log_error("Couldn't read extent size for physical volume.");
+		log_error(0, "Couldn't read extent size for physical volume.");
 		return 0;
 	}
 
 	if (!_read_int32(pvn, "pe_count", &pv->pe_count)) {
-		log_error("Couldn't find extent count (pe_count) for "
+		log_error(0, "Couldn't find extent count (pe_count) for "
 			  "physical volume.");
 		return 0;
 	}
@@ -229,7 +229,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	/* Optional tags */
 	if ((cn = find_config_node(pvn, "tags")) &&
 	    !(read_tags(mem, &pv->tags, cn->v))) {
-		log_error("Couldn't read tags for physical volume %s in %s.",
+		log_error(0, "Couldn't read tags for physical volume %s in %s.",
 			  pv_dev_name(pv), vg->name);
 		return 0;
 	}
@@ -247,7 +247,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	/* Fix up pv size if missing or impossibly large */
 	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
 		if (!dev_get_size(pv->dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", pv_dev_name(pv));
+			log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 			return 0;
 		}
 		log_verbose("Fixing up missing size (%s) "
@@ -257,7 +257,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 			size = pv->pe_count * (uint64_t) vg->extent_size +
 			       pv->pe_start;
 			if (size > pv->size)
-				log_error("WARNING: Physical Volume %s is too "
+				log_error(0, "WARNING: Physical Volume %s is too "
 					  "large for underlying device",
 					  pv_dev_name(pv));
 		}
@@ -300,18 +300,18 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 	const char *segtype_str;
 
 	if (!(sn = sn->child)) {
-		log_error("Empty segment section.");
+		log_error(0, "Empty segment section.");
 		return 0;
 	}
 
 	if (!_read_int32(sn, "start_extent", &start_extent)) {
-		log_error("Couldn't read 'start_extent' for segment '%s'.",
+		log_error(0, "Couldn't read 'start_extent' for segment '%s'.",
 			  sn->key);
 		return 0;
 	}
 
 	if (!_read_int32(sn, "extent_count", &extent_count)) {
-		log_error("Couldn't read 'extent_count' for segment '%s'.",
+		log_error(0, "Couldn't read 'extent_count' for segment '%s'.",
 			  sn->key);
 		return 0;
 	}
@@ -321,7 +321,7 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 	if ((cn = find_config_node(sn, "type"))) {
 		cv = cn->v;
 		if (!cv || !cv->v.str) {
-			log_error("Segment type must be a string.");
+			log_error(0, "Segment type must be a string.");
 			return 0;
 		}
 		segtype_str = cv->v.str;
@@ -337,7 +337,7 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
 				     extent_count, 0, 0, NULL, area_count,
 				     extent_count, 0, 0, 0))) {
-		log_error("Segment allocation failed");
+		log_error(0, "Segment allocation failed");
 		return 0;
 	}
 
@@ -348,7 +348,7 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 	/* Optional tags */
 	if ((cn = find_config_node(sn, "tags")) &&
 	    !(read_tags(mem, &seg->tags, cn->v))) {
-		log_error("Couldn't read tags for a segment of %s/%s.",
+		log_error(0, "Couldn't read tags for a segment of %s/%s.",
 			  vg->name, lv->name);
 		return 0;
 	}
@@ -380,7 +380,7 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 	const char *seg_name = sn->key;
 
 	if (!seg->area_count) {
-		log_error("Zero areas not allowed for segment '%s'", sn->key);
+		log_error(0, "Zero areas not allowed for segment '%s'", sn->key);
 		return 0;
 	}
 
@@ -392,17 +392,17 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		struct physical_volume *pv;
 
 		if (cv->type != CFG_STRING) {
-			log_error(bad, sn->key);
+			log_error(0, bad, sn->key);
 			return 0;
 		}
 
 		if (!cv->next) {
-			log_error(bad, sn->key);
+			log_error(0, bad, sn->key);
 			return 0;
 		}
 
 		if (cv->next->type != CFG_INT) {
-			log_error(bad, sn->key);
+			log_error(0, bad, sn->key);
 			return 0;
 		}
 
@@ -416,7 +416,7 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 						    flags))
 				return_0;
 		} else {
-			log_error("Couldn't find volume '%s' "
+			log_error(0, "Couldn't find volume '%s' "
 				  "for segment '%s'.",
 				  cv->v.str ? : "NULL", seg_name);
 			return 0;
@@ -429,7 +429,7 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 	 * Check we read the correct number of stripes.
 	 */
 	if (cv || (s < seg->area_count)) {
-		log_error("Incorrect number of areas in area array "
+		log_error(0, "Incorrect number of areas in area array "
 			  "for segment '%s'.", seg_name);
 		return 0;
 	}
@@ -457,18 +457,18 @@ static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
 		}
 		/* FIXME Remove this restriction */
 		if ((lv->status & SNAPSHOT) && count > 1) {
-			log_error("Only one segment permitted for snapshot");
+			log_error(0, "Only one segment permitted for snapshot");
 			return 0;
 		}
 	}
 
 	if (!_read_int32(lvn, "segment_count", &seg_count)) {
-		log_error("Couldn't read segment count for logical volume.");
+		log_error(0, "Couldn't read segment count for logical volume.");
 		return 0;
 	}
 
 	if (seg_count != count) {
-		log_error("segment_count and actual number of segments "
+		log_error(0, "segment_count and actual number of segments "
 			  "disagree.");
 		return 0;
 	}
@@ -504,12 +504,12 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 		return_0;
 
 	if (!(lvn = lvn->child)) {
-		log_error("Empty logical volume section.");
+		log_error(0, "Empty logical volume section.");
 		return 0;
 	}
 
 	if (!_read_flag_config(lvn, &lv->status, LV_FLAGS)) {
-		log_error("Couldn't read status flags for logical volume %s.",
+		log_error(0, "Couldn't read status flags for logical volume %s.",
 			  lv->name);
 		return 0;
 	}
@@ -518,7 +518,7 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 	if ((cn = find_config_node(lvn, "allocation_policy"))) {
 		struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
-			log_error("allocation_policy must be a string.");
+			log_error(0, "allocation_policy must be a string.");
 			return 0;
 		}
 
@@ -552,7 +552,7 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
 	/* Optional tags */
 	if ((cn = find_config_node(lvn, "tags")) &&
 	    !(read_tags(mem, &lv->tags, cn->v))) {
-		log_error("Couldn't read tags for logical volume %s/%s.",
+		log_error(0, "Couldn't read tags for logical volume %s/%s.",
 			  vg->name, lv->name);
 		return 0;
 	}
@@ -570,20 +570,20 @@ static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
 	struct lv_list *lvl;
 
 	if (!(lvl = find_lv_in_vg(vg, lvn->key))) {
-		log_error("Lost logical volume reference %s", lvn->key);
+		log_error(0, "Lost logical volume reference %s", lvn->key);
 		return 0;
 	}
 
 	lv = lvl->lv;
 
 	if (!(lvn = lvn->child)) {
-		log_error("Empty logical volume section.");
+		log_error(0, "Empty logical volume section.");
 		return 0;
 	}
 
 	/* FIXME: read full lvid */
 	if (!_read_id(&lv->lvid.id[1], lvn, "id")) {
-		log_error("Couldn't read uuid for logical volume %s.",
+		log_error(0, "Couldn't read uuid for logical volume %s.",
 			  lv->name);
 		return 0;
 	}
@@ -598,7 +598,7 @@ static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
 	lv->minor = -1;
 	if ((lv->status & FIXED_MINOR) &&
 	    !_read_int32(lvn, "minor", &lv->minor)) {
-		log_error("Couldn't read minor number for logical "
+		log_error(0, "Couldn't read minor number for logical "
 			  "volume %s.", lv->name);
 		return 0;
 	}
@@ -606,7 +606,7 @@ static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
 	lv->major = -1;
 	if ((lv->status & FIXED_MINOR) &&
 	    !_read_int32(lvn, "major", &lv->major)) {
-		log_error("Couldn't read major number for logical "
+		log_error(0, "Couldn't read major number for logical "
 			  "volume %s.", lv->name);
 	}
 
@@ -623,7 +623,7 @@ static int _read_sections(struct format_instance *fid,
 
 	if (!(n = find_config_node(vgn, section))) {
 		if (!optional) {
-			log_error("Couldn't find section '%s'.", section);
+			log_error(0, "Couldn't find section '%s'.", section);
 			return 0;
 		}
 
@@ -653,7 +653,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
 
 	if (!vgn) {
-		log_error("Couldn't find volume group in file.");
+		log_error(0, "Couldn't find volume group in file.");
 		goto bad;
 	}
 
@@ -677,31 +677,31 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	if ((cn = find_config_node(vgn, "system_id")) && cn->v) {
 		if (!cn->v->v.str) {
-			log_error("system_id must be a string");
+			log_error(0, "system_id must be a string");
 			goto bad;
 		}
 		strncpy(vg->system_id, cn->v->v.str, NAME_LEN);
 	}
 
 	if (!_read_id(&vg->id, vgn, "id")) {
-		log_error("Couldn't read uuid for volume group %s.", vg->name);
+		log_error(0, "Couldn't read uuid for volume group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_int32(vgn, "seqno", &vg->seqno)) {
-		log_error("Couldn't read 'seqno' for volume group %s.",
+		log_error(0, "Couldn't read 'seqno' for volume group %s.",
 			  vg->name);
 		goto bad;
 	}
 
 	if (!_read_flag_config(vgn, &vg->status, VG_FLAGS)) {
-		log_error("Error reading flags of volume group %s.",
+		log_error(0, "Error reading flags of volume group %s.",
 			  vg->name);
 		goto bad;
 	}
 
 	if (!_read_int32(vgn, "extent_size", &vg->extent_size)) {
-		log_error("Couldn't read extent size for volume group %s.",
+		log_error(0, "Couldn't read extent size for volume group %s.",
 			  vg->name);
 		goto bad;
 	}
@@ -712,13 +712,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	 */
 
 	if (!_read_int32(vgn, "max_lv", &vg->max_lv)) {
-		log_error("Couldn't read 'max_lv' for volume group %s.",
+		log_error(0, "Couldn't read 'max_lv' for volume group %s.",
 			  vg->name);
 		goto bad;
 	}
 
 	if (!_read_int32(vgn, "max_pv", &vg->max_pv)) {
-		log_error("Couldn't read 'max_pv' for volume group %s.",
+		log_error(0, "Couldn't read 'max_pv' for volume group %s.",
 			  vg->name);
 		goto bad;
 	}
@@ -727,7 +727,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
 		struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
-			log_error("allocation_policy must be a string.");
+			log_error(0, "allocation_policy must be a string.");
 			return 0;
 		}
 
@@ -741,14 +741,14 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	 * structures.
 	 */
 	if (!(pv_hash = dm_hash_create(32))) {
-		log_error("Couldn't create hash table.");
+		log_error(0, "Couldn't create hash table.");
 		goto bad;
 	}
 
 	dm_list_init(&vg->pvs);
 	if (!_read_sections(fid, "physical_volumes", _read_pv, mem, vg,
 			    vgn, pv_hash, 0)) {
-		log_error("Couldn't find all physical volumes for volume "
+		log_error(0, "Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
@@ -759,26 +759,26 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
 	    !(read_tags(mem, &vg->tags, cn->v))) {
-		log_error("Couldn't read tags for volume group %s.", vg->name);
+		log_error(0, "Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvnames, mem, vg,
 			    vgn, pv_hash, 1)) {
-		log_error("Couldn't read all logical volume names for volume "
+		log_error(0, "Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, mem, vg,
 			    vgn, pv_hash, 1)) {
-		log_error("Couldn't read all logical volumes for "
+		log_error(0, "Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!fixup_imported_mirrors(vg)) {
-		log_error("Failed to fixup mirror pointers after import for "
+		log_error(0, "Failed to fixup mirror pointers after import for "
 			  "volume group %s.", vg->name);
 		goto bad;
 	}
@@ -833,7 +833,7 @@ static const char *_read_vgname(const struct format_type *fmt,
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
 
 	if (!vgn) {
-		log_error("Couldn't find volume group in file.");
+		log_error(0, "Couldn't find volume group in file.");
 		return 0;
 	}
 
@@ -843,12 +843,12 @@ static const char *_read_vgname(const struct format_type *fmt,
 	vgn = vgn->child;
 
 	if (!_read_id(vgid, vgn, "id")) {
-		log_error("Couldn't read uuid for volume group %s.", vgname);
+		log_error(0, "Couldn't read uuid for volume group %s.", vgname);
 		return 0;
 	}
 
 	if (!_read_flag_config(vgn, vgstatus, VG_FLAGS)) {
-		log_error("Couldn't find status flags for volume group %s.",
+		log_error(0, "Couldn't find status flags for volume group %s.",
 			  vgname);
 		return 0;
 	}
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index eeb0af7..debebc4 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -51,7 +51,7 @@ int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv
 
 	while (cv) {
 		if (cv->type != CFG_STRING) {
-			log_error("Found a tag that is not a string");
+			log_error(0, "Found a tag that is not a string");
 			return 0;
 		}
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 110bc1d..e9344b0 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -137,7 +137,7 @@ static int _text_write(struct label *label, void *buf)
 		  mda2 ? "s)" : "");
 
 	if (da1 < 0) {
-		log_error("Internal error: %s label header currently requires "
+		log_error(0, "Internal error: %s label header currently requires "
 			  "a data area.", dev_name(info->dev));
 		return 0;
 	}
@@ -152,12 +152,12 @@ int add_da(struct dm_pool *mem, struct dm_list *das,
 
 	if (!mem) {
 		if (!(dal = dm_malloc(sizeof(*dal)))) {
-			log_error("struct data_area_list allocation failed");
+			log_error(0, "struct data_area_list allocation failed");
 			return 0;
 		}
 	} else {
 		if (!(dal = dm_pool_alloc(mem, sizeof(*dal)))) {
-			log_error("struct data_area_list allocation failed");
+			log_error(0, "struct data_area_list allocation failed");
 			return 0;
 		}
 	}
@@ -192,23 +192,23 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 
 	if (!mem) {
 		if (!(mdal = dm_malloc(sizeof(struct metadata_area)))) {
-			log_error("struct mda_list allocation failed");
+			log_error(0, "struct mda_list allocation failed");
 			return 0;
 		}
 
 		if (!(mdac = dm_malloc(sizeof(struct mda_context)))) {
-			log_error("struct mda_context allocation failed");
+			log_error(0, "struct mda_context allocation failed");
 			dm_free(mdal);
 			return 0;
 		}
 	} else {
 		if (!(mdal = dm_pool_alloc(mem, sizeof(struct metadata_area)))) {
-			log_error("struct mda_list allocation failed");
+			log_error(0, "struct mda_list allocation failed");
 			return 0;
 		}
 
 		if (!(mdac = dm_pool_alloc(mem, sizeof(struct mda_context)))) {
-			log_error("struct mda_context allocation failed");
+			log_error(0, "struct mda_context allocation failed");
 			return 0;
 		}
 	}
@@ -343,7 +343,7 @@ struct labeller *text_labeller_create(const struct format_type *fmt)
 	struct labeller *l;
 
 	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_err("Couldn't allocate labeller object.");
+		log_error(0, "Couldn't allocate labeller object.");
 		return NULL;
 	}
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 8924735..df6c60d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -46,7 +46,7 @@ static struct labeller_i *_alloc_li(const char *name, struct labeller *l)
 	len = sizeof(*li) + strlen(name) + 1;
 
 	if (!(li = dm_malloc(len))) {
-		log_error("Couldn't allocate memory for labeller list object.");
+		log_error(0, "Couldn't allocate memory for labeller list object.");
 		return NULL;
 	}
 
@@ -130,7 +130,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
-				log_error("Ignoring additional label on %s at "
+				log_error(0, "Ignoring additional label on %s at "
 					  "sector %" PRIu64, dev_name(dev),
 					  sector + scan_sector);
 			}
@@ -159,7 +159,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 				log_very_verbose("%s: %s label detected",
 						 dev_name(dev), li->name);
 				if (found) {
-					log_error("Ignoring additional label "
+					log_error(0, "Ignoring additional label "
 						  "on %s at sector %" PRIu64,
 						  dev_name(dev),
 						  sector + scan_sector);
@@ -242,7 +242,7 @@ int label_remove(struct device *dev)
 				 dev_name(dev), sector);
 			if (!dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE,
 				       buf)) {
-				log_error("Failed to remove label from %s at "
+				log_error(0, "Failed to remove label from %s@"
 					  "sector %" PRIu64, dev_name(dev),
 					  sector);
 				r = 0;
@@ -304,12 +304,12 @@ int label_write(struct device *dev, struct label *label)
 	int r = 1;
 
 	if (!label->labeller->ops->write) {
-		log_err("Label handler does not support label writes");
+		log_error(0, "Label handler does not support label writes");
 		return 0;
 	}
 
 	if ((LABEL_SIZE + (label->sector << SECTOR_SHIFT)) > LABEL_SCAN_SIZE) {
-		log_error("Label sector %" PRIu64 " beyond range (%ld)",
+		log_error(0, "Label sector %" PRIu64 " beyond range (%ld)",
 			  label->sector, LABEL_SCAN_SECTORS);
 		return 0;
 	}
@@ -384,7 +384,7 @@ struct label *label_create(struct labeller *labeller)
 	struct label *label;
 
 	if (!(label = dm_malloc(sizeof(*label)))) {
-		log_error("label allocaction failed");
+		log_error(0, "label allocaction failed");
 		return NULL;
 	}
 	memset(label, 0, sizeof(*label));
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index eb09241..f2beb94 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -69,7 +69,7 @@ static int _open_local_sock(void)
 
 	/* Open local socket */
 	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
-		log_error("Local socket creation failed: %s", strerror(errno));
+		log_error(0, "Local socket creation failed: %s", strerror(errno));
 		return -1;
 	}
 
@@ -82,7 +82,7 @@ static int _open_local_sock(void)
 		    sizeof(sockaddr))) {
 		int saved_errno = errno;
 
-		log_error("connect() failed on local socket: %s",
+		log_error(0, "connect() failed on local socket: %s",
 			  strerror(errno));
 		if (close(local_socket))
 			stack;
@@ -109,7 +109,7 @@ static int _send_request(char *inbuf, int inlen, char **retbuf)
 	if ( (err = write(_clvmd_sock, inbuf, inlen)) != inlen) {
 		if (err == -1 && errno == EINTR)
 			goto rewrite;
-		log_error("Error writing data to clvmd: %s", strerror(errno));
+		log_error(0, "Error writing data to clvmd: %s", strerror(errno));
 		return 0;
 	}
 
@@ -118,12 +118,12 @@ static int _send_request(char *inbuf, int inlen, char **retbuf)
 	if ((len = read(_clvmd_sock, outbuf, sizeof(struct clvm_header))) < 0) {
 		if (errno == EINTR)
 			goto reread;
-		log_error("Error reading data from clvmd: %s", strerror(errno));
+		log_error(0, "Error reading data from clvmd: %s", strerror(errno));
 		return 0;
 	}
 
 	if (len == 0) {
-		log_error("EOF reading CLVMD");
+		log_error(0, "EOF reading CLVMD");
 		errno = ENOTCONN;
 		return 0;
 	}
@@ -156,7 +156,7 @@ static int _send_request(char *inbuf, int inlen, char **retbuf)
 		/* Only return an error here if there are no node-specific
 		   errors present in the message that might have more detail */
 		if (!(outheader->flags & CLVMD_FLAG_NODEERRS)) {
-			log_error("cluster request failed: %s", strerror(errno));
+			log_error(0, "cluster request failed: %s", strerror(errno));
 			return 0;
 		}
 
@@ -351,12 +351,12 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 	/* If any nodes were down then display them and return an error */
 	for (i = 0; i < num_responses; i++) {
 		if (response[i].status == EHOSTDOWN) {
-			log_error("clvmd not running on node %s",
+			log_error(0, "clvmd not running on node %s",
 				  response[i].node);
 			status = 0;
 			errno = response[i].status;
 		} else if (response[i].status) {
-			log_error("Error locking on node %s: %s",
+			log_error(0, "Error locking on node %s: %s",
 				  response[i].node,
 				  response[i].response[0] ?
 				  	response[i].response :
@@ -419,7 +419,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		break;
 
 	default:
-		log_error("Unrecognised lock scope: %d",
+		log_error(0, "Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
 		return 0;
 	}
@@ -444,7 +444,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		lock_type = "EX";
 		break;
 	default:
-		log_error("Unrecognised lock type: %u",
+		log_error(0, "Unrecognised lock type: %u",
 			  flags & LCK_TYPE_MASK);
 		return 0;
 	}
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index 949d065..3958c5e 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -62,7 +62,7 @@ int init_external_locking(struct locking_type *locking, struct cmd_context *cmd)
 	const char *libname;
 
 	if (_locking_lib) {
-		log_error("External locking already initialised");
+		log_error(0, "External locking already initialised");
 		return 1;
 	}
 
@@ -82,7 +82,7 @@ int init_external_locking(struct locking_type *locking, struct cmd_context *cmd)
 	    !(_lock_fn = dlsym(_locking_lib, "lock_resource")) ||
 	    !(_reset_fn = dlsym(_locking_lib, "reset_locking")) ||
 	    !(_end_fn = dlsym(_locking_lib, "locking_end"))) {
-		log_error("Shared library %s does not contain locking "
+		log_error(0, "Shared library %s does not contain locking "
 			  "functions", libname);
 		dlclose(_locking_lib);
 		_locking_lib = NULL;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index e205577..2e24c68 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -108,7 +108,7 @@ static void _remove_ctrl_c_handler(void)
 static void _trap_ctrl_c(int sig __attribute((unused)))
 {
 	_remove_ctrl_c_handler();
-	log_error("CTRL-c detected: giving up waiting for lock");
+	log_error(0, "CTRL-c detected: giving up waiting for lock");
 }
 
 static void _install_ctrl_c_handler()
@@ -146,7 +146,7 @@ static int _lock_file(const char *file, uint32_t flags)
 	case LCK_UNLOCK:
 		return _release_lock(file, 1);
 	default:
-		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
+		log_error(0, "Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
 		return 0;
 	}
 
@@ -263,7 +263,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 		}
 		break;
 	default:
-		log_error("Unrecognised lock scope: %d",
+		log_error(0, "Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
 		return 0;
 	}
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 5c04b4f..93807fb 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -257,7 +257,7 @@ int init_locking(int type, struct cmd_context *cmd)
 #endif
 
 	default:
-		log_error("Unknown locking type requested.");
+		log_error(0, "Unknown locking type requested.");
 		return 0;
 	}
 
@@ -307,12 +307,12 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
 
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/VGs/%s", cmd->proc_dir,
 			 vgname) < 0) {
-		log_error("LVM1 proc VG pathname too long for %s", vgname);
+		log_error(0, "LVM1 proc VG pathname too long for %s", vgname);
 		return 0;
 	}
 
 	if (stat(path, &info) == 0) {
-		log_error("%s exists: Is the original LVM driver using "
+		log_error(0, "%s exists: Is the original LVM driver using "
 			  "this volume group?", path);
 		return 0;
 	} else if (errno != ENOENT && errno != ENOTDIR) {
@@ -337,12 +337,12 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t fla
 	assert(resource);
 
 	if (!*resource) {
-		log_error("Internal error: Use of P_orphans is deprecated.");
+		log_error(0, "Internal error: Use of P_orphans is deprecated.");
 		return 0;
 	}
 
 	if (*resource == '#' && (flags & LCK_CACHE)) {
-		log_error("Internal error: P_%s referenced", resource);
+		log_error(0, "Internal error: P_%s referenced", resource);
 		return 0;
 	}
 
@@ -393,7 +393,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 		strncpy(resource, vol, sizeof(resource));
 		break;
 	default:
-		log_error("Unrecognised lock scope: %d",
+		log_error(0, "Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
 		return 0;
 	}
@@ -434,7 +434,7 @@ int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 
 	dm_list_iterate_items(lvl, lvs) {
 		if (!suspend_lv(cmd, lvl->lv)) {
-			log_error("Failed to suspend %s", lvl->lv->name);
+			log_error(0, "Failed to suspend %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				resume_lv(cmd, lvl->lv);
@@ -456,11 +456,11 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusiv
 	dm_list_iterate_items(lvl, lvs) {
 		if (!exclusive) {
 			if (!activate_lv(cmd, lvl->lv)) {
-				log_error("Failed to activate %s", lvl->lv->name);
+				log_error(0, "Failed to activate %s", lvl->lv->name);
 				return 0;
 			}
 		} else if (!activate_lv_excl(cmd, lvl->lv)) {
-			log_error("Failed to activate %s", lvl->lv->name);
+			log_error(0, "Failed to activate %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				activate_lv(cmd, lvl->lv);
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 5eebafa..828cee8 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -58,7 +58,7 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 		}
 		break;
 	default:
-		log_error("Unrecognised lock scope: %d",
+		log_error(0, "Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
 		return 0;
 	}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cd741cb..507c1f3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -47,7 +47,7 @@ int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
 			 seg->lv->name, seg->le, lv->name);
 
 	if (!(sl = dm_pool_zalloc(lv->vg->cmd->mem, sizeof(*sl)))) {
-		log_error("Failed to allocate segment list");
+		log_error(0, "Failed to allocate segment list");
 		return 0;
 	}
 
@@ -92,7 +92,7 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv)
 	struct seg_list *sl;
 
 	if (dm_list_size(&lv->segs_using_this_lv) != 1) {
-		log_error("%s is expected to have only one segment using it, "
+		log_error(0, "%s is expected to have only one segment using it, "
 			  "while it has %d", lv->name,
 			  dm_list_size(&lv->segs_using_this_lv));
 		return NULL;
@@ -101,7 +101,7 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv)
 	sl = dm_list_item(dm_list_first(&lv->segs_using_this_lv), struct seg_list);
 
 	if (sl->count != 1) {
-		log_error("%s is expected to have only one segment using it, "
+		log_error(0, "%s is expected to have only one segment using it, "
 			  "while %s:%" PRIu32 " uses it %d times",
 			  lv->name, sl->seg->lv->name, sl->seg->le, sl->count);
 		return NULL;
@@ -187,7 +187,7 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 	}
 
 	if (!segtype) {
-		log_error("alloc_lv_segment: Missing segtype.");
+		log_error(0, "alloc_lv_segment: Missing segtype.");
 		return NULL;
 	}
 
@@ -219,7 +219,7 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 
 	segtype = get_segtype_from_string(lv->vg->cmd, "snapshot");
 	if (!segtype) {
-		log_error("Failed to find snapshot segtype");
+		log_error(0, "Failed to find snapshot segtype");
 		return NULL;
 	}
 
@@ -227,7 +227,7 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				     lv->le_count - old_le_count, status, 0,
 				     NULL, 0, lv->le_count - old_le_count,
 				     0, 0, 0))) {
-		log_error("Couldn't allocate new snapshot segment.");
+		log_error(0, "Couldn't allocate new snapshot segment.");
 		return NULL;
 	}
 
@@ -379,7 +379,7 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 	/* Caller must ensure exact divisibility */
 	if (seg_is_striped(seg)) {
 		if (reduction % seg->area_count) {
-			log_error("Segment extent reduction %" PRIu32
+			log_error(0, "Segment extent reduction %" PRIu32
 				  "not divisible by #stripes %" PRIu32,
 				  reduction, seg->area_count);
 			return 0;
@@ -544,12 +544,12 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	uint32_t s, area_count;
 
 	if (stripes > 1 && mirrors > 1) {
-		log_error("Striped mirrors are not supported yet");
+		log_error(0, "Striped mirrors are not supported yet");
 		return NULL;
 	}
 
 	if (log_count && stripes > 1) {
-		log_error("Can't mix striping with a mirror log yet.");
+		log_error(0, "Can't mix striping with a mirror log yet.");
 		return NULL;
 	}
 
@@ -561,7 +561,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		area_count = stripes;
 
 	if (!(ah = dm_pool_zalloc(mem, sizeof(*ah) + sizeof(ah->alloced_areas[0]) * area_count))) {
-		log_error("allocation handle allocation failed");
+		log_error(0, "allocation handle allocation failed");
 		return NULL;
 	}
 
@@ -571,7 +571,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	ah->cmd = cmd;
 
 	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
-		log_error("allocation pool creation failed");
+		log_error(0, "allocation pool creation failed");
 		return NULL;
 	}
 
@@ -606,25 +606,25 @@ static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_are
 
 	dm_list_iterate_items(spvs, parallel_areas) {
 		if (!dm_pool_begin_object(mem, 256)) {
-			log_error("dm_pool_begin_object failed");
+			log_error(0, "dm_pool_begin_object failed");
 			return 0;
 		}
 
 		dm_list_iterate_items(pvl, &spvs->pvs) {
 			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
-				log_error("dm_pool_grow_object failed");
+				log_error(0, "dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
 			}
 			if (!dm_pool_grow_object(mem, " ", 1)) {
-				log_error("dm_pool_grow_object failed");
+				log_error(0, "dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
 			}
 		}
 
 		if (!dm_pool_grow_object(mem, "\0", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			dm_pool_abandon_object(mem);
 			return 0;
 		}
@@ -658,7 +658,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint32_t status,
 				     status, stripe_size, NULL,
 				     area_count,
 				     aa[0].len, 0u, region_size, 0u))) {
-		log_error("Couldn't allocate new LV segment.");
+		log_error(0, "Couldn't allocate new LV segment.");
 		return 0;
 	}
 
@@ -745,7 +745,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
 
 	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) *
 			      (ah->area_count + (log_area ? 1 : 0))))) {
-		log_error("alloced_area allocation failed");
+		log_error(0, "alloced_area allocation failed");
 		return 0;
 	}
 
@@ -796,7 +796,7 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 	int r = 1;
 
 	if (!(seg = find_seg_by_le(lv, le))) {
-		log_error("Failed to find segment for %s extent %" PRIu32,
+		log_error(0, "Failed to find segment for %s extent %" PRIu32,
 			  lv->name, le);
 		return 0;
 	}
@@ -1002,7 +1002,7 @@ static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
 	if (needed - *allocated > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+		log_error(0, "Insufficient free space: %" PRIu32 " extents needed,"
 			  " but only %" PRIu32 " available",
 			  needed - *allocated, free_pes);
 		return 0;
@@ -1200,7 +1200,7 @@ static int _allocate(struct alloc_handle *ah,
 	alloc_policy_t alloc;
 
 	if (allocated >= new_extents && !ah->log_count) {
-		log_error("_allocate called with no work to do!");
+		log_error(0, "_allocate called with no work to do!");
 		return 1;
 	}
 
@@ -1222,9 +1222,9 @@ static int _allocate(struct alloc_handle *ah,
 	areas_size = dm_list_size(pvms);
 	if (areas_size && areas_size < (ah->area_count + ah->log_count)) {
 		if (ah->alloc != ALLOC_ANYWHERE) {
-			log_error("Not enough PVs with free space available "
+			log_error(0, "Not enough PVs with free space available "
 				  "for parallel allocation.");
-			log_error("Consider --alloc anywhere if desperate.");
+			log_error(0, "Consider --alloc anywhere if desperate.");
 			return 0;
 		}
 		areas_size = ah->area_count + ah->log_count;
@@ -1237,7 +1237,7 @@ static int _allocate(struct alloc_handle *ah,
 
 	/* Allocate an array of pv_areas to hold the largest space on each PV */
 	if (!(areas = dm_malloc(sizeof(*areas) * areas_size))) {
-		log_err("Couldn't allocate areas array.");
+		log_error(0, "Couldn't allocate areas array.");
 		return 0;
 	}
 
@@ -1254,7 +1254,7 @@ static int _allocate(struct alloc_handle *ah,
 	}
 
 	if (allocated != new_extents) {
-		log_error("Insufficient suitable %sallocatable extents "
+		log_error(0, "Insufficient suitable %sallocatable extents "
 			  "for logical volume %s: %u more required",
 			  can_split ? "" : "contiguous ",
 			  lv ? lv->name : "",
@@ -1264,7 +1264,7 @@ static int _allocate(struct alloc_handle *ah,
 	}
 
 	if (ah->log_count && !ah->log_area.len) {
-		log_error("Insufficient extents for log allocation "
+		log_error(0, "Insufficient extents for log allocation "
 			  "for logical volume %s.",
 			  lv ? lv->name : "");
 		goto out;
@@ -1285,7 +1285,7 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint32_t status,
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count, extents, status, 0,
 				     NULL, 0, extents, 0, 0, 0))) {
-		log_error("Couldn't allocate new zero segment.");
+		log_error(0, "Couldn't allocate new zero segment.");
 		return 0;
 	}
 
@@ -1315,16 +1315,16 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 	struct alloc_handle *ah;
 
 	if (segtype_is_virtual(segtype)) {
-		log_error("allocate_extents does not handle virtual segments");
+		log_error(0, "allocate_extents does not handle virtual segments");
 		return NULL;
 	}
 
 	if (vg->fid->fmt->ops->segtype_supported &&
 	    !vg->fid->fmt->ops->segtype_supported(vg->fid, segtype)) {
-		log_error("Metadata format (%s) does not support required "
+		log_error(0, "Metadata format (%s) does not support required "
 			  "LV segment type (%s).", vg->fid->fmt->name,
 			  segtype->name);
-		log_error("Consider changing the metadata format by running "
+		log_error(0, "Consider changing the metadata format by running "
 			  "vgconvert.");
 		return NULL;
 	}
@@ -1359,12 +1359,12 @@ int lv_add_segment(struct alloc_handle *ah,
 		   struct logical_volume *log_lv)
 {
 	if (!segtype) {
-		log_error("Missing segtype in lv_add_segment().");
+		log_error(0, "Missing segtype in lv_add_segment().");
 		return 0;
 	}
 
 	if (segtype_is_virtual(segtype)) {
-		log_error("lv_add_segment cannot handle virtual segments");
+		log_error(0, "lv_add_segment cannot handle virtual segments");
 		return 0;
 	}
 
@@ -1375,7 +1375,7 @@ int lv_add_segment(struct alloc_handle *ah,
 		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {
-		log_err("Couldn't merge segments after extending "
+		log_error(0, "Couldn't merge segments after extending "
 			"logical volume.");
 		return 0;
 	}
@@ -1400,12 +1400,12 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 	uint32_t s;
 
 	if (!seg_is_striped(seg)) {
-		log_error("Can't convert non-striped segment to mirrored.");
+		log_error(0, "Can't convert non-striped segment to mirrored.");
 		return NULL;
 	}
 
 	if (seg->area_count > 1) {
-		log_error("Can't convert striped segment with multiple areas "
+		log_error(0, "Can't convert striped segment with multiple areas "
 			  "to mirrored.");
 		return NULL;
 	}
@@ -1418,7 +1418,7 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
 					seg->extents_copied))) {
-		log_error("Couldn't allocate converted LV segment");
+		log_error(0, "Couldn't allocate converted LV segment");
 		return NULL;
 	}
 
@@ -1446,7 +1446,7 @@ int lv_add_mirror_areas(struct alloc_handle *ah,
 
 	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
 		if (!(seg = find_seg_by_le(lv, current_le))) {
-			log_error("Failed to find segment for %s extent %"
+			log_error(0, "Failed to find segment for %s extent %"
 				  PRIu32, lv->name, current_le);
 			return 0;
 		}
@@ -1454,7 +1454,7 @@ int lv_add_mirror_areas(struct alloc_handle *ah,
 		/* Allocator assures aa[0].len <= seg->area_len */
 		if (aa[0].len < seg->area_len) {
 			if (!lv_split_segment(lv, seg->le + aa[0].len)) {
-				log_error("Failed to split segment at %s "
+				log_error(0, "Failed to split segment at %s "
 					  "extent %" PRIu32, lv->name, le);
 				return 0;
 			}
@@ -1504,7 +1504,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 	seg = first_seg(lv);
 
 	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
-		log_error("Mirror layer must be inserted before adding mirrors");
+		log_error(0, "Mirror layer must be inserted before adding mirrors");
 		return_0;
 	}
 
@@ -1514,7 +1514,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 			return_0;
 
 	if (region_size && region_size != seg->region_size) {
-		log_error("Conflicting region_size");
+		log_error(0, "Conflicting region_size");
 		return 0;
 	}
 
@@ -1522,7 +1522,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 	new_area_count = old_area_count + num_extra_areas;
 
 	if (!_lv_segment_add_areas(lv, seg, new_area_count)) {
-		log_error("Failed to allocate widened LV segment for %s.",
+		log_error(0, "Failed to allocate widened LV segment for %s.",
 			  lv->name);
 		return 0;
 	}
@@ -1550,7 +1550,7 @@ int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
 	struct lv_segment *seg;
 
 	if (dm_list_size(&log_lv->segments)) {
-		log_error("Log segments can only be added to an empty LV");
+		log_error(0, "Log segments can only be added to an empty LV");
 		return 0;
 	}
 
@@ -1559,7 +1559,7 @@ int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
 							     "striped"),
 				     log_lv, 0, ah->log_area.len, MIRROR_LOG,
 				     0, NULL, 1, ah->log_area.len, 0, 0, 0))) {
-		log_error("Couldn't allocate new mirror log segment.");
+		log_error(0, "Couldn't allocate new mirror log segment.");
 		return 0;
 	}
 
@@ -1597,7 +1597,7 @@ static int _lv_extend_mirror(struct alloc_handle *ah,
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
 				    0, 0, 0, NULL)) {
-			log_error("Aborting. Failed to extend %s.",
+			log_error(0, "Aborting. Failed to extend %s.",
 				  seg_lv(seg, s)->name);
 			return 0;
 		}
@@ -1652,13 +1652,13 @@ static int _rename_single_lv(struct logical_volume *lv, char *new_name)
 	struct volume_group *vg = lv->vg;
 
 	if (find_lv_in_vg(vg, new_name)) {
-		log_error("Logical volume \"%s\" already exists in "
+		log_error(0, "Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", new_name, vg->name);
 		return 0;
 	}
 
 	if (lv->status & LOCKED) {
-		log_error("Cannot rename locked LV %s", lv->name);
+		log_error(0, "Cannot rename locked LV %s", lv->name);
 		return 0;
 	}
 
@@ -1684,7 +1684,7 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 	 */
 	len = strlen(lv_name_old);
 	if (strncmp(lv->name, lv_name_old, len) || lv->name[len] != '_') {
-		log_error("Cannot rename \"%s\": name format not recognized "
+		log_error(0, "Cannot rename \"%s\": name format not recognized "
 			  "for internal LV \"%s\"",
 			  lv_name_old, lv->name);
 		return 0;
@@ -1700,11 +1700,11 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 	len = strlen(lv_name_new) + strlen(suffix) + 1;
 	new_name = dm_pool_alloc(cmd->mem, len);
 	if (!new_name) {
-		log_error("Failed to allocate space for new name");
+		log_error(0, "Failed to allocate space for new name");
 		return 0;
 	}
 	if (!dm_snprintf(new_name, len, "%s%s", lv_name_new, suffix)) {
-		log_error("Failed to create new name");
+		log_error(0, "Failed to create new name");
 		return 0;
 	}
 
@@ -1771,18 +1771,18 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* rename is not allowed on sub LVs */
 	if (!lv_is_visible(lv)) {
-		log_error("Cannot rename internal LV \"%s\".", lv->name);
+		log_error(0, "Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
 
 	if (find_lv_in_vg(vg, new_name)) {
-		log_error("Logical volume \"%s\" already exists in "
+		log_error(0, "Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", new_name, vg->name);
 		return 0;
 	}
 
 	if (lv->status & LOCKED) {
-		log_error("Cannot rename locked LV %s", lv->name);
+		log_error(0, "Cannot rename locked LV %s", lv->name);
 		return 0;
 	}
 
@@ -1797,7 +1797,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* rename main LV */
 	if (!(lv->name = dm_pool_strdup(cmd->mem, new_name))) {
-		log_error("Failed to allocate space for new name");
+		log_error(0, "Failed to allocate space for new name");
 		return 0;
 	}
 
@@ -1879,11 +1879,11 @@ struct logical_volume *lv_create_empty(const char *name,
 
 	if (strstr(name, "%d") &&
 	    !(name = generate_lv_name(vg, name, dname, sizeof(dname)))) {
-		log_error("Failed to generate unique name for the new "
+		log_error(0, "Failed to generate unique name for the new "
 			  "logical volume");
 		return NULL;
 	} else if (find_lv_in_vg(vg, name)) {
-		log_error("Unable to create LV %s in Volume Group %s: "
+		log_error(0, "Unable to create LV %s in Volume Group %s: "
 			  "name already in use.", name, vg->name);
 		return NULL;
 	}
@@ -1935,7 +1935,7 @@ static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
 			return 1;
 
 	if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
-		log_error("pv_list allocation failed");
+		log_error(0, "pv_list allocation failed");
 		return 0;
 	}
 
@@ -1957,7 +1957,7 @@ struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
 	uint32_t current_le = 0;
 
 	if (!(parallel_areas = dm_pool_alloc(cmd->mem, sizeof(*parallel_areas)))) {
-		log_error("parallel_areas allocation failed");
+		log_error(0, "parallel_areas allocation failed");
 		return NULL;
 	}
 
@@ -1965,7 +1965,7 @@ struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
 
 	do {
 		if (!(spvs = dm_pool_zalloc(cmd->mem, sizeof(*spvs)))) {
-			log_error("allocation failed");
+			log_error(0, "allocation failed");
 			return NULL;
 		}
 
@@ -2052,25 +2052,25 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 
 	if (lv_is_origin(lv)) {
-		log_error("Can't remove logical volume \"%s\" under snapshot",
+		log_error(0, "Can't remove logical volume \"%s\" under snapshot",
 			  lv->name);
 		return 0;
 	}
 
 	if (lv->status & MIRROR_IMAGE) {
-		log_error("Can't remove logical volume %s used by a mirror",
+		log_error(0, "Can't remove logical volume %s used by a mirror",
 			  lv->name);
 		return 0;
 	}
 
 	if (lv->status & MIRROR_LOG) {
-		log_error("Can't remove logical volume %s used as mirror log",
+		log_error(0, "Can't remove logical volume %s used as mirror log",
 			  lv->name);
 		return 0;
 	}
 
 	if (lv->status & LOCKED) {
-		log_error("Can't remove locked LV %s", lv->name);
+		log_error(0, "Can't remove locked LV %s", lv->name);
 		return 0;
 	}
 
@@ -2078,7 +2078,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
-			log_error("Can't remove open logical volume \"%s\"",
+			log_error(0, "Can't remove open logical volume \"%s\"",
 				  lv->name);
 			return 0;
 		}
@@ -2099,7 +2099,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* FIXME Snapshot commit out of sequence if it fails after here? */
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate logical volume \"%s\"",
+		log_error(0, "Unable to deactivate logical volume \"%s\"",
 			  lv->name);
 		return 0;
 	}
@@ -2113,7 +2113,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
 	if (!lv_remove(lv)) {
-		log_error("Error releasing logical volume \"%s\"", lv->name);
+		log_error(0, "Error releasing logical volume \"%s\"", lv->name);
 		return 0;
 	}
 
@@ -2126,9 +2126,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* If no snapshots left, reload without -real. */
 	if (origin && !lv_is_origin(origin)) {
 		if (!suspend_lv(cmd, origin))
-			log_error("Failed to refresh %s without snapshot.", origin->name);
+			log_error(0, "Failed to refresh %s without snapshot.", origin->name);
 		else if (!resume_lv(cmd, origin))
-			log_error("Failed to resume %s.", origin->name);
+			log_error(0, "Failed to resume %s.", origin->name);
 	}
 
 	if (lv_is_visible(lv))
@@ -2185,13 +2185,13 @@ static int _split_parent_area(struct lv_segment *seg, uint32_t s,
 	while (parent_area_len > 0) {
 		/* Find the layer segment pointed at */
 		if (!(spvs = _find_seg_pvs_by_le(layer_seg_pvs, layer_le))) {
-			log_error("layer segment for %s:%" PRIu32 " not found",
+			log_error(0, "layer segment for %s:%" PRIu32 " not found",
 				  seg->lv->name, parent_le);
 			return 0;
 		}
 
 		if (spvs->le != layer_le) {
-			log_error("Incompatible layer boundary: "
+			log_error(0, "Incompatible layer boundary: "
 				  "%s:%" PRIu32 "[%" PRIu32 "] on %s:%" PRIu32,
 				  seg->lv->name, parent_le, s,
 				  seg_lv(seg, s)->name, layer_le);
@@ -2271,19 +2271,19 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 
 			/* Find the layer segment pointed at */
 			if (!(lseg = find_seg_by_le(layer_lv, seg_le(seg, s)))) {
-				log_error("Layer segment found: %s:%" PRIu32,
+				log_error(0, "Layer segment found: %s:%" PRIu32,
 					  layer_lv->name, seg_le(seg, s));
 				return 0;
 			}
 
 			/* Check the segment params are compatible */
 			if (!seg_is_striped(lseg) || lseg->area_count != 1) {
-				log_error("Layer is not linear: %s:%" PRIu32,
+				log_error(0, "Layer is not linear: %s:%" PRIu32,
 					  layer_lv->name, lseg->le);
 				return 0;
 			}
 			if ((lseg->status & status_mask) != status_mask) {
-				log_error("Layer status does not match: "
+				log_error(0, "Layer status does not match: "
 					  "%s:%" PRIu32 " status: 0x%x/0x%x",
 					  layer_lv->name, lseg->le,
 					  lseg->status, status_mask);
@@ -2291,7 +2291,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 			}
 			if (lseg->le != seg_le(seg, s) ||
 			    lseg->area_len != seg->area_len) {
-				log_error("Layer boundary mismatch: "
+				log_error(0, "Layer boundary mismatch: "
 					  "%s:%" PRIu32 "-%" PRIu32 " on "
 					  "%s:%" PRIu32 " / "
 					  "%" PRIu32 "-%" PRIu32 " / ",
@@ -2307,7 +2307,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 			/* Replace mirror with error segment */
 			if (!(lseg->segtype =
 			      get_segtype_from_string(lv->vg->cmd, "error"))) {
-				log_error("Missing error segtype");
+				log_error(0, "Missing error segtype");
 				return 0;
 			}
 			lseg->area_count = 0;
@@ -2315,7 +2315,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 			/* First time, add LV to list of LVs affected */
 			if (!lv_changed && lvs_changed) {
 				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed");
+					log_error(0, "lv_list alloc failed");
 					return 0;
 				}
 				lvl->lv = lv;
@@ -2364,7 +2364,7 @@ static int _move_lv_segments(struct logical_volume *lv_to,
 
 	dm_list_iterate_items(seg, &lv_to->segments) {
 		if (seg->origin) {
-			log_error("Can't move snapshot segment");
+			log_error(0, "Can't move snapshot segment");
 			return 0;
 		}
 	}
@@ -2401,7 +2401,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	log_very_verbose("Removing layer %s for %s", layer_lv->name, lv->name);
 
 	if (!(parent_seg = get_only_segment_using_this_lv(layer_lv))) {
-		log_error("Failed to find layer %s in %s",
+		log_error(0, "Failed to find layer %s in %s",
 		layer_lv->name, lv->name);
 		return 0;
 	}
@@ -2452,20 +2452,20 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	/* create an empty layer LV */
 	len = strlen(lv_where->name) + 32;
 	if (!(name = alloca(len))) {
-		log_error("layer name allocation failed. "
+		log_error(0, "layer name allocation failed. "
 			  "Remove new LV and retry.");
 		return NULL;
 	}
 
 	if (dm_snprintf(name, len, "%s%s", lv_where->name, layer_suffix) < 0) {
-		log_error("layer name allocation failed. "
+		log_error(0, "layer name allocation failed. "
 			  "Remove new LV and retry.");
 		return NULL;
 	}
 
 	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
 					 ALLOC_INHERIT, lv_where->vg))) {
-		log_error("Creation of layer LV failed");
+		log_error(0, "Creation of layer LV failed");
 		return NULL;
 	}
 
@@ -2475,23 +2475,23 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		segtype = get_segtype_from_string(cmd, "error");
 
 		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
-			log_error("Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
+			log_error(0, "Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
 			return NULL;
 		}
 
 		if (!vg_write(lv_where->vg)) {
-			log_error("Failed to write intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
+			log_error(0, "Failed to write intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
 			return NULL;
 		}
 
 		if (!vg_commit(lv_where->vg)) {
-			log_error("Failed to commit intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
+			log_error(0, "Failed to commit intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
 			vg_revert(lv_where->vg);
 			return NULL;
 		}
 
 		if (!activate_lv(cmd, layer_lv)) {
-			log_error("Failed to resume transient error LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
+			log_error(0, "Failed to resume transient error LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 			return NULL;
 		}
 	}
@@ -2701,7 +2701,7 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 			/* First time, add LV to list of LVs affected */
 			if (!lv_used && lvs_changed) {
 				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed");
+					log_error(0, "lv_list alloc failed");
 					return 0;
 				}
 				lvl->lv = lv_where;
@@ -2711,7 +2711,7 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 
 			if (!_extend_layer_lv_for_segment(layer_lv, seg, s,
 							  status)) {
-				log_error("Failed to insert segment in layer "
+				log_error(0, "Failed to insert segment in layer "
 					  "LV %s under %s:%" PRIu32 "-%" PRIu32,
 					  layer_lv->name, lv_where->name,
 					  seg->le, seg->le + seg->len);
@@ -2740,20 +2740,20 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	 *	   (I know the device is at least 4k, but not 32k)
 	 */
 	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - device not cleared");
+		log_error(0, "Name allocation failed - device not cleared");
 		return 0;
 	}
 
 	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
 			lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
+		log_error(0, "Name too long - device not cleared (%s)", lv->name);
 		return 0;
 	}
 
 	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
 
 	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: device not cleared", name);
+		log_error(0, "%s: not found: device not cleared", name);
 		return 0;
 	}
 
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 66e9ce0..57f1354 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -70,7 +70,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
 		if (seg->le != le) {
-			log_error("LV %s invalid: segment %u should begin at "
+			log_error(0, "LV %s invalid: segment %u should begin at "
 				  "LE %" PRIu32 " (found %" PRIu32 ").",
 				  lv->name, seg_count, le, seg->le);
 			r = 0;
@@ -80,7 +80,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					seg->area_count : 1;
 
 		if (seg->area_len * area_multiplier != seg->len) {
-			log_error("LV %s: segment %u has inconsistent "
+			log_error(0, "LV %s: segment %u has inconsistent "
 				  "area_len %u",
 				  lv->name, seg_count, seg->area_len);
 			r = 0;
@@ -88,14 +88,14 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 		if (complete_vg && seg->log_lv) {
 			if (!seg_is_mirrored(seg)) {
-				log_error("LV %s: segment %u has log LV but "
+				log_error(0, "LV %s: segment %u has log LV but "
 					  "is not mirrored",
 					  lv->name, seg_count);
 				r = 0;
 			}
 
 			if (!(seg->log_lv->status & MIRROR_LOG)) {
-				log_error("LV %s: segment %u log LV %s is not "
+				log_error(0, "LV %s: segment %u log LV %s is not "
 					  "a mirror log",
 					   lv->name, seg_count, seg->log_lv->name);
 				r = 0;
@@ -103,7 +103,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 			if (!(seg2 = first_seg(seg->log_lv)) ||
 			    find_mirror_seg(seg2) != seg) {
-				log_error("LV %s: segment %u log LV does not "
+				log_error(0, "LV %s: segment %u log LV does not "
 					  "point back to mirror segment",
 					   lv->name, seg_count);
 				r = 0;
@@ -113,7 +113,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if (complete_vg && seg->status & MIRROR_IMAGE) {
 			if (!find_mirror_seg(seg) ||
 			    !seg_is_mirrored(find_mirror_seg(seg))) {
-				log_error("LV %s: segment %u mirror image "
+				log_error(0, "LV %s: segment %u mirror image "
 					  "is not mirrored",
 					  lv->name, seg_count);
 				r = 0;
@@ -122,7 +122,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 		if (seg_is_snapshot(seg)) {
 			if (seg->cow && seg->cow == seg->origin) {
-				log_error("LV %s: segment %u has same LV %s for "
+				log_error(0, "LV %s: segment %u has same LV %s for "
 					  "both origin and snapshot",
 					  lv->name, seg_count, seg->cow->name);
 				r = 0;
@@ -131,7 +131,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_UNASSIGNED) {
-				log_error("LV %s: segment %u has unassigned "
+				log_error(0, "LV %s: segment %u has unassigned "
 					  "area %u.",
 					  lv->name, seg_count, s);
 				r = 0;
@@ -139,7 +139,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				if (!seg_pvseg(seg, s) ||
 				    seg_pvseg(seg, s)->lvseg != seg ||
 				    seg_pvseg(seg, s)->lv_area != s) {
-					log_error("LV %s: segment %u has "
+					log_error(0, "LV %s: segment %u has "
 						  "inconsistent PV area %u",
 						  lv->name, seg_count, s);
 					r = 0;
@@ -148,7 +148,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				if (!seg_lv(seg, s) ||
 				    seg_lv(seg, s)->vg != lv->vg ||
 				    seg_lv(seg, s) == lv) {
-					log_error("LV %s: segment %u has "
+					log_error(0, "LV %s: segment %u has "
 						  "inconsistent LV area %u",
 						  lv->name, seg_count, s);
 					r = 0;
@@ -159,7 +159,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				    (!(seg2 = find_seg_by_le(seg_lv(seg, s),
 							    seg_le(seg, s))) ||
 				     find_mirror_seg(seg2) != seg)) {
-					log_error("LV %s: segment %u mirror "
+					log_error(0, "LV %s: segment %u mirror "
 						  "image %u missing mirror ptr",
 						  lv->name, seg_count, s);
 					r = 0;
@@ -167,7 +167,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 /* FIXME I don't think this ever holds?
 				if (seg_le(seg, s) != le) {
-					log_error("LV %s: segment %u has "
+					log_error(0, "LV %s: segment %u has "
 						  "inconsistent LV area %u "
 						  "size",
 						  lv->name, seg_count, s);
@@ -179,14 +179,14 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					if (sl->seg == seg)
 						seg_found++;
 				if (!seg_found) {
-					log_error("LV %s segment %d uses LV %s,"
+					log_error(0, "LV %s segment %d uses LV %s,"
 						  " but missing ptr from %s to %s",
 						  lv->name, seg_count,
 						  seg_lv(seg, s)->name,
 						  seg_lv(seg, s)->name, lv->name);
 					r = 0;
 				} else if (seg_found > 1) {
-					log_error("LV %s has duplicated links "
+					log_error(0, "LV %s has duplicated links "
 						  "to LV %s segment %d",
 						  seg_lv(seg, s)->name,
 						  lv->name, seg_count);
@@ -210,14 +210,14 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if (seg->log_lv == lv)
 			seg_found++;
 		if (!seg_found) {
-			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
+			log_error(0, "LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
 				  ", but missing ptr from %s to %s",
 				  lv->name, seg->lv->name, seg->le,
 				  seg->le + seg->len - 1,
 				  seg->lv->name, lv->name);
 			r = 0;
 		} else if (seg_found != sl->count) {
-			log_error("Reference count mismatch: LV %s has %d "
+			log_error(0, "Reference count mismatch: LV %s has %d "
 				  "links to LV %s:%" PRIu32 "-%" PRIu32
 				  ", which has %d links",
 				  lv->name, sl->count, seg->lv->name, seg->le,
@@ -232,7 +232,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				break;
 			}
 		if (!seg_found) {
-			log_error("LV segment %s:%" PRIu32 "-%" PRIu32
+			log_error(0, "LV segment %s:%" PRIu32 "-%" PRIu32
 				  "is incorrectly listed as being used by LV %s",
 				  seg->lv->name, seg->le, seg->le + seg->len - 1,
 				  lv->name);
@@ -241,7 +241,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	}
 
 	if (le != lv->le_count) {
-		log_error("LV %s: inconsistent LE count %u != %u",
+		log_error(0, "LV %s: inconsistent LE count %u != %u",
 			  lv->name, le, lv->le_count);
 		r = 0;
 	}
@@ -262,7 +262,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 	uint32_t area_offset;
 
 	if (!seg_can_split(seg)) {
-		log_error("Unable to split the %s segment at LE %" PRIu32
+		log_error(0, "Unable to split the %s segment at LE %" PRIu32
 			  " in LV %s", seg->segtype->name, le, lv->name);
 		return 0;
 	}
@@ -275,12 +275,12 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
 					   seg->extents_copied))) {
-		log_error("Couldn't allocate cloned LV segment.");
+		log_error(0, "Couldn't allocate cloned LV segment.");
 		return 0;
 	}
 
 	if (!str_list_dup(lv->vg->cmd->mem, &split_seg->tags, &seg->tags)) {
-		log_error("LV segment tags duplication failed");
+		log_error(0, "LV segment tags duplication failed");
 		return 0;
 	}
 
@@ -328,7 +328,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 			break;
 
 		case AREA_UNASSIGNED:
-			log_error("Unassigned area %u found in segment", s);
+			log_error(0, "Unassigned area %u found in segment", s);
 			return 0;
 		}
 	}
@@ -347,7 +347,7 @@ int lv_split_segment(struct logical_volume *lv, uint32_t le)
 	struct lv_segment *seg;
 
 	if (!(seg = find_seg_by_le(lv, le))) {
-		log_error("Segment with extent %" PRIu32 " in LV %s not found",
+		log_error(0, "Segment with extent %" PRIu32 " in LV %s not found",
 			  le, lv->name);
 		return 0;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fda07be..6caf9dc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -118,31 +118,31 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		    pv_name, vg->name);
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
-		log_error("pv_list allocation for '%s' failed", pv_name);
+		log_error(0, "pv_list allocation for '%s' failed", pv_name);
 		return 0;
 	}
 
 	if (!is_orphan_vg(pv->vg_name)) {
-		log_error("Physical volume '%s' is already in volume group "
+		log_error(0, "Physical volume '%s' is already in volume group "
 			  "'%s'", pv_name, pv->vg_name);
 		return 0;
 	}
 
 	if (pv->fmt != fid->fmt) {
-		log_error("Physical volume %s is of different format type (%s)",
+		log_error(0, "Physical volume %s is of different format type (%s)",
 			  pv_name, pv->fmt->name);
 		return 0;
 	}
 
 	/* Ensure PV doesn't depend on another PV already in the VG */
 	if (pv_uses_vg(pv, vg)) {
-		log_error("Physical volume %s might be constructed from same "
+		log_error(0, "Physical volume %s might be constructed from same "
 			  "volume group %s", pv_name, vg->name);
 		return 0;
 	}
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name))) {
-		log_error("vg->name allocation failed for '%s'", pv_name);
+		log_error(0, "vg->name allocation failed for '%s'", pv_name);
 		return 0;
 	}
 
@@ -159,19 +159,19 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
 				     vg->extent_size, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
-		log_error("Format-specific setup of physical volume '%s' "
+		log_error(0, "Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;
 	}
 
 	if (_find_pv_in_vg(vg, pv_name)) {
-		log_error("Physical volume '%s' listed more than once.",
+		log_error(0, "Physical volume '%s' listed more than once.",
 			  pv_name);
 		return 0;
 	}
 
 	if (vg->pv_count && (vg->pv_count == vg->max_pv)) {
-		log_error("No space for '%s' - volume group '%s' "
+		log_error(0, "No space for '%s' - volume group '%s' "
 			  "holds max %d physical volume(s).", pv_name,
 			  vg->name, vg->max_pv);
 		return 0;
@@ -184,7 +184,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	dm_list_add(&vg->pvs, &pvl->list);
 
 	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
-		log_error("Unable to add %s to %s: new extent count (%"
+		log_error(0, "Unable to add %s to %s: new extent count (%"
 			  PRIu64 ") exceeds limit (%" PRIu32 ").",
 			  pv_name, vg->name,
 			  (uint64_t) vg->extent_count + pv->pe_count,
@@ -245,7 +245,7 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 	int r = 0, consistent = 0;
 
 	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
+		log_error(0, "get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -257,7 +257,7 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
 			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
-				log_error("internal PV duplication failed");
+				log_error(0, "internal PV duplication failed");
 				r = 0;
 				goto out;
 			}
@@ -279,7 +279,7 @@ static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 
 	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
-		log_error("%s: already exists in filesystem", vg_path);
+		log_error(0, "%s: already exists in filesystem", vg_path);
 		return 0;
 	}
 
@@ -298,19 +298,19 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 
 	/* Check sanity of new name */
 	if (strlen(vg_name_new) > NAME_LEN - length - 2) {
-		log_error("New volume group path exceeds maximum length "
+		log_error(0, "New volume group path exceeds maximum length "
 			  "of %d!", NAME_LEN - length - 2);
 		return 0;
 	}
 
 	if (!validate_new_vg_name(cmd, vg_name_new)) {
-		log_error("New volume group name \"%s\" is invalid",
+		log_error(0, "New volume group name \"%s\" is invalid",
 			  vg_name_new);
 		return 0;
 	}
 
 	if (!strcmp(vg_name_old, vg_name_new)) {
-		log_error("Old and new volume group names must differ");
+		log_error(0, "Old and new volume group names must differ");
 		return 0;
 	}
 
@@ -324,13 +324,13 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	struct pv_list *pvl;
 
 	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
-		log_error("vg->name allocation failed for '%s'", new_name);
+		log_error(0, "vg->name allocation failed for '%s'", new_name);
 		return 0;
 	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvl->pv->vg_name = dm_pool_strdup(mem, new_name))) {
-			log_error("pv->vg_name allocation failed for '%s'",
+			log_error(0, "pv->vg_name allocation failed for '%s'",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
@@ -366,9 +366,9 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	int ret = 1;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
-		log_error("Volume group \"%s\" not found, is inconsistent "
+		log_error(0, "Volume group \"%s\" not found, is inconsistent "
 			  "or has PVs missing.", vg_name);
-		log_error("Consider vgreduce --removemissing if metadata "
+		log_error(0, "Consider vgreduce --removemissing if metadata "
 			  "is inconsistent.");
 		return 0;
 	}
@@ -394,7 +394,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
-		log_error("Volume group \"%s\" still contains %u "
+		log_error(0, "Volume group \"%s\" still contains %u "
 			  "logical volume(s)", vg_name, lv_count);
 		return 0;
 	}
@@ -403,7 +403,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		return 0;
 
 	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg_name);
+		log_error(0, "vg_remove %s failed", vg_name);
 		return 0;
 	}
 
@@ -416,14 +416,14 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		pv->status = ALLOCATABLE_PV;
 
 		if (!dev_get_size(pv_dev(pv), &pv->size)) {
-			log_error("%s: Couldn't get size.", pv_dev_name(pv));
+			log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 			ret = 0;
 			continue;
 		}
 
 		/* FIXME Write to same sector label was read from */
 		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
-			log_error("Failed to remove physical volume \"%s\""
+			log_error(0, "Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
 				  pv_dev_name(pv), vg_name);
 			ret = 0;
@@ -435,7 +435,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	if (ret)
 		log_print("Volume group \"%s\" successfully removed", vg_name);
 	else
-		log_error("Volume group \"%s\" not properly removed", vg_name);
+		log_error(0, "Volume group \"%s\" not properly removed", vg_name);
 
 	return ret;
 }
@@ -448,7 +448,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
 		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
-			log_error("%s not identified as an existing "
+			log_error(0, "%s not identified as an existing "
 				  "physical volume", pv_names[i]);
 			goto bad;
 		}
@@ -462,7 +462,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 	return 1;
 	
       bad:
-	log_error("Unable to add physical volume '%s' to "
+	log_error(0, "Unable to add physical volume '%s' to "
 		  "volume group '%s'.", pv_names[i], vg->name);
 	return 0;
 }
@@ -485,19 +485,19 @@ int validate_vg_create_params(struct cmd_context *cmd,
 			      struct vgcreate_params *vp)
 {
 	if (!validate_new_vg_name(cmd, vp->vg_name)) {
-		log_error("New volume group name \"%s\" is invalid",
+		log_error(0, "New volume group name \"%s\" is invalid",
 			  vp->vg_name);
 		return 1;
 	}
 
 	if (vp->alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
+		log_error(0, "Volume Group allocation policy cannot inherit "
 			  "from anything");
 		return 1;
 	}
 
 	if (!vp->extent_size) {
-		log_error("Physical extent size may not be zero");
+		log_error(0, "Physical extent size may not be zero");
 		return 1;
 	}
 
@@ -507,7 +507,7 @@ int validate_vg_create_params(struct cmd_context *cmd,
 		if (!vp->max_pv)
 			vp->max_pv = 255;
 		if (vp->max_lv > 255 || vp->max_pv > 255) {
-			log_error("Number of volumes may not exceed 255");
+			log_error(0, "Number of volumes may not exceed 255");
 			return 1;
 		}
 	}
@@ -526,7 +526,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-		log_err("A volume group called '%s' already exists.", vg_name);
+		log_error(0, "A volume group called '%s' already exists.", vg_name);
 		vg_release(vg);
 		return NULL;
 	}
@@ -538,7 +538,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 		goto_bad;
 
 	if (!id_create(&vg->id)) {
-		log_err("Couldn't create uuid for volume group '%s'.", vg_name);
+		log_error(0, "Couldn't create uuid for volume group '%s'.", vg_name);
 		goto bad;
 	}
 
@@ -577,13 +577,13 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 
 	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, vg_name,
 						       NULL, NULL))) {
-		log_error("Failed to create format instance");
+		log_error(0, "Failed to create format instance");
 		goto bad;
 	}
 
 	if (vg->fid->fmt->ops->vg_setup &&
 	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg)) {
-		log_error("Format specific setup of volume group '%s' failed.",
+		log_error(0, "Format specific setup of volume group '%s' failed.",
 			  vg_name);
 		goto bad;
 	}
@@ -606,7 +606,7 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	uint64_t size = (uint64_t) old_size * (*extents);
 
 	if (size % new_size) {
-		log_error("New size %" PRIu64 " for %s%s not an exact number "
+		log_error(0, "New size %" PRIu64 " for %s%s not an exact number "
 			  "of new extents.", size, desc1, desc2);
 		return 0;
 	}
@@ -614,7 +614,7 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	size /= new_size;
 
 	if (size > UINT32_MAX) {
-		log_error("New extent count %" PRIu64 " for %s%s exceeds "
+		log_error(0, "New extent count %" PRIu64 " for %s%s exceeds "
 			  "32 bits.", size, desc1, desc2);
 		return 0;
 	}
@@ -733,7 +733,7 @@ int vg_change_pesize(struct cmd_context *cmd __attribute((unused)),
 						return_0;
 					break;
 				case AREA_UNASSIGNED:
-					log_error("Unassigned area %u found in "
+					log_error(0, "Unassigned area %u found in "
 						  "segment", s);
 					return 0;
 				}
@@ -871,13 +871,13 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 	if (id)
 		memcpy(&pv->id, id, sizeof(*id));
 	else if (!id_create(&pv->id)) {
-		log_error("Failed to create random uuid for %s.",
+		log_error(0, "Failed to create random uuid for %s.",
 			  dev_name(dev));
 		goto bad;
 	}
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
-		log_error("%s: Couldn't get size.", pv_dev_name(pv));
+		log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 		goto bad;
 	}
 
@@ -891,13 +891,13 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 	}
 
 	if (pv->size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
+		log_error(0, "%s: Size must exceed minimum of %ld sectors.",
 			  pv_dev_name(pv), PV_MIN_SIZE);
 		goto bad;
 	}
 
 	if (pv->size < data_alignment) {
-		log_error("%s: Data alignment must not exceed device size.",
+		log_error(0, "%s: Data alignment must not exceed device size.",
 			  pv_dev_name(pv));
 		goto bad;
 	}
@@ -909,7 +909,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 				existing_extent_size, data_alignment,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
-		log_error("%s: Format-specific setup of physical volume "
+		log_error(0, "%s: Format-specific setup of physical volume "
 			  "failed.", pv_dev_name(pv));
 		goto bad;
 	}
@@ -1069,7 +1069,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 	struct physical_volume *pv;
 
 	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
-		log_error("Physical volume %s not found", pv_name);
+		log_error(0, "Physical volume %s not found", pv_name);
 		return NULL;
 	}
 
@@ -1078,13 +1078,13 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
 		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
-			log_error("Physical volume %s not found", pv_name);
+			log_error(0, "Physical volume %s not found", pv_name);
 			return NULL;
 		}
 	}
 
 	if (is_orphan_vg(pv->vg_name)) {
-		log_error("Physical volume %s not in a volume group", pv_name);
+		log_error(0, "Physical volume %s not in a volume group", pv_name);
 		return NULL;
 	}
 
@@ -1177,14 +1177,14 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 	char *name1, *name2;
 
 	if (lvs_in_vg_activated(vg_from)) {
-		log_error("Logical volumes in \"%s\" must be inactive",
+		log_error(0, "Logical volumes in \"%s\" must be inactive",
 			  vg_from->name);
 		return 0;
 	}
 
 	/* Check compatibility */
 	if (vg_to->extent_size != vg_from->extent_size) {
-		log_error("Extent sizes differ: %d (%s) and %d (%s)",
+		log_error(0, "Extent sizes differ: %d (%s) and %d (%s)",
 			  vg_to->extent_size, vg_to->name,
 			  vg_from->extent_size, vg_from->name);
 		return 0;
@@ -1192,7 +1192,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 
 	if (vg_to->max_pv &&
 	    (vg_to->max_pv < vg_to->pv_count + vg_from->pv_count)) {
-		log_error("Maximum number of physical volumes (%d) exceeded "
+		log_error(0, "Maximum number of physical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_pv, vg_to->name,
 			  vg_from->name);
 		return 0;
@@ -1200,7 +1200,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 
 	if (vg_to->max_lv &&
 	    (vg_to->max_lv < vg_visible_lvs(vg_to) + vg_visible_lvs(vg_from))) {
-		log_error("Maximum number of logical volumes (%d) exceeded "
+		log_error(0, "Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
 		return 0;
@@ -1208,14 +1208,14 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 
 	/* Metadata types must be the same */
 	if (vg_to->fid->fmt != vg_from->fid->fmt) {
-		log_error("Metadata types differ for \"%s\" and \"%s\"",
+		log_error(0, "Metadata types differ for \"%s\" and \"%s\"",
 			  vg_to->name, vg_from->name);
 		return 0;
 	}
 
 	/* Clustering attribute must be the same */
 	if (vg_is_clustered(vg_to) != vg_is_clustered(vg_from)) {
-		log_error("Clustered attribute differs for \"%s\" and \"%s\"",
+		log_error(0, "Clustered attribute differs for \"%s\" and \"%s\"",
 			  vg_to->name, vg_from->name);
 		return 0;
 	}
@@ -1228,7 +1228,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 			name2 = lvl2->lv->name;
 
 			if (!strcmp(name1, name2)) {
-				log_error("Duplicate logical volume "
+				log_error(0, "Duplicate logical volume "
 					  "name \"%s\" "
 					  "in \"%s\" and \"%s\"",
 					  name1, vg_to->name, vg_from->name);
@@ -1240,7 +1240,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 	/* Check no PVs are constructed from either VG */
 	dm_list_iterate_items(pvl, &vg_to->pvs) {
 		if (pv_uses_vg(pvl->pv, vg_from)) {
-			log_error("Physical volume %s might be constructed "
+			log_error(0, "Physical volume %s might be constructed "
 				  "from same volume group %s.",
 				  pv_dev_name(pvl->pv), vg_from->name);
 			return 0;
@@ -1249,7 +1249,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 
 	dm_list_iterate_items(pvl, &vg_from->pvs) {
 		if (pv_uses_vg(pvl->pv, vg_to)) {
-			log_error("Physical volume %s might be constructed "
+			log_error(0, "Physical volume %s might be constructed "
 				  "from same volume group %s.",
 				  pv_dev_name(pvl->pv), vg_to->name);
 			return 0;
@@ -1468,7 +1468,7 @@ int vg_validate(struct volume_group *vg)
 				if (!id_write_format(&pvl->pv->id, uuid,
 						     sizeof(uuid)))
 					 stack;
-				log_error("Internal error: Duplicate PV id "
+				log_error(0, "Internal error: Duplicate PV id "
 					  "%s detected for %s in %s.",
 					  uuid, pv_dev_name(pvl->pv),
 					  vg->name);
@@ -1477,14 +1477,14 @@ int vg_validate(struct volume_group *vg)
 		}
 
 		if (strcmp(pvl->pv->vg_name, vg->name)) {
-			log_error("Internal error: VG name for PV %s is corrupted",
+			log_error(0, "Internal error: VG name for PV %s is corrupted",
 				  pv_dev_name(pvl->pv));
 			r = 0;
 		}
 	}
 
 	if (!check_pv_segments(vg)) {
-		log_error("Internal error: PV segments corrupted in %s.",
+		log_error(0, "Internal error: PV segments corrupted in %s.",
 			  vg->name);
 		r = 0;
 	}
@@ -1520,7 +1520,7 @@ int vg_validate(struct volume_group *vg)
 	 */
 	if (((uint32_t) dm_list_size(&vg->lvs)) !=
 	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
-		log_error("Internal error: #internal LVs (%u) != #LVs (%"
+		log_error(0, "Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs %u in VG %s",
 			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
 			  snapshot_count(vg), hidden_lv_count, vg->name);
@@ -1532,7 +1532,7 @@ int vg_validate(struct volume_group *vg)
 			if (lvl == lvl2)
 				break;
 			if (!strcmp(lvl->lv->name, lvl2->lv->name)) {
-				log_error("Internal error: Duplicate LV name "
+				log_error(0, "Internal error: Duplicate LV name "
 					  "%s detected in %s.", lvl->lv->name,
 					  vg->name);
 				r = 0;
@@ -1542,7 +1542,7 @@ int vg_validate(struct volume_group *vg)
 				if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
 						     sizeof(uuid)))
 					 stack;
-				log_error("Internal error: Duplicate LV id "
+				log_error(0, "Internal error: Duplicate LV id "
 					  "%s detected for %s and %s in %s.",
 					  uuid, lvl->lv->name, lvl2->lv->name,
 					  vg->name);
@@ -1553,7 +1553,7 @@ int vg_validate(struct volume_group *vg)
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
-			log_error("Internal error: LV segments corrupted in %s.",
+			log_error(0, "Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
 			r = 0;
 		}
@@ -1561,7 +1561,7 @@ int vg_validate(struct volume_group *vg)
 
 	if (!(vg->fid->fmt->features & FMT_UNLIMITED_VOLS) &&
 	    (!vg->max_lv || !vg->max_pv)) {
-		log_error("Internal error: Volume group %s has limited PV/LV count"
+		log_error(0, "Internal error: Volume group %s has limited PV/LV count"
 			  " but limit is not set.", vg->name);
 		r = 0;
 	}
@@ -1585,23 +1585,23 @@ int vg_write(struct volume_group *vg)
 		return_0;
 
 	if (vg->status & PARTIAL_VG) {
-		log_error("Cannot update partial volume group %s.", vg->name);
+		log_error(0, "Cannot update partial volume group %s.", vg->name);
 		return 0;
 	}
 
 	if (vg_missing_pv_count(vg) && !vg->cmd->handles_missing_pvs) {
-		log_error("Cannot update volume group %s while physical "
+		log_error(0, "Cannot update volume group %s while physical "
 			  "volumes are missing.", vg->name);
 		return 0;
 	}
 
 	if (dm_list_empty(&vg->fid->metadata_areas)) {
-		log_error("Aborting vg_write: No metadata areas to write to!");
+		log_error(0, "Aborting vg_write: No metadata areas to write to!");
 		return 0;
 	}
 
 	if (!drop_cached_metadata(vg)) {
-		log_error("Unable to drop cached metadata for VG %s.", vg->name);
+		log_error(0, "Unable to drop cached metadata for VG %s.", vg->name);
 		return 0;
 	}
 
@@ -1610,7 +1610,7 @@ int vg_write(struct volume_group *vg)
 	/* Write to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (!mda->ops->vg_write) {
-			log_error("Format does not support writing volume"
+			log_error(0, "Format does not support writing volume"
 				  "group metadata areas");
 			/* Revert */
 			dm_list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
@@ -1665,7 +1665,7 @@ int vg_commit(struct volume_group *vg)
 	int failed = 0;
 
 	if (!vgname_is_locked(vg->name)) {
-		log_error("Internal error: Attempt to write new VG metadata "
+		log_error(0, "Internal error: Attempt to write new VG metadata "
 			  "without locking %s", vg->name);
 		return cache_updated;
 	}
@@ -1687,7 +1687,7 @@ int vg_commit(struct volume_group *vg)
 
 	/* If update failed, remove any cached precommitted metadata. */
 	if (!cache_updated && !drop_cached_metadata(vg))
-		log_error("Attempt to drop cached metadata failed "
+		log_error(0, "Attempt to drop cached metadata failed "
 			  "after commit for VG %s.", vg->name);
 
 	/* If at least one mda commit succeeded, it was committed */
@@ -1707,7 +1707,7 @@ int vg_revert(struct volume_group *vg)
 	}
 
 	if (!drop_cached_metadata(vg))
-		log_error("Attempt to drop cached metadata failed "
+		log_error(0, "Attempt to drop cached metadata failed "
 			  "after reverted update for VG %s.", vg->name);
 
 	return 1;
@@ -1733,7 +1733,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 		return_NULL;
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
-		log_error("vg allocation failed");
+		log_error(0, "vg allocation failed");
 		return NULL;
 	}
 	dm_list_init(&vg->pvs);
@@ -1742,7 +1742,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	vg->vgmem = mem;
 	vg->cmd = cmd;
 	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {
-		log_error("vg name allocation failed");
+		log_error(0, "vg name allocation failed");
 		goto bad;
 	}
 
@@ -1750,7 +1750,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
 							  orphan_vgname, NULL,
 							  NULL))) {
-		log_error("Failed to create format instance");
+		log_error(0, "Failed to create format instance");
 		goto bad;
 	}
 
@@ -1759,7 +1759,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
-			log_error("pv_list allocation failed");
+			log_error(0, "pv_list allocation failed");
 			goto bad;
 		}
 		pvl->pv = pv;
@@ -1787,7 +1787,7 @@ static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struc
 		 * PV is not on list so add it.
 		 */
 		if (!(pvl2 = _copy_pvl(pvmem, pvl))) {
-			log_error("pv_list allocation for '%s' failed",
+			log_error(0, "pv_list allocation for '%s' failed",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
@@ -1843,7 +1843,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read_internal requires vgname "
+			log_error(0, "Internal error: vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -1883,7 +1883,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	/* create format instance with appropriate metadata area */
 	if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
-		log_error("Failed to create format instance");
+		log_error(0, "Failed to create format instance");
 		return NULL;
 	}
 
@@ -2000,7 +2000,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		/* create format instance with appropriate metadata area */
 		if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
-			log_error("Failed to create format instance");
+			log_error(0, "Failed to create format instance");
 			return NULL;
 		}
 
@@ -2057,7 +2057,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
 		if (use_precommitted) {
-			log_error("Inconsistent pre-commit metadata copies "
+			log_error(0, "Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
 			vg_release(correct_vg);
 			return NULL;
@@ -2068,7 +2068,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
-			log_error("Inconsistent metadata UUIDs found for "
+			log_error(0, "Inconsistent metadata UUIDs found for "
 				  "volume group %s", vgname);
 			*consistent = 0;
 			return correct_vg;
@@ -2079,7 +2079,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
-			log_error("Automatic metadata correction failed");
+			log_error(0, "Automatic metadata correction failed");
 			vg_release(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
@@ -2087,7 +2087,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		cmd->handles_missing_pvs = saved_handles_missing_pvs;
 
 		if (!vg_commit(correct_vg)) {
-			log_error("Automatic metadata correction commit "
+			log_error(0, "Automatic metadata correction commit "
 				  "failed");
 			vg_release(correct_vg);
 			return NULL;
@@ -2102,7 +2102,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				vg_release(correct_vg);
 				return_NULL;
 			}
-			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
+			log_error(0, "Removing PV %s (%s) that no longer belongs to VG %s",
 				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv)) {
 				vg_release(correct_vg);
@@ -2120,9 +2120,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
-		log_error("WARNING: Interrupted pvmove detected in "
+		log_error(0, "WARNING: Interrupted pvmove detected in "
 			  "volume group %s", correct_vg->name);
-		log_error("Please restore the metadata by running "
+		log_error(0, "Please restore the metadata by running "
 			  "vgcfgrestore.");
 		vg_release(correct_vg);
 		return NULL;
@@ -2142,7 +2142,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 		return NULL;
 
 	if (!check_pv_segments(vg)) {
-		log_error("Internal error: PV segments corrupted in %s.",
+		log_error(0, "Internal error: PV segments corrupted in %s.",
 			  vg->name);
 		vg_release(vg);
 		return NULL;
@@ -2150,7 +2150,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 1)) {
-			log_error("Internal error: LV segments corrupted in %s.",
+			log_error(0, "Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
 			vg_release(vg);
 			return NULL;
@@ -2166,7 +2166,7 @@ void vg_release(struct volume_group *vg)
 		return;
 
 	if (vg->cmd && vg->vgmem == vg->cmd->mem)
-		log_error("Internal error: global memory pool used for VG %s",
+		log_error(0, "Internal error: global memory pool used for VG %s",
 			  vg->name);
 
 	dm_pool_destroy(vg->vgmem);
@@ -2195,7 +2195,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 
 			if (!consistent) {
-				log_error("Volume group %s metadata is "
+				log_error(0, "Volume group %s metadata is "
 					  "inconsistent", vg->name);
 			}
 			return vg;
@@ -2213,7 +2213,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 
 	// The slow way - full scan required to cope with vgrename
 	if (!(vgnames = get_vgnames(cmd, 2))) {
-		log_error("vg_read_by_vgid: get_vgnames failed");
+		log_error(0, "vg_read_by_vgid: get_vgnames failed");
 		goto out;
 	}
 
@@ -2227,7 +2227,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 
 			if (!consistent) {
-				log_error("Volume group %s metadata is "
+				log_error(0, "Volume group %s metadata is "
 					  "inconsistent", vgname);
 				goto out;
 			}
@@ -2252,13 +2252,13 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 
 	log_very_verbose("Finding volume group for uuid %s", lvid_s);
 	if (!(vg = _vg_read_by_vgid(cmd, (char *)lvid->id[0].uuid, precommitted))) {
-		log_error("Volume group for uuid not found: %s", lvid_s);
+		log_error(0, "Volume group for uuid not found: %s", lvid_s);
 		return NULL;
 	}
 
 	log_verbose("Found volume group \"%s\"", vg->name);
 	if (vg->status & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg->name);
+		log_error(0, "Volume group \"%s\" is exported", vg->name);
 		goto out;
 	}
 	if (!(lvl = find_lv_in_vg_by_lvid(vg, lvid))) {
@@ -2312,7 +2312,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 
 	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		if (warnings)
-			log_error("No physical volume label read from %s",
+			log_error(0, "No physical volume label read from %s",
 				  pv_name);
 		return NULL;
 	}
@@ -2322,7 +2322,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 		*label_sector = label->sector;
 
 	if (!(pv = dm_pool_zalloc(pvmem, sizeof(*pv)))) {
-		log_error("pv allocation for '%s' failed", pv_name);
+		log_error(0, "pv allocation for '%s' failed", pv_name);
 		return NULL;
 	}
 
@@ -2332,7 +2332,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	/* FIXME Move more common code up here */
 	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, mdas,
 	      scan_label_only))) {
-		log_error("Failed to read existing physical volume '%s'",
+		log_error(0, "Failed to read existing physical volume '%s'",
 			  pv_name);
 		return NULL;
 	}
@@ -2372,7 +2372,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 
 	if (pvslist) {
 		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
-			log_error("PV list allocation failed");
+			log_error(0, "PV list allocation failed");
 			return 0;
 		}
 
@@ -2381,7 +2381,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 0))) {
-		log_error("get_pvs: get_vgids failed");
+		log_error(0, "get_pvs: get_vgids failed");
 		return 0;
 	}
 
@@ -2410,7 +2410,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 		if (pvslist)
 			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
-					log_error("PV list allocation failed");
+					log_error(0, "PV list allocation failed");
 					vg_release(vg);
 					return 0;
 				}
@@ -2456,12 +2456,12 @@ static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 	     	     struct dm_list *mdas, int64_t label_sector)
 {
 	if (!pv->fmt->ops->pv_write) {
-		log_error("Format does not support writing physical volumes");
+		log_error(0, "Format does not support writing physical volumes");
 		return 0;
 	}
 
 	if (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count) {
-		log_error("Assertion failed: can't _pv_write non-orphan PV "
+		log_error(0, "Assertion failed: can't _pv_write non-orphan PV "
 			  "(in VG %s)", pv->vg_name);
 		return 0;
 	}
@@ -2481,12 +2481,12 @@ int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv)
 	pv->pe_alloc_count = 0;
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
-		log_error("%s: Couldn't get size.", pv_dev_name(pv));
+		log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 		return 0;
 	}
 
 	if (!_pv_write(cmd, pv, NULL, INT64_C(-1))) {
-		log_error("Failed to clear metadata from physical "
+		log_error(0, "Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  pv_dev_name(pv), old_vg_name);
 		return 0;
@@ -2537,7 +2537,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 
 	dev = dev_cache_get(pv_name, cmd->filter);
 	if (!dev) {
-		log_error("Device %s not found (or ignored by filtering).",
+		log_error(0, "Device %s not found (or ignored by filtering).",
 			  pv_name);
 		return 0;
 	}
@@ -2546,7 +2546,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	 * First, scan for LVM labels.
 	 */
 	if (!label_read(dev, &label, label_sector)) {
-		log_error("Could not find LVM label on %s",
+		log_error(0, "Could not find LVM label on %s",
 			  pv_name);
 		return 0;
 	}
@@ -2578,26 +2578,26 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 	if ((status & CLUSTERED) &&
 	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
 	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		log_error(0, "Skipping clustered volume group %s", vg->name);
 		/* Return because other flags are considered undefined. */
 		return FAILED_CLUSTERED;
 	}
 
 	if ((status & EXPORTED_VG) &&
 	    (vg->status & EXPORTED_VG)) {
-		log_error("Volume group %s is exported", vg->name);
+		log_error(0, "Volume group %s is exported", vg->name);
 		failure |= FAILED_EXPORTED;
 	}
 
 	if ((status & LVM_WRITE) &&
 	    !(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", vg->name);
+		log_error(0, "Volume group %s is read-only", vg->name);
 		failure |= FAILED_READ_ONLY;
 	}
 
 	if ((status & RESIZEABLE_VG) &&
 	    !(vg->status & RESIZEABLE_VG)) {
-		log_error("Volume group %s is not resizeable.", vg->name);
+		log_error(0, "Volume group %s is not resizeable.", vg->name);
 		failure |= FAILED_RESIZEABLE;
 	}
 
@@ -2633,19 +2633,19 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		consistent = 0;
 
 	if (!validate_name(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_error(0, "Volume group name %s has invalid characters",
 			  vg_name);
 		return NULL;
 	}
 
 	if (!lock_vol(cmd, vg_name, lock_flags)) {
-		log_error("Can't get lock for %s", vg_name);
+		log_error(0, "Can't get lock for %s", vg_name);
 		return NULL;
 	}
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
-		log_error("Volume group \"%s\" not found", vg_name);
+		log_error(0, "Volume group \"%s\" not found", vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
@@ -2671,7 +2671,7 @@ static vg_t *_vg_make_handle(struct cmd_context *cmd,
 	if (!vg) {
 		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
 		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
-			log_error("Error allocating vg handle.");
+			log_error(0, "Error allocating vg handle.");
 			if (vgmem)
 				dm_pool_destroy(vgmem);
 			return_NULL;
@@ -2738,7 +2738,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_error(0, "Volume group name %s has invalid characters",
 			  vg_name);
 		return NULL;
 	}
@@ -2747,7 +2747,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	already_locked = vgname_is_locked(lock_name);
 
 	if (!already_locked && !lock_vol(cmd, lock_name, lock_flags)) {
-		log_error("Can't get lock for %s", vg_name);
+		log_error(0, "Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
 
@@ -2762,13 +2762,13 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	/* If consistent == 1, we get NULL here if correction fails. */
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
-			log_error("Volume group \"%s\" inconsistent.", vg_name);
+			log_error(0, "Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto_bad;
 		}
 
 		if (!(misc_flags & READ_CHECK_EXISTENCE))
-			log_error("Volume group \"%s\" not found", vg_name);
+			log_error(0, "Volume group \"%s\" not found", vg_name);
 		else
 			failure |= READ_CHECK_EXISTENCE;
 
@@ -2778,7 +2778,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 
 	if (vg_is_clustered(vg) && !locking_is_clustered() &&
 	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
+		log_error(0, "Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto_bad;
 	}
@@ -2787,7 +2787,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	if (!consistent && !failure) {
 		vg_release(vg);
 		if (!(vg = _recover_vg(cmd, lock_name, vg_name, vgid, lock_flags))) {
-			log_error("Recovery of volume group \"%s\" failed.",
+			log_error(0, "Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto_bad;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5a52cfb..ee8261e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -102,12 +102,12 @@ struct lv_segment *find_mirror_seg(struct lv_segment *seg)
 	mirror_seg = get_only_segment_using_this_lv(seg->lv);
 
 	if (!mirror_seg) {
-		log_error("Failed to find mirror_seg for %s", seg->lv->name);
+		log_error(0, "Failed to find mirror_seg for %s", seg->lv->name);
 		return NULL;
 	}
 
 	if (!seg_is_mirrored(mirror_seg)) {
-		log_error("%s on %s is not a mirror segments",
+		log_error(0, "%s on %s is not a mirror segments",
 			  mirror_seg->lv->name, seg->lv->name);
 		return NULL;
 	}
@@ -165,7 +165,7 @@ int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage)
 	struct lv_segment_area area;
 
 	if (mimage >= mirrored_seg->area_count) {
-		log_error("Invalid index (%u) of mirror image supplied "
+		log_error(0, "Invalid index (%u) of mirror image supplied "
 			  "to shift_mirror_images()", mimage);
 		return 0;
 	}
@@ -202,21 +202,21 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	log_header.nr_regions = xlate64((uint64_t)-1);
 
 	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - log header not written (%s)",
+		log_error(0, "Name allocation failed - log header not written (%s)",
 			lv->name);
 		return 0;
 	}
 
 	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
 			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - log header not written (%s)", lv->name);
+		log_error(0, "Name too long - log header not written (%s)", lv->name);
 		return 0;
 	}
 
 	log_verbose("Writing log header to device, %s", lv->name);
 
 	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: log header not written", name);
+		log_error(0, "%s: not found: log header not written", name);
 		return 0;
 	}
 
@@ -224,7 +224,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 
 	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
-		log_error("Failed to write log header to %s", name);
+		log_error(0, "Failed to write log header to %s", name);
 		dev_close_immediate(dev);
 		return 0;
 	}
@@ -247,7 +247,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	int was_active = 0;
 
 	if (!activation() && in_sync) {
-		log_error("Aborting. Unable to create in-sync mirror log "
+		log_error(0, "Aborting. Unable to create in-sync mirror log "
 			  "while activation is disabled.");
 		return 0;
 	}
@@ -265,7 +265,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tags)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
-			log_error("Aborting. Unable to tag mirror log.");
+			log_error(0, "Aborting. Unable to tag mirror log.");
 			goto activate_lv;
 		}
 
@@ -276,29 +276,29 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	backup(log_lv->vg);
 
 	if (!activate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to activate mirror log.");
+		log_error(0, "Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
 	}
 
 	/* Remove the temporary tags */
 	dm_list_iterate_items(sl, tags)
 		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
+			log_error(0, "Failed to remove tag %s from mirror log.",
 				  sl->str);
 
 	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
-		log_error("Aborting. Failed to wipe mirror log.");
+		log_error(0, "Aborting. Failed to wipe mirror log.");
 		goto deactivate_and_revert_new_lv;
 	}
 
 	if (activation() && !_write_log_header(cmd, log_lv)) {
-		log_error("Aborting. Failed to write mirror log header.");
+		log_error(0, "Aborting. Failed to write mirror log header.");
 		goto deactivate_and_revert_new_lv;
 	}
 
 	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Aborting. Failed to deactivate mirror log. "
+		log_error(0, "Aborting. Failed to deactivate mirror log. "
 			  "Manual intervention required.");
 		return 0;
 	}
@@ -312,7 +312,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, log_lv)) {
-		log_error("Unable to deactivate mirror log LV. "
+		log_error(0, "Unable to deactivate mirror log LV. "
 			  "Manual intervention required.");
 		return 0;
 	}
@@ -322,17 +322,17 @@ revert_new_lv:
 
 	dm_list_iterate_items(sl, tags)
 		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
+			log_error(0, "Failed to remove tag %s from mirror log.",
 				  sl->str);
 
 	if (remove_on_failure && !lv_remove(log_lv)) {
-		log_error("Manual intervention may be required to remove "
+		log_error(0, "Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
 		return 0;
 	}
 
 	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
-		log_error("Manual intervention may be required to "
+		log_error(0, "Manual intervention may be required to "
 			  "remove/restore abandoned log LV before retrying.");
 	else
 		backup(log_lv->vg);
@@ -356,13 +356,13 @@ static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *l
 	if (!str_list_match_list(&mirror_lv->tags, &lv->tags)) {
 		dm_list_iterate_items(sl, &mirror_lv->tags)
 			if (!str_list_add(cmd->mem, &lv->tags, sl->str)) {
-				log_error("Aborting. Unable to tag.");
+				log_error(0, "Aborting. Unable to tag.");
 				return 0;
 			}
 
 		if (!vg_write(mirror_lv->vg) ||
 		    !vg_commit(mirror_lv->vg)) {
-			log_error("Intermediate VG commit for orphan volume failed.");
+			log_error(0, "Intermediate VG commit for orphan volume failed.");
 			return 0;
 		}
 	}
@@ -510,7 +510,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 
 	if (collapse &&
 	    (removable_pvs || (old_area_count - num_removed != 1))) {
-		log_error("Incompatible parameters to _remove_mirror_images");
+		log_error(0, "Incompatible parameters to _remove_mirror_images");
 		return 0;
 	}
 
@@ -538,7 +538,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
 		lv_set_visible(seg_lv(mirrored_seg, m));
 		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
-			log_error("lv_list alloc failed");
+			log_error(0, "lv_list alloc failed");
 			return 0;
 		}
 		lvl->lv = seg_lv(mirrored_seg, m);
@@ -561,7 +561,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
 		if (collapse && !_merge_mirror_images(lv, &tmp_orphan_lvs)) {
-			log_error("Failed to add mirror images");
+			log_error(0, "Failed to add mirror images");
 			return 0;
 		}
 	} else if (new_area_count == 0) {
@@ -584,12 +584,12 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 */
 
 	if (!vg_write(mirrored_seg->lv->vg)) {
-		log_error("intermediate VG write failed.");
+		log_error(0, "intermediate VG write failed.");
 		return 0;
 	}
 
 	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s", mirrored_seg->lv->name);
+		log_error(0, "Failed to lock %s", mirrored_seg->lv->name);
 		vg_revert(mirrored_seg->lv->vg);
 		return 0;
 	}
@@ -608,12 +608,12 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * explicitly.
 	 */
 	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
-		log_error("Problem resuming temporary LV, %s", lv1->name);
+		log_error(0, "Problem resuming temporary LV, %s", lv1->name);
 		return 0;
 	}
 
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Problem reactivating %s", mirrored_seg->lv->name);
+		log_error(0, "Problem reactivating %s", mirrored_seg->lv->name);
 		return 0;
 	}
 
@@ -637,7 +637,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 				      1, &lv->tags, 0)) {
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
-			log_error("Failed to initialize log device");
+			log_error(0, "Failed to initialize log device");
 			return_0;
 		}
 	}
@@ -686,9 +686,9 @@ int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
 
 	if (num_removed) {
 		if (num_removed == existing_mirrors - num_mirrors)
-			log_error("No mirror images found using specified PVs.");
+			log_error(0, "No mirror images found using specified PVs.");
 		else {
-			log_error("%u images are removed out of requested %u.",
+			log_error(0, "%u images are removed out of requested %u.",
 				  existing_mirrors - lv_mirror_count(lv),
 				  existing_mirrors - num_mirrors);
 		}
@@ -703,7 +703,7 @@ static int _mirrored_lv_in_sync(struct logical_volume *lv)
 	float sync_percent;
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL)) {
-		log_error("Unable to determine mirror sync status of %s/%s.",
+		log_error(0, "Unable to determine mirror sync status of %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
@@ -733,7 +733,7 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 	while ((tmp_lv = find_temporary_mirror(lv))) {
 		mirror_seg = find_mirror_seg(first_seg(tmp_lv));
 		if (!mirror_seg) {
-			log_error("Failed to find mirrored LV for %s",
+			log_error(0, "Failed to find mirrored LV for %s",
 				  tmp_lv->name);
 			return 0;
 		}
@@ -747,7 +747,7 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 		if (!_remove_mirror_images(mirror_seg->lv,
 					   mirror_seg->area_count - 1,
 					   NULL, 1, 1, NULL)) {
-			log_error("Failed to release mirror images");
+			log_error(0, "Failed to release mirror images");
 			return 0;
 		}
 	}
@@ -775,9 +775,9 @@ static int get_mirror_fault_policy(struct cmd_context *cmd __attribute((unused))
 		return MIRROR_ALLOCATE_ANYWHERE;
 
 	if (log_policy)
-		log_error("Bad activation/mirror_log_fault_policy");
+		log_error(0, "Bad activation/mirror_log_fault_policy");
 	else
-		log_error("Bad activation/mirror_device_fault_policy");
+		log_error(0, "Bad activation/mirror_device_fault_policy");
 
 	return MIRROR_REMOVE;
 }
@@ -815,14 +815,14 @@ static int replace_mirror_images(struct lv_segment *mirrored_seg,
 	/* FIXME: Use lvconvert rather than duplicating its code */
 
 	if (mirrored_seg->area_count < num_mirrors) {
-		log_error("WARNING: Failed to replace mirror device in %s/%s",
+		log_error(0, "WARNING: Failed to replace mirror device in %s/%s",
 			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 
 		if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv)
-			log_error("WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices",
+			log_error(0, "WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices",
 				  num_mirrors - 1, lv->vg->name, lv->name);
 		else
-			log_error("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
+			log_error(0, "WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
 				  num_mirrors - 1, lv->vg->name, lv->name);
 		r = 0;
 
@@ -836,10 +836,10 @@ static int replace_mirror_images(struct lv_segment *mirrored_seg,
 	 */
 	if ((mirrored_seg->area_count > 1) && !mirrored_seg->log_lv &&
 	    (log_policy != MIRROR_REMOVE)) {
-		log_error("WARNING: Failed to replace mirror log device in %s/%s",
+		log_error(0, "WARNING: Failed to replace mirror log device in %s/%s",
 			  lv->vg->name, lv->name);
 
-		log_error("WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
+		log_error(0, "WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices",
 			  mirrored_seg->area_count - 1 , lv->vg->name, lv->name);
 		r = 0;
 	}
@@ -885,7 +885,7 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 
 	if (!r)
 		/* Failed to replace device(s) */
-		log_error("WARNING: Unable to find substitute device for mirror volume, %s/%s",
+		log_error(0, "WARNING: Unable to find substitute device for mirror volume, %s/%s",
 			  mirrored_seg->lv->vg->name, mirrored_seg->lv->name);
 	else if (r > 0)
 		/* Success in replacing device(s) */
@@ -918,13 +918,13 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 	
 	len = strlen(lv->name) + 32;
 	if (!(img_name = alloca(len))) {
-		log_error("img_name allocation failed. "
+		log_error(0, "img_name allocation failed. "
 			  "Remove new LV and retry.");
 		return 0;
 	}
 
 	if (dm_snprintf(img_name, len, "%s_mimage_%%d", lv->name) < 0) {
-		log_error("img_name allocation failed. "
+		log_error(0, "img_name allocation failed. "
 			  "Remove new LV and retry.");
 		return 0;
 	}
@@ -933,7 +933,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 		if (!(img_lvs[m] = lv_create_empty(img_name,
 					     NULL, LVM_READ | LVM_WRITE,
 					     ALLOC_INHERIT, lv->vg))) {
-			log_error("Aborting. Failed to create mirror image LV. "
+			log_error(0, "Aborting. Failed to create mirror image LV. "
 				  "Remove new LV and retry.");
 			return 0;
 		}
@@ -942,7 +942,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
 				    0, 0, 0, NULL)) {
-			log_error("Aborting. Failed to add mirror image segment "
+			log_error(0, "Aborting. Failed to add mirror image segment "
 				  "to %s. Remove new LV and retry.",
 				  img_lvs[m]->name);
 			return 0;
@@ -967,11 +967,11 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 	/* Check the segment params are compatible */
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg)) {
-			log_error("Segment is not mirrored: %s:%" PRIu32,
+			log_error(0, "Segment is not mirrored: %s:%" PRIu32,
 				  lv->name, seg->le);
 			return 0;
 		} if ((seg->status & status_mask) != status_mask) {
-			log_error("Segment status does not match: %s:%" PRIu32
+			log_error(0, "Segment status does not match: %s:%" PRIu32
 				  " status:0x%x/0x%x", lv->name, seg->le,
 				  seg->status, status_mask);
 			return 0;
@@ -1081,7 +1081,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t s;
 
 	if (!(lvs = dm_pool_alloc(cmd->mem, sizeof(*lvs)))) {
-		log_error("lvs list alloc failed");
+		log_error(0, "lvs list alloc failed");
 		return NULL;
 	}
 
@@ -1100,7 +1100,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 				    seg_lv(seg, s) != lv)
 					continue;
 				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed");
+					log_error(0, "lv_list alloc failed");
 					return NULL;
 				}
 				lvl->lv = lv1;
@@ -1180,12 +1180,12 @@ int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc,
 				    parallel_areas))) {
-		log_error("Unable to allocate mirror extents for %s.", lv->name);
+		log_error(0, "Unable to allocate mirror extents for %s.", lv->name);
 		return 0;
 	}
 
 	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
-		log_error("Failed to add mirror areas to %s", lv->name);
+		log_error(0, "Failed to add mirror areas to %s", lv->name);
 		r = 0;
 	}
 
@@ -1208,18 +1208,18 @@ int remove_mirror_log(struct cmd_context *cmd,
 
 	/* Unimplemented features */
 	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Multiple-segment mirror is not supported");
+		log_error(0, "Multiple-segment mirror is not supported");
 		return 0;
 	}
 
 	/* Had disk log, switch to core. */
 	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-			log_error("Unable to determine mirror sync status.");
+			log_error(0, "Unable to determine mirror sync status.");
 			return 0;
 		}
 	} else if (vg_is_clustered(vg)) {
-		log_error("Unable to convert the log of inactive "
+		log_error(0, "Unable to convert the log of inactive "
 			  "cluster mirror %s", lv->name);
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
@@ -1256,12 +1256,12 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 
 	len = strlen(lv_name) + 32;
 	if (!(log_name = alloca(len))) {
-		log_error("log_name allocation failed.");
+		log_error(0, "log_name allocation failed.");
 		return NULL;
 	}
 
 	if (dm_snprintf(log_name, len, "%s%s", lv_name, suffix) < 0) {
-		log_error("log_name allocation failed.");
+		log_error(0, "log_name allocation failed.");
 		return NULL;
 	}
 
@@ -1293,7 +1293,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 	init_mirror_in_sync(in_sync);
 
 	if (log_count != 1) {
-		log_error("log_count != 1 is not supported.");
+		log_error(0, "log_count != 1 is not supported.");
 		return NULL;
 	}
 
@@ -1314,7 +1314,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 		len = c - lv->name + 1;
 		if (!(lv_name = alloca(len)) ||
 		    !dm_snprintf(lv_name, len, "%s", lv->name)) {
-			log_error("mirror log name allocation failed");
+			log_error(0, "mirror log name allocation failed");
 			return 0;
 		}
 		suffix = "_mlog";
@@ -1325,12 +1325,12 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 
 	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
 					  (const char *) lv_name, suffix))) {
-		log_error("Failed to create mirror log.");
+		log_error(0, "Failed to create mirror log.");
 		return NULL;
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
-		log_error("Failed to create mirror log.");
+		log_error(0, "Failed to create mirror log.");
 		return NULL;
 	}
 
@@ -1360,12 +1360,12 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* Unimplemented features */
 	if (log_count > 1) {
-		log_error("log_count > 1 is not supported");
+		log_error(0, "log_count > 1 is not supported");
 		return 0;
 	}
 
 	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Multiple-segment mirror is not supported");
+		log_error(0, "Multiple-segment mirror is not supported");
 		return 0;
 	}
 
@@ -1376,7 +1376,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (vg_is_clustered(lv->vg) &&
 	    !(lv_info(cmd, lv, &info, 0, 0) && info.exists)) {
-		log_error("Unable to convert the log of inactive "
+		log_error(0, "Unable to convert the log of inactive "
 			  "cluster mirror %s", lv->name);
 		return 0;
 	}
@@ -1389,7 +1389,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (activation() && segtype->ops->target_present &&
 	    !segtype->ops->target_present(cmd, NULL, NULL)) {
-		log_error("%s: Required device-mapper target(s) not "
+		log_error(0, "%s: Required device-mapper target(s) not "
 			  "detected in your kernel", segtype->name);
 		return 0;
 	}
@@ -1399,7 +1399,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 			      0, 0, log_count, region_size, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
-		log_error("Unable to allocate extents for mirror log.");
+		log_error(0, "Unable to allocate extents for mirror log.");
 		return 0;
 	}
 
@@ -1438,7 +1438,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *log_lv = NULL;
 
 	if (stripes > 1) {
-		log_error("stripes > 1 is not supported");
+		log_error(0, "stripes > 1 is not supported");
 		return 0;
 	}
 
@@ -1456,7 +1456,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 			      stripes, mirrors, log_count, region_size, lv->le_count,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
-		log_error("Unable to allocate extents for mirror(s).");
+		log_error(0, "Unable to allocate extents for mirror(s).");
 		return 0;
 	}
 
@@ -1486,7 +1486,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	 * create mirror image LVs
 	 */
 	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
-		log_error("img_lvs allocation failed. "
+		log_error(0, "img_lvs allocation failed. "
 			  "Remove new LV and retry.");
 		goto out_remove_log;
 	}
@@ -1497,7 +1497,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
 			       MIRROR_IMAGE | (lv->status & LOCKED),
 			       region_size)) {
-		log_error("Aborting. Failed to add mirror segment. "
+		log_error(0, "Aborting. Failed to add mirror segment. "
 			  "Remove new LV and retry.");
 		goto out_remove_images;
 	}
@@ -1513,7 +1513,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!lv_remove(log_lv) ||
 		    !vg_write(log_lv->vg) ||
 		    !vg_commit(log_lv->vg))
-			log_error("Manual intervention may be required to remove "
+			log_error(0, "Manual intervention may be required to remove "
 				  "abandoned log LV before retrying.");
 		else
 			backup(log_lv->vg);
@@ -1534,7 +1534,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags)
 {
 	if (!mirrors && !log_count) {
-		log_error("No conversion is requested");
+		log_error(0, "No conversion is requested");
 		return 0;
 	}
 
@@ -1550,12 +1550,12 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (flags & MIRROR_BY_SEG) {
 		if (log_count) {
-			log_error("Persistent log is not supported on "
+			log_error(0, "Persistent log is not supported on "
 				  "segment-by-segment mirroring");
 			return 0;
 		}
 		if (stripes > 1) {
-			log_error("Striped-mirroring is not supported on "
+			log_error(0, "Striped-mirroring is not supported on "
 				  "segment-by-segment mirroring");
 			return 0;
 		}
@@ -1571,7 +1571,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 					 pvs, alloc, log_count);
 	}
 
-	log_error("Unsupported mirror conversion type");
+	log_error(0, "Unsupported mirror conversion type");
 	return 0;
 }
 
@@ -1589,18 +1589,18 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
 	struct lv_segment *seg;
 
 	if (!mirrors && !log_count) {
-		log_error("No conversion is requested");
+		log_error(0, "No conversion is requested");
 		return 0;
 	}
 
 	seg = first_seg(lv);
 	if (!seg_is_mirrored(seg)) {
-		log_error("Not a mirror segment");
+		log_error(0, "Not a mirror segment");
 		return 0;
 	}
 
 	if (lv_mirror_count(lv) <= mirrors) {
-		log_error("Removing more than existing: %d <= %d",
+		log_error(0, "Removing more than existing: %d <= %d",
 			  seg->area_count, mirrors);
 		return 0;
 	}
@@ -1614,7 +1614,7 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
 
 	/* MIRROR_BY_SEG */
 	if (log_count) {
-		log_error("Persistent log is not supported on "
+		log_error(0, "Persistent log is not supported on "
 			  "segment-by-segment mirroring");
 		return 0;
 	}
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 1b0a457..64aa9c7 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -30,7 +30,7 @@ static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 	struct pv_segment *peg;
 
 	if (!(peg = dm_pool_zalloc(mem, sizeof(*peg)))) {
-		log_error("pv_segment allocation failed");
+		log_error(0, "pv_segment allocation failed");
 		return NULL;
 	}
 
@@ -115,7 +115,7 @@ int pv_split_segment(struct physical_volume *pv, uint32_t pe)
 		return 1;
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
-		log_error("Segment with extent %" PRIu32 " in PV %s not found",
+		log_error(0, "Segment with extent %" PRIu32 " in PV %s not found",
 			  pe, pv_dev_name(pv));
 		return 0;
 	}
@@ -151,7 +151,7 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv,
 		return_NULL;
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
-		log_error("Missing PV segment on %s at %u.",
+		log_error(0, "Missing PV segment on %s at %u.",
 			  pv_dev_name(pv), pe);
 		return NULL;
 	}
@@ -168,7 +168,7 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv,
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 {
 	if (!peg->lvseg) {
-		log_error("release_pv_segment with unallocated segment: "
+		log_error(0, "release_pv_segment with unallocated segment: "
 			  "%s PE %" PRIu32, pv_dev_name(peg->pv), peg->pe);
 		return 0;
 	}
@@ -272,21 +272,21 @@ int check_pv_segments(struct volume_group *vg)
 				  peg->lvseg ? peg->lvseg->le : 0, s);
 			/* FIXME Add details here on failure instead */
 			if (start_pe != peg->pe) {
-				log_error("Gap in pvsegs: %u, %u",
+				log_error(0, "Gap in pvsegs: %u, %u",
 					  start_pe, peg->pe);
 				ret = 0;
 			}
 			if (peg->lvseg) {
 				if (seg_type(peg->lvseg, s) != AREA_PV) {
-					log_error("Wrong lvseg area type");
+					log_error(0, "Wrong lvseg area type");
 					ret = 0;
 				}
 				if (seg_pvseg(peg->lvseg, s) != peg) {
-					log_error("Inconsistent pvseg pointers");
+					log_error(0, "Inconsistent pvseg pointers");
 					ret = 0;
 				}
 				if (peg->lvseg->area_len != peg->len) {
-					log_error("Inconsistent length: %u %u",
+					log_error(0, "Inconsistent length: %u %u",
 						  peg->len,
 						  peg->lvseg->area_len);
 					ret = 0;
@@ -297,13 +297,13 @@ int check_pv_segments(struct volume_group *vg)
 		}
 
 		if (start_pe != pv->pe_count) {
-			log_error("PV segment pe_count mismatch: %u != %u",
+			log_error(0, "PV segment pe_count mismatch: %u != %u",
 				  start_pe, pv->pe_count);
 			ret = 0;
 		}
 
 		if (alloced != pv->pe_alloc_count) {
-			log_error("PV segment pe_alloc_count mismatch: "
+			log_error(0, "PV segment pe_alloc_count mismatch: "
 				  "%u != %u", alloced, pv->pe_alloc_count);
 			ret = 0;
 		}
@@ -313,19 +313,19 @@ int check_pv_segments(struct volume_group *vg)
 	}
 
 	if (pv_count != vg->pv_count) {
-		log_error("PV segment VG pv_count mismatch: %u != %u",
+		log_error(0, "PV segment VG pv_count mismatch: %u != %u",
 			  pv_count, vg->pv_count);
 		ret = 0;
 	}
 
 	if (free_count != vg->free_count) {
-		log_error("PV segment VG free_count mismatch: %u != %u",
+		log_error(0, "PV segment VG free_count mismatch: %u != %u",
 			  free_count, vg->free_count);
 		ret = 0;
 	}
 
 	if (extent_count != vg->extent_count) {
-		log_error("PV segment VG extent_count mismatch: %u != %u",
+		log_error(0, "PV segment VG extent_count mismatch: %u != %u",
 			  extent_count, vg->extent_count);
 		ret = 0;
 	}
@@ -339,7 +339,7 @@ static int _reduce_pv(struct physical_volume *pv, struct volume_group *vg, uint3
 	uint32_t old_pe_count = pv->pe_count;
 
 	if (new_pe_count < pv->pe_alloc_count) {
-		log_error("%s: cannot resize to %" PRIu32 " extents "
+		log_error(0, "%s: cannot resize to %" PRIu32 " extents "
 			  "as %" PRIu32 " are allocated.",
 			  pv_dev_name(pv), new_pe_count,
 			  pv->pe_alloc_count);
@@ -352,7 +352,7 @@ static int _reduce_pv(struct physical_volume *pv, struct volume_group *vg, uint3
 			continue;
 
 		if (peg->lvseg) {
-			log_error("%s: cannot resize to %" PRIu32 " extents as "
+			log_error(0, "%s: cannot resize to %" PRIu32 " extents as "
 				  "later ones are allocated.",
 				  pv_dev_name(pv), new_pe_count);
 			return 0;
@@ -382,7 +382,7 @@ static int _extend_pv(struct physical_volume *pv, struct volume_group *vg,
 	uint32_t old_pe_count = pv->pe_count;
 
 	if ((uint64_t) new_pe_count * pv->pe_size > pv->size ) {
-		log_error("%s: cannot resize to %" PRIu32 " extents as there "
+		log_error(0, "%s: cannot resize to %" PRIu32 " extents as there "
 			  "is only room for %" PRIu64 ".", pv_dev_name(pv),
 			  new_pe_count, pv->size / pv->pe_size);
 		return 0;
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 642629b..ad94096 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -166,14 +166,14 @@ struct dm_list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
 	struct dm_list *pvms;
 
 	if (!(pvms = dm_pool_zalloc(mem, sizeof(*pvms)))) {
-		log_error("create_pv_maps alloc failed");
+		log_error(0, "create_pv_maps alloc failed");
 		return NULL;
 	}
 
 	dm_list_init(pvms);
 
 	if (!_create_maps(mem, allocatable_pvs, pvms)) {
-		log_error("Couldn't create physical volume maps in %s",
+		log_error(0, "Couldn't create physical volume maps in %s",
 			  vg->name);
 		dm_pool_free(mem, pvms);
 		return NULL;
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index b2d4ebf..378b6c7 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -27,6 +27,6 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 			return segtype;
 	}
 
-	log_error("Unrecognised segment type %s", str);
+	log_error(0, "Unrecognised segment type %s", str);
 	return NULL;
 }
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 83bc385..1ca8c7b 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -94,12 +94,12 @@ int vg_add_snapshot(struct logical_volume *origin,
 	 * Is the cow device already being used ?
 	 */
 	if (lv_is_cow(cow)) {
-		log_err("'%s' is already in use as a snapshot.", cow->name);
+		log_error(0, "'%s' is already in use as a snapshot.", cow->name);
 		return 0;
 	}
 
 	if (cow == origin) {
-		log_error("Snapshot and origin LVs must differ.");
+		log_error(0, "Snapshot and origin LVs must differ.");
 		return 0;
 	}
 
@@ -124,7 +124,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	cow->snapshot->origin->origin_count--;
 
 	if (!lv_remove(cow->snapshot->lv)) {
-		log_error("Failed to remove internal snapshot LV %s",
+		log_error(0, "Failed to remove internal snapshot LV %s",
 			  cow->snapshot->lv->name);
 		return 0;
 	}
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index b243ebb..89e6b04 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -77,7 +77,7 @@ static void _mirrored_display(const struct lv_segment *seg)
 static int _mirrored_text_import_area_count(struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "mirror_count", area_count)) {
-		log_error("Couldn't read 'mirror_count' for "
+		log_error(0, "Couldn't read 'mirror_count' for "
 			  "segment '%s'.", sn->key);
 		return 0;
 	}
@@ -96,7 +96,7 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 				      &seg->extents_copied))
 			seg->status |= PVMOVE;
 		else {
-			log_error("Couldn't read 'extents_moved' for "
+			log_error(0, "Couldn't read 'extents_moved' for "
 				  "segment '%s'.", sn->key);
 			return 0;
 		}
@@ -105,7 +105,7 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 	if (find_config_node(sn, "region_size")) {
 		if (!get_config_uint32(sn, "region_size",
 				      &seg->region_size)) {
-			log_error("Couldn't read 'region_size' for "
+			log_error(0, "Couldn't read 'region_size' for "
 				  "segment '%s'.", sn->key);
 			return 0;
 		}
@@ -113,12 +113,12 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 
 	if ((cn = find_config_node(sn, "mirror_log"))) {
 		if (!cn->v || !cn->v->v.str) {
-			log_error("Mirror log type must be a string.");
+			log_error(0, "Mirror log type must be a string.");
 			return 0;
 		}
 		logname = cn->v->v.str;
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
-			log_error("Unrecognised mirror log in segment %s.",
+			log_error(0, "Unrecognised mirror log in segment %s.",
 				  sn->key);
 			return 0;
 		}
@@ -126,13 +126,13 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 	}
 
 	if (logname && !seg->region_size) {
-		log_error("Missing region size for mirror log for segment "
+		log_error(0, "Missing region size for mirror log for segment "
 			  "'%s'.", sn->key);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "mirrors"))) {
-		log_error("Couldn't find mirrors array for segment "
+		log_error(0, "Couldn't find mirrors array for segment "
 			  "'%s'.", sn->key);
 		return 0;
 	}
@@ -161,7 +161,7 @@ static struct mirror_state *_mirrored_init_target(struct dm_pool *mem,
 	struct mirror_state *mirr_state;
 
 	if (!(mirr_state = dm_pool_alloc(mem, sizeof(*mirr_state)))) {
-		log_error("struct mirr_state allocation failed");
+		log_error(0, "struct mirr_state allocation failed");
 		return NULL;
 	}
 
@@ -193,7 +193,7 @@ static int _mirrored_target_percent(void **target_state, struct dm_pool *mem,
 	log_debug("Mirror status: %s", params);
 
 	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
-		log_error("Failure parsing mirror status mirror count: %s",
+		log_error(0, "Failure parsing mirror status mirror count: %s",
 			  params);
 		return 0;
 	}
@@ -201,7 +201,7 @@ static int _mirrored_target_percent(void **target_state, struct dm_pool *mem,
 
 	for (m = 0; m < mirror_count; m++) {
 		if (sscanf(pos, "%*x:%*x %n", &used) != 0) {
-			log_error("Failure parsing mirror status devices: %s",
+			log_error(0, "Failure parsing mirror status devices: %s",
 				  params);
 			return 0;
 		}
@@ -210,7 +210,7 @@ static int _mirrored_target_percent(void **target_state, struct dm_pool *mem,
 
 	if (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n", &numerator, &denominator,
 		   &used) != 2) {
-		log_error("Failure parsing mirror status fraction: %s", params);
+		log_error(0, "Failure parsing mirror status fraction: %s", params);
 		return 0;
 	}
 	pos += used;
@@ -242,14 +242,14 @@ static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
 	if (seg->log_lv) {
 		/* If disk log, use its UUID */
 		if (!(log_dlid = build_dlid(dm, seg->log_lv->lvid.s, NULL))) {
-			log_error("Failed to build uuid for log LV %s.",
+			log_error(0, "Failed to build uuid for log LV %s.",
 				  seg->log_lv->name);
 			return 0;
 		}
 	} else {
 		/* If core log, use mirror's UUID and set DM_CORELOG flag */
 		if (!(log_dlid = build_dlid(dm, seg->lv->lvid.s, NULL))) {
-			log_error("Failed to build uuid for mirror LV %s.",
+			log_error(0, "Failed to build uuid for mirror LV %s.",
 				  seg->lv->name);
 			return 0;
 		}
@@ -314,7 +314,7 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 
 	if (!(seg->status & PVMOVE)) {
 		if (!seg->region_size) {
-			log_error("Missing region size for mirror segment.");
+			log_error(0, "Missing region size for mirror segment.");
 			return 0;
 		}
 		region_size = seg->region_size;
@@ -392,7 +392,7 @@ static int _get_mirror_dso_path(struct cmd_context *cmd, char **dso)
 	const char *libpath;
 
 	if (!(path = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Failed to allocate dmeventd library path.");
+		log_error(0, "Failed to allocate dmeventd library path.");
 		return 0;
 	}
 
@@ -521,12 +521,12 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 
 	if (vg_is_clustered(seg->lv->vg) &&
 	    !str_list_add(mem, modules, "clog")) {
-		log_error("cluster log string list allocation failed");
+		log_error(0, "cluster log string list allocation failed");
 		return 0;
 	}
 
 	if (!str_list_add(mem, modules, "mirror")) {
-		log_error("mirror string list allocation failed");
+		log_error(0, "mirror string list allocation failed");
 		return 0;
 	}
 
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index fffdc37..f0ed28e 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -55,7 +55,7 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[])
 	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
 	if ((pid = fork()) == -1) {
-		log_error("fork failed: %s", strerror(errno));
+		log_error(0, "fork failed: %s", strerror(errno));
 		return 0;
 	}
 
@@ -73,18 +73,18 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[])
 
 	/* Parent */
 	if (wait4(pid, &status, 0, NULL) != pid) {
-		log_error("wait4 child process %u failed: %s", pid,
+		log_error(0, "wait4 child process %u failed: %s", pid,
 			  strerror(errno));
 		return 0;
 	}
 
 	if (!WIFEXITED(status)) {
-		log_error("Child %u exited abnormally", pid);
+		log_error(0, "Child %u exited abnormally", pid);
 		return 0;
 	}
 
 	if (WEXITSTATUS(status)) {
-		log_error("%s failed: %u", argv[0], WEXITSTATUS(status));
+		log_error(0, "%s failed: %u", argv[0], WEXITSTATUS(status));
 		return 0;
 	}
 
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index a5a5f2b..a68c80e 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -53,7 +53,7 @@ int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
 
 		if (dm_snprintf(buffer, len, "%s/.lvm_%s_%d_%d",
 				 dir, hostname, pid, num) == -1) {
-			log_err("Not enough space to build temporary file "
+			log_error(0, "Not enough space to build temporary file "
 				"string.");
 			return 0;
 		}
@@ -89,7 +89,7 @@ int lvm_rename(const char *old, const char *new)
 	struct stat buf;
 
 	if (link(old, new)) {
-		log_error("%s: rename to %s failed: %s", old, new,
+		log_error(0, "%s: rename to %s failed: %s", old, new,
 			  strerror(errno));
 		return 0;
 	}
@@ -100,7 +100,7 @@ int lvm_rename(const char *old, const char *new)
 	}
 
 	if (buf.st_nlink != 2) {
-		log_error("%s: rename to %s failed", old, new);
+		log_error(0, "%s: rename to %s failed", old, new);
 		return 0;
 	}
 
@@ -168,7 +168,7 @@ void sync_dir(const char *file)
 	char *dir, *c;
 
 	if (!(dir = dm_strdup(file))) {
-		log_error("sync_dir failed in strdup");
+		log_error(0, "sync_dir failed in strdup");
 		return;
 	}
 
@@ -217,7 +217,7 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 	};
 
 	if (!(dir = dm_strdup(file))) {
-		log_error("fcntl_lock_file failed in strdup.");
+		log_error(0, "fcntl_lock_file failed in strdup.");
 		return -1;
 	}
 
@@ -265,11 +265,11 @@ void fcntl_unlock_file(int lockfd)
 	log_very_verbose("Unlocking fd %d", lockfd);
 
 	if (fcntl(lockfd, F_SETLK, &lock) == -1)
-		log_error("fcntl unlock failed on fd %d: %s", lockfd,
+		log_error(0, "fcntl unlock failed on fd %d: %s", lockfd,
 			  strerror(errno));
 
 	if (close(lockfd))
-		log_error("lock file close failed on fd %d: %s", lockfd,
+		log_error(0, "lock file close failed on fd %d: %s", lockfd,
 			  strerror(errno));
 }
 
@@ -278,7 +278,7 @@ int lvm_fclose(FILE *fp, const char *filename)
 	if (!dm_fclose(fp))
 		return 0;
 	if (errno == 0)
-		log_error("%s: write error", filename);
+		log_error(0, "%s: write error", filename);
 	else
 		log_sys_error("write error", filename);
 	return EOF;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index c75a9a7..b961595 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -149,7 +149,7 @@ char *build_dm_name(struct dm_pool *mem, const char *vgname,
 	len += hyphens;
 
 	if (!(r = dm_pool_alloc(mem, len))) {
-		log_error("build_dm_name: Allocation failed for %" PRIsize_t
+		log_error(0, "build_dm_name: Allocation failed for %" PRIsize_t
 			  " for %s %s %s.", len, vgname, lvname, layer);
 		return NULL;
 	}
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index cab2909..c2a6268 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -45,7 +45,7 @@ void *load_shared_library(struct cmd_context *cmd, const char *libname,
 	void *library;
 
 	if (is_static()) {
-		log_error("Not loading shared %s library %s in static mode.",
+		log_error(0, "Not loading shared %s library %s in static mode.",
 			  desc, libname);
 		return NULL;
 	}
@@ -59,7 +59,7 @@ void *load_shared_library(struct cmd_context *cmd, const char *libname,
 			log_verbose("Unable to open external %s library %s: %s",
 				    desc, path, dlerror());
 		else
-			log_error("Unable to open external %s library %s: %s",
+			log_error(0, "Unable to open external %s library %s: %s",
 				  desc, path, dlerror());
 	}
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 1386683..7b363d7 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -105,7 +105,7 @@ static void _lock_mem(void)
 		log_sys_error("getpriority", "");
 	else
 		if (setpriority(PRIO_PROCESS, 0, _default_priority))
-			log_error("setpriority %d failed: %s",
+			log_error(0, "setpriority %d failed: %s",
 				  _default_priority, strerror(errno));
 }
 
@@ -119,7 +119,7 @@ static void _unlock_mem(void)
 #endif
 	_release_memory();
 	if (setpriority(PRIO_PROCESS, 0, _priority))
-		log_error("setpriority %u failed: %s", _priority,
+		log_error(0, "setpriority %u failed: %s", _priority,
 			  strerror(errno));
 }
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 3de63ce..d778eae 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -90,7 +90,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 	char extent_str[32];
 
 	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
@@ -110,7 +110,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 		}
 
 		if (!dm_pool_grow_object(mem, name, strlen(name))) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			return 0;
 		}
 
@@ -118,35 +118,35 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 				"%s%" PRIu32 "%s",
 				range_format ? ":" : "(", extent,
 				range_format ? "-"  : ")") < 0) {
-			log_error("Extent number dm_snprintf failed");
+			log_error(0, "Extent number dm_snprintf failed");
 			return 0;
 		}
 		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			return 0;
 		}
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
 					"%" PRIu32, extent + seg->area_len - 1) < 0) {
-				log_error("Extent number dm_snprintf failed");
+				log_error(0, "Extent number dm_snprintf failed");
 				return 0;
 			}
 			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-				log_error("dm_pool_grow_object failed");
+				log_error(0, "dm_pool_grow_object failed");
 				return 0;
 			}
 		}
 
 		if ((s != seg->area_count - 1) &&
 		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			return 0;
 		}
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		return 0;
 	}
 
@@ -177,20 +177,20 @@ static int _tags_disp(struct dm_report *rh __attribute((unused)), struct dm_pool
 	struct str_list *sl;
 
 	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
 	dm_list_iterate_items(sl, tags) {
 		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
 		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			return 0;
 		}
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		return 0;
 	}
 
@@ -207,7 +207,7 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	struct dm_list *modules;
 
 	if (!(modules = str_list_create(mem))) {
-		log_error("modules str_list allocation failed");
+		log_error(0, "modules str_list allocation failed");
 		return 0;
 	}
 
@@ -299,7 +299,7 @@ static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 	float snap_percent;
 
 	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -394,7 +394,7 @@ static int _pvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(mem, 3))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -420,7 +420,7 @@ static int _vgstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -504,17 +504,17 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	len = strlen(lv->name) + 3;
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, len, "[%s]", lv->name) < 0) {
-		log_error("lvname snprintf failed");
+		log_error(0, "lvname snprintf failed");
 		return 0;
 	}
 
 	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
-		log_error("dm_pool_strdup failed");
+		log_error(0, "dm_pool_strdup failed");
 		return 0;
 	}
 
@@ -593,12 +593,12 @@ static int _size32_disp(struct dm_report *rh __attribute((unused)), struct dm_po
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, disp))) {
-		log_error("dm_pool_strdup failed");
+		log_error(0, "dm_pool_strdup failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -622,12 +622,12 @@ static int _size64_disp(struct dm_report *rh __attribute((unused)),
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, disp))) {
-		log_error("dm_pool_strdup failed");
+		log_error(0, "dm_pool_strdup failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -824,7 +824,7 @@ static int _uuid_disp(struct dm_report *rh __attribute((unused)), struct dm_pool
 	char *repstr = NULL;
 
 	if (!(repstr = dm_pool_alloc(mem, 40))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -1020,7 +1020,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm
 	}
 
 	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -1038,12 +1038,12 @@ static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm
 	}
 
 	if (!(repstr = dm_pool_zalloc(mem, 8))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 7, "%.2f", snap_percent) < 0) {
-		log_error("snapshot percentage too large");
+		log_error(0, "snapshot percentage too large");
 		return 0;
 	}
 
@@ -1063,7 +1063,7 @@ static int _copypercent_disp(struct dm_report *rh __attribute((unused)), struct
 	char *repstr;
 
 	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
@@ -1077,12 +1077,12 @@ static int _copypercent_disp(struct dm_report *rh __attribute((unused)), struct
 	percent = copy_percent(lv);
 
 	if (!(repstr = dm_pool_zalloc(mem, 8))) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 7, "%.2f", percent) < 0) {
-		log_error("copy percentage too large");
+		log_error(0, "copy percentage too large");
 		return 0;
 	}
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index d704ff9..d8138e7 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -40,7 +40,7 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 	int old_suppress;
 
 	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
-		log_error("Couldn't read chunk size for snapshot.");
+		log_error(0, "Couldn't read chunk size for snapshot.");
 		return 0;
 	}
 
@@ -48,26 +48,26 @@ static int _snap_text_import(struct lv_segment *seg, const struct config_node *s
 
 	if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
-		log_error("Snapshot cow storage not specified.");
+		log_error(0, "Snapshot cow storage not specified.");
 		return 0;
 	}
 
 	if (!(org_name = find_config_str(sn, "origin", NULL))) {
 		log_suppress(old_suppress);
-		log_error("Snapshot origin not specified.");
+		log_error(0, "Snapshot origin not specified.");
 		return 0;
 	}
 
 	log_suppress(old_suppress);
 
 	if (!(cow = find_lv(seg->lv->vg, cow_name))) {
-		log_error("Unknown logical volume specified for "
+		log_error(0, "Unknown logical volume specified for "
 			  "snapshot cow store.");
 		return 0;
 	}
 
 	if (!(org = find_lv(seg->lv->vg, org_name))) {
-		log_error("Unknown logical volume specified for "
+		log_error(0, "Unknown logical volume specified for "
 			  "snapshot origin.");
 		return 0;
 	}
@@ -128,7 +128,7 @@ static int _get_snapshot_dso_path(struct cmd_context *cmd, char **dso)
 	const char *libpath;
 
 	if (!(path = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Failed to allocate dmeventd library path.");
+		log_error(0, "Failed to allocate dmeventd library path.");
 		return 0;
 	}
 
@@ -255,7 +255,7 @@ static int _snap_modules_needed(struct dm_pool *mem,
 				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "snapshot")) {
-		log_error("snapshot string list allocation failed");
+		log_error(0, "snapshot string list allocation failed");
 		return 0;
 	}
 
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 78129af..18fccd1 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -53,7 +53,7 @@ static void _striped_display(const struct lv_segment *seg)
 static int _striped_text_import_area_count(struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "stripe_count", area_count)) {
-		log_error("Couldn't read 'stripe_count' for "
+		log_error(0, "Couldn't read 'stripe_count' for "
 			  "segment '%s'.", sn->key);
 		return 0;
 	}
@@ -68,13 +68,13 @@ static int _striped_text_import(struct lv_segment *seg, const struct config_node
 
 	if ((seg->area_count != 1) &&
 	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
-		log_error("Couldn't read stripe_size for segment '%s'.",
+		log_error(0, "Couldn't read stripe_size for segment '%s'.",
 			  sn->key);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "stripes"))) {
-		log_error("Couldn't find stripes array for segment "
+		log_error(0, "Couldn't find stripes array for segment "
 			  "'%s'.", sn->key);
 		return 0;
 	}
@@ -161,7 +161,7 @@ static int _striped_add_target_line(struct dev_manager *dm,
 				uint32_t *pvmove_mirror_count __attribute((unused)))
 {
 	if (!seg->area_count) {
-		log_error("Internal error: striped add_target_line called "
+		log_error(0, "Internal error: striped add_target_line called "
 			  "with no areas for %s.", seg->lv->name);
 		return 0;
 	}
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index 1ded223..f85650d 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -139,7 +139,7 @@ int id_valid(struct id *id)
 
 	for (i = 0; i < ID_LEN; i++)
 		if (!_inverse_c[id->uuid[i]]) {
-			log_err("UUID contains invalid character");
+			log_error(0, "UUID contains invalid character");
 			return 0;
 		}
 
@@ -163,7 +163,7 @@ int id_write_format(const struct id *id, char *buffer, size_t size)
 
 	/* split into groups separated by dashes */
 	if (size < (32 + 6 + 1)) {
-		log_err("Couldn't write uuid, buffer too small.");
+		log_error(0, "Couldn't write uuid, buffer too small.");
 		return 0;
 	}
 
@@ -191,7 +191,7 @@ int id_read_format(struct id *id, const char *buffer)
 		}
 
 		if (out >= ID_LEN) {
-			log_err("Too many characters to be uuid.");
+			log_error(0, "Too many characters to be uuid.");
 			return 0;
 		}
 
@@ -199,7 +199,7 @@ int id_read_format(struct id *id, const char *buffer)
 	}
 
 	if (out != ID_LEN) {
-		log_err("Couldn't read uuid, incorrect number of characters.");
+		log_error(0, "Couldn't read uuid, incorrect number of characters.");
 		return 0;
 	}
 
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 7b3e62e..0583e0d 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -71,7 +71,7 @@ static int _zero_modules_needed(struct dm_pool *mem,
 				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "zero")) {
-		log_error("zero module string list allocation failed");
+		log_error(0, "zero module string list allocation failed");
 		return 0;
 	}
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 2f8a930..217789f 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -173,7 +173,7 @@ static int _get_proc_number(const char *file, const char *name,
 		log_sys_error("fclose", file);
 
 	if (number) {
-		log_error("%s: No entry for %s found", file, name);
+		log_error(0, "%s: No entry for %s found", file, name);
 		return 0;
 	}
 
@@ -327,7 +327,7 @@ static int _open_control(void)
 	snprintf(control, sizeof(control), "%s/control", dm_dir());
 
 	if (!_control_device_number(&major, &minor))
-		log_error("Is device-mapper driver missing from kernel?");
+		log_error(0, "Is device-mapper driver missing from kernel?");
 
 	if (!_control_exists(control, major, minor) &&
 	    !_create_control(control, major, minor))
@@ -339,14 +339,14 @@ static int _open_control(void)
 	}
 
 	if (!_create_dm_bitset()) {
-		log_error("Failed to set up list of device-mapper major numbers");
+		log_error(0, "Failed to set up list of device-mapper major numbers");
 		return 0;
 	}
 
 	return 1;
 
 error:
-	log_error("Failure to communicate with kernel device-mapper driver.");
+	log_error(0, "Failure to communicate with kernel device-mapper driver.");
 	return 0;
 #else
 	return 1;
@@ -478,7 +478,7 @@ static const char *_dm_task_get_uuid_v1(const struct dm_task *dmt)
 
 static struct dm_deps *_dm_task_get_deps_v1(struct dm_task *dmt)
 {
-	log_error("deps version 1 no longer supported by libdevmapper");
+	log_error(0, "deps version 1 no longer supported by libdevmapper");
 	return NULL;
 }
 
@@ -498,7 +498,7 @@ static void *_add_target_v1(struct target *t, void *out, void *end)
 
 	out += sp_size;
 	if (out >= end) {
-		log_error(no_space);
+		log_error(0, no_space);
 		return NULL;
 	}
 
@@ -510,9 +510,9 @@ static void *_add_target_v1(struct target *t, void *out, void *end)
 	len = strlen(t->params);
 
 	if ((out + len + 1) >= end) {
-		log_error(no_space);
+		log_error(0, no_space);
 
-		log_error("t->params= '%s'", t->params);
+		log_error(0, "t->params= '%s'", t->params);
 		return NULL;
 	}
 	strcpy((char *) out, t->params);
@@ -546,7 +546,7 @@ static struct dm_ioctl_v1 *_flatten_v1(struct dm_task *dmt)
 	}
 
 	if (count && dmt->newname) {
-		log_error("targets and newname are incompatible");
+		log_error(0, "targets and newname are incompatible");
 		return NULL;
 	}
 
@@ -584,7 +584,7 @@ static struct dm_ioctl_v1 *_flatten_v1(struct dm_task *dmt)
 
 	if (dmt->minor >= 0) {
 		if (dmt->major <= 0) {
-			log_error("Missing major number for persistent device");
+			log_error(0, "Missing major number for persistent device");
 			return NULL;
 		}
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
@@ -658,7 +658,7 @@ static int _dm_names_v1(struct dm_ioctl_v1 *dmi)
 		names->next = 0;
 		len = strlen(name);
 		if (((void *) (names + 1) + len + 1) >= end) {
-			log_error("Insufficient buffer space for device list");
+			log_error(0, "Insufficient buffer space for device list");
 			r = 0;
 			break;
 		}
@@ -682,7 +682,7 @@ static int _dm_task_run_v1(struct dm_task *dmt)
 
 	dmi = _flatten_v1(dmt);
 	if (!dmi) {
-		log_error("Couldn't create ioctl argument.");
+		log_error(0, "Couldn't create ioctl argument.");
 		return 0;
 	}
 
@@ -691,7 +691,7 @@ static int _dm_task_run_v1(struct dm_task *dmt)
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v1) / sizeof(*_cmd_data_v1))) {
-		log_error("Internal error: unknown device-mapper task %d",
+		log_error(0, "Internal error: unknown device-mapper task %d",
 			  dmt->type);
 		goto bad;
 	}
@@ -716,7 +716,7 @@ static int _dm_task_run_v1(struct dm_task *dmt)
 				    _cmd_data_v1[dmt->type].name,
 				    strerror(errno));
 		else
-			log_error("device-mapper: %s ioctl failed: %s",
+			log_error(0, "device-mapper: %s ioctl failed: %s",
 				  _cmd_data_v1[dmt->type].name,
 				  strerror(errno));
 		goto bad;
@@ -726,7 +726,7 @@ static int _dm_task_run_v1(struct dm_task *dmt)
 
 	if (dmi->flags & DM_BUFFER_FULL_FLAG)
 		/* FIXME Increase buffer size and retry operation (if query) */
-		log_error("WARNING: libdevmapper buffer too small for data");
+		log_error(0, "WARNING: libdevmapper buffer too small for data");
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
@@ -808,7 +808,7 @@ static int _check_version(char *version, size_t size, int log_suppress)
 	int r;
 
 	if (!(task = dm_task_create(DM_DEVICE_VERSION))) {
-		log_error("Failed to get device-mapper version");
+		log_error(0, "Failed to get device-mapper version");
 		version[0] = '\0';
 		return 0;
 	}
@@ -856,7 +856,7 @@ int dm_check_version(void)
 
 	dm_get_library_version(libversion, sizeof(libversion));
 
-	log_error("Incompatible libdevmapper %s%s and kernel driver %s",
+	log_error(0, "Incompatible libdevmapper %s%s and kernel driver %s",
 		  libversion, compat, dmversion);
 
       bad:
@@ -977,7 +977,7 @@ uint32_t dm_task_get_read_ahead(const struct dm_task *dmt, uint32_t *read_ahead)
 	else if (dmt->dev_name)
 		dev_name = dmt->dev_name;
 	else {
-		log_error("Get read ahead request failed: device name unrecorded.");
+		log_error(0, "Get read ahead request failed: device name unrecorded.");
 		return 0;
 	}
 
@@ -1056,17 +1056,17 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt)
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
 	if (strchr(newname, '/')) {
-		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
+		log_error(0, "Name \"%s\" invalid. It contains \"/\".", newname);
 		return 0;
 	}
 
 	if (strlen(newname) >= DM_NAME_LEN) {
-		log_error("Name \"%s\" too long", newname);
+		log_error(0, "Name \"%s\" too long", newname);
 		return 0;
 	}
 
 	if (!(dmt->newname = dm_strdup(newname))) {
-		log_error("dm_task_set_newname: strdup(%s) failed", newname);
+		log_error(0, "dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;
 	}
 
@@ -1076,7 +1076,7 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
 	if (!(dmt->message = dm_strdup(message))) {
-		log_error("dm_task_set_message: strdup(%s) failed", message);
+		log_error(0, "dm_task_set_message: strdup(%s) failed", message);
 		return 0;
 	}
 
@@ -1095,12 +1095,12 @@ int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char
 	size_t len = strlen(cylinders) + 1 + strlen(heads) + 1 + strlen(sectors) + 1 + strlen(start) + 1;
 
 	if (!(dmt->geometry = dm_malloc(len))) {
-		log_error("dm_task_set_geometry: dm_malloc failed");
+		log_error(0, "dm_task_set_geometry: dm_malloc failed");
 		return 0;
 	}
 
 	if (sprintf(dmt->geometry, "%s %s %s %s", cylinders, heads, sectors, start) < 0) {
-		log_error("dm_task_set_geometry: sprintf failed");
+		log_error(0, "dm_task_set_geometry: sprintf failed");
 		return 0;
 	}
 
@@ -1141,7 +1141,7 @@ struct target *create_target(uint64_t start, uint64_t len, const char *type,
 	struct target *t = dm_malloc(sizeof(*t));
 
 	if (!t) {
-		log_error("create_target: malloc(%" PRIsize_t ") failed",
+		log_error(0, "create_target: malloc(%" PRIsize_t ") failed",
 			  sizeof(*t));
 		return NULL;
 	}
@@ -1149,12 +1149,12 @@ struct target *create_target(uint64_t start, uint64_t len, const char *type,
 	memset(t, 0, sizeof(*t));
 
 	if (!(t->params = dm_strdup(params))) {
-		log_error("create_target: strdup(params) failed");
+		log_error(0, "create_target: strdup(params) failed");
 		goto bad;
 	}
 
 	if (!(t->type = dm_strdup(type))) {
-		log_error("create_target: strdup(type) failed");
+		log_error(0, "create_target: strdup(type) failed");
 		goto bad;
 	}
 
@@ -1179,7 +1179,7 @@ static void *_add_target(struct target *t, void *out, void *end)
 
 	out += sp_size;
 	if (out >= end) {
-		log_error(no_space);
+		log_error(0, no_space);
 		return NULL;
 	}
 
@@ -1191,9 +1191,9 @@ static void *_add_target(struct target *t, void *out, void *end)
 	len = strlen(t->params);
 
 	if ((out + len + 1) >= end) {
-		log_error(no_space);
+		log_error(0, no_space);
 
-		log_error("t->params= '%s'", t->params);
+		log_error(0, "t->params= '%s'", t->params);
 		return NULL;
 	}
 	strcpy((char *) out, t->params);
@@ -1261,37 +1261,37 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	}
 
 	if (count && (dmt->sector || dmt->message)) {
-		log_error("targets and message are incompatible");
+		log_error(0, "targets and message are incompatible");
 		return NULL;
 	}
 
 	if (count && dmt->newname) {
-		log_error("targets and newname are incompatible");
+		log_error(0, "targets and newname are incompatible");
 		return NULL;
 	}
 
 	if (count && dmt->geometry) {
-		log_error("targets and geometry are incompatible");
+		log_error(0, "targets and geometry are incompatible");
 		return NULL;
 	}
 
 	if (dmt->newname && (dmt->sector || dmt->message)) {
-		log_error("message and newname are incompatible");
+		log_error(0, "message and newname are incompatible");
 		return NULL;
 	}
 
 	if (dmt->newname && dmt->geometry) {
-		log_error("geometry and newname are incompatible");
+		log_error(0, "geometry and newname are incompatible");
 		return NULL;
 	}
 
 	if (dmt->geometry && (dmt->sector || dmt->message)) {
-		log_error("geometry and message are incompatible");
+		log_error(0, "geometry and message are incompatible");
 		return NULL;
 	}
 
 	if (dmt->sector && !dmt->message) {
-		log_error("message is required with sector");
+		log_error(0, "message is required with sector");
 		return NULL;
 	}
 
@@ -1331,7 +1331,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 
 	if (dmt->minor >= 0) {
 		if (dmt->major <= 0) {
-			log_error("Missing major number for persistent device.");
+			log_error(0, "Missing major number for persistent device.");
 			goto bad;
 		}
 
@@ -1350,7 +1350,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	/* Does driver support device number referencing? */
 	if (_dm_version_minor < 3 && !dmt->dev_name && !dmt->uuid && dmi->dev) {
 		if (!_lookup_dev_name(dmi->dev, dmi->name, sizeof(dmi->name))) {
-			log_error("Unable to find name for device (%" PRIu32
+			log_error(0, "Unable to find name for device (%" PRIu32
 				  ":%" PRIu32 ")", dmt->major, dmt->minor);
 			goto bad;
 		}
@@ -1486,7 +1486,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 
 	/* Use new task struct to create the device */
 	if (!(task = dm_task_create(DM_DEVICE_CREATE))) {
-		log_error("Failed to create device-mapper task struct");
+		log_error(0, "Failed to create device-mapper task struct");
 		return 0;
 	}
 
@@ -1514,7 +1514,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 
 	/* Next load the table */
 	if (!(task = dm_task_create(DM_DEVICE_RELOAD))) {
-		log_error("Failed to create device-mapper task struct");
+		log_error(0, "Failed to create device-mapper task struct");
 		return 0;
 	}
 
@@ -1552,7 +1552,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->uuid = NULL;
 
 	if (!dm_task_run(dmt))
-		log_error("Failed to revert device creation.");
+		log_error(0, "Failed to revert device creation.");
 
 	return r;
 }
@@ -1570,7 +1570,7 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 
 	/* New task to get existing table information */
 	if (!(task = dm_task_create(DM_DEVICE_TABLE))) {
-		log_error("Failed to create device-mapper task struct");
+		log_error(0, "Failed to create device-mapper task struct");
 		return 0;
 	}
 
@@ -1643,7 +1643,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 
 	dmi = _flatten(dmt, repeat_count);
 	if (!dmi) {
-		log_error("Couldn't create ioctl argument.");
+		log_error(0, "Couldn't create ioctl argument.");
 		return NULL;
 	}
 
@@ -1684,7 +1684,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				    	    _cmd_data_v4[dmt->type].name,
 					    strerror(errno));
 			else
-				log_error("device-mapper: %s ioctl "
+				log_error(0, "device-mapper: %s ioctl "
 					  "failed: %s",
 				    	   _cmd_data_v4[dmt->type].name,
 					  strerror(errno));
@@ -1714,7 +1714,7 @@ int dm_task_run(struct dm_task *dmt)
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
-		log_error("Internal error: unknown device-mapper task %d",
+		log_error(0, "Internal error: unknown device-mapper task %d",
 			  dmt->type);
 		return 0;
 	}
@@ -1751,7 +1751,7 @@ repeat_ioctl:
 			dm_free(dmi);
 			goto repeat_ioctl;
 		default:
-			log_error("WARNING: libdevmapper buffer too small for data");
+			log_error(0, "WARNING: libdevmapper buffer too small for data");
 		}
 	}
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 291a1b5..2fd8c43 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -104,7 +104,7 @@ struct dm_task *dm_task_create(int type)
 	struct dm_task *dmt = dm_malloc(sizeof(*dmt));
 
 	if (!dmt) {
-		log_error("dm_task_create: malloc(%" PRIsize_t ") failed",
+		log_error(0, "dm_task_create: malloc(%" PRIsize_t ") failed",
 			  sizeof(*dmt));
 		return NULL;
 	}
@@ -146,7 +146,7 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 	 */
 	if ((pos = strrchr(name, '/'))) {
 		if (dmt->type == DM_DEVICE_CREATE) {
-			log_error("Name \"%s\" invalid. It contains \"/\".", name);
+			log_error(0, "Name \"%s\" invalid. It contains \"/\".", name);
 			return 0;
 		}
 
@@ -154,7 +154,7 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 		if (stat(name, &st1) || stat(path, &st2) ||
 		    !(st1.st_dev == st2.st_dev)) {
-			log_error("Device %s not found", name);
+			log_error(0, "Device %s not found", name);
 			return 0;
 		}
 
@@ -162,12 +162,12 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 	}
 
 	if (strlen(name) >= DM_NAME_LEN) {
-		log_error("Name \"%s\" too long", name);
+		log_error(0, "Name \"%s\" too long", name);
 		return 0;
 	}
 
 	if (!(dmt->dev_name = dm_strdup(name))) {
-		log_error("dm_task_set_name: strdup(%s) failed", name);
+		log_error(0, "dm_task_set_name: strdup(%s) failed", name);
 		return 0;
 	}
 
@@ -182,7 +182,7 @@ int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 	}
 
 	if (!(dmt->uuid = dm_strdup(uuid))) {
-		log_error("dm_task_set_uuid: strdup(%s) failed", uuid);
+		log_error(0, "dm_task_set_uuid: strdup(%s) failed", uuid);
 		return 0;
 	}
 
@@ -262,7 +262,7 @@ int dm_set_selinux_context(const char *path, mode_t mode)
 		return 1;
 
 	if (matchpathcon(path, mode, &scontext) < 0) {
-		log_error("%s: matchpathcon %07o failed: %s", path, mode,
+		log_error(0, "%s: matchpathcon %07o failed: %s", path, mode,
 			  strerror(errno));
 		return 0;
 	}
@@ -292,7 +292,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 
 	if (stat(path, &info) >= 0) {
 		if (!S_ISBLK(info.st_mode)) {
-			log_error("A non-block device file at '%s' "
+			log_error(0, "A non-block device file at '%s' "
 				  "is already present", path);
 			return 0;
 		}
@@ -302,7 +302,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			return 1;
 
 		if (unlink(path) < 0) {
-			log_error("Unable to unlink device node for '%s'",
+			log_error(0, "Unable to unlink device node for '%s'",
 				  dev_name);
 			return 0;
 		}
@@ -310,7 +310,7 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
-		log_error("Unable to make device node for '%s'", dev_name);
+		log_error(0, "Unable to make device node for '%s'", dev_name);
 		return 0;
 	}
 	umask(old_mask);
@@ -341,7 +341,7 @@ static int _rename_dev_node(const char *old_name, const char *new_name)
 
 	if (stat(newpath, &info) == 0) {
 		if (!S_ISBLK(info.st_mode)) {
-			log_error("A non-block device file at '%s' "
+			log_error(0, "A non-block device file@'%s' "
 				  "is already present", newpath);
 			return 0;
 		}
@@ -351,14 +351,14 @@ static int _rename_dev_node(const char *old_name, const char *new_name)
 				/* devfs, entry has already been renamed */
 				return 1;
 			}
-			log_error("Unable to unlink device node for '%s'",
+			log_error(0, "Unable to unlink device node for '%s'",
 				  new_name);
 			return 0;
 		}
 	}
 
 	if (rename(oldpath, newpath) < 0) {
-		log_error("Unable to rename device node from '%s' to '%s'",
+		log_error(0, "Unable to rename device node from '%s' to '%s'",
 			  old_name, new_name);
 		return 0;
 	}
@@ -379,7 +379,7 @@ static int _rm_dev_node(const char *dev_name)
 		return 1;
 
 	if (unlink(path) < 0) {
-		log_error("Unable to unlink device node for '%s'", dev_name);
+		log_error(0, "Unable to unlink device node for '%s'", dev_name);
 		return 0;
 	}
 
@@ -409,7 +409,7 @@ int get_dev_node_read_ahead(const char *dev_name, uint32_t *read_ahead)
 	long read_ahead_long;
 
 	if (!*dev_name) {
-		log_error("Empty device name passed to BLKRAGET");
+		log_error(0, "Empty device name passed to BLKRAGET");
 		return 0;
 	}
 
@@ -438,7 +438,7 @@ static int _set_read_ahead(const char *dev_name, uint32_t read_ahead)
 	long read_ahead_long = (long) read_ahead;
 
 	if (!*dev_name) {
-		log_error("Empty device name passed to BLKRAGET");
+		log_error(0, "Empty device name passed to BLKRAGET");
 		return 0;
 	}
 
@@ -575,7 +575,7 @@ static int _stack_node_op(node_op_t type, const char *dev_name, uint32_t major,
 	}
 
 	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
-		log_error("Insufficient memory to stack mknod operation");
+		log_error(0, "Insufficient memory to stack mknod operation");
 		return 0;
 	}
 
@@ -712,7 +712,7 @@ int dm_driver_version(char *version, size_t size)
 		return 0;
 
 	if (!dm_task_run(dmt))
-		log_error("Failed to get driver version");
+		log_error(0, "Failed to get driver version");
 
 	if (!dm_task_get_driver_version(dmt, version, size))
 		goto out;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5c5ea97..2155002 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -148,7 +148,7 @@ struct dm_tree *dm_tree_create(void)
 	struct dm_tree *dtree;
 
 	if (!(dtree = dm_malloc(sizeof(*dtree)))) {
-		log_error("dm_tree_create malloc failed");
+		log_error(0, "dm_tree_create malloc failed");
 		return NULL;
 	}
 
@@ -160,20 +160,20 @@ struct dm_tree *dm_tree_create(void)
 	dtree->no_flush = 0;
 
 	if (!(dtree->mem = dm_pool_create("dtree", 1024))) {
-		log_error("dtree pool creation failed");
+		log_error(0, "dtree pool creation failed");
 		dm_free(dtree);
 		return NULL;
 	}
 
 	if (!(dtree->devs = dm_hash_create(8))) {
-		log_error("dtree hash creation failed");
+		log_error(0, "dtree hash creation failed");
 		dm_pool_destroy(dtree->mem);
 		dm_free(dtree);
 		return NULL;
 	}
 
 	if (!(dtree->uuids = dm_hash_create(32))) {
-		log_error("dtree uuid hash creation failed");
+		log_error(0, "dtree uuid hash creation failed");
 		dm_hash_destroy(dtree->devs);
 		dm_pool_destroy(dtree->mem);
 		dm_free(dtree);
@@ -211,7 +211,7 @@ static int _link(struct dm_list *list, struct dm_tree_node *node)
 	struct dm_tree_link *dlink;
 
 	if (!(dlink = dm_pool_alloc(node->dtree->mem, sizeof(*dlink)))) {
-		log_error("dtree link allocation failed");
+		log_error(0, "dtree link allocation failed");
 		return 0;
 	}
 
@@ -305,7 +305,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	uint64_t dev;
 
 	if (!(node = dm_pool_zalloc(dtree->mem, sizeof(*node)))) {
-		log_error("_create_dm_tree_node alloc failed");
+		log_error(0, "_create_dm_tree_node alloc failed");
 		return NULL;
 	}
 
@@ -325,14 +325,14 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 
 	if (!dm_hash_insert_binary(dtree->devs, (const char *) &dev,
 				sizeof(dev), node)) {
-		log_error("dtree node hash insertion failed");
+		log_error(0, "dtree node hash insertion failed");
 		dm_pool_free(dtree->mem, node);
 		return NULL;
 	}
 
 	if (uuid && *uuid &&
 	    !dm_hash_insert(dtree->uuids, uuid, node)) {
-		log_error("dtree uuid hash insertion failed");
+		log_error(0, "dtree uuid hash insertion failed");
 		dm_hash_remove_binary(dtree->devs, (const char *) &dev,
 				      sizeof(dev));
 		dm_pool_free(dtree->mem, node);
@@ -385,30 +385,30 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 	}
 
 	if (!(*dmt = dm_task_create(DM_DEVICE_DEPS))) {
-		log_error("deps dm_task creation failed");
+		log_error(0, "deps dm_task creation failed");
 		return 0;
 	}
 
 	if (!dm_task_set_major(*dmt, major)) {
-		log_error("_deps: failed to set major for (%" PRIu32 ":%" PRIu32 ")",
+		log_error(0, "_deps: failed to set major for (%" PRIu32 ":%" PRIu32 ")",
 			  major, minor);
 		goto failed;
 	}
 
 	if (!dm_task_set_minor(*dmt, minor)) {
-		log_error("_deps: failed to set minor for (%" PRIu32 ":%" PRIu32 ")",
+		log_error(0, "_deps: failed to set minor for (%" PRIu32 ":%" PRIu32 ")",
 			  major, minor);
 		goto failed;
 	}
 
 	if (!dm_task_run(*dmt)) {
-		log_error("_deps: task run failed for (%" PRIu32 ":%" PRIu32 ")",
+		log_error(0, "_deps: task run failed for (%" PRIu32 ":%" PRIu32 ")",
 			  major, minor);
 		goto failed;
 	}
 
 	if (!dm_task_get_info(*dmt, info)) {
-		log_error("_deps: failed to get info for (%" PRIu32 ":%" PRIu32 ")",
+		log_error(0, "_deps: failed to get info for (%" PRIu32 ":%" PRIu32 ")",
 			  major, minor);
 		goto failed;
 	}
@@ -419,21 +419,21 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 		*deps = NULL;
 	} else {
 		if (info->major != major) {
-			log_error("Inconsistent dtree major number: %u != %u",
+			log_error(0, "Inconsistent dtree major number: %u != %u",
 				  major, info->major);
 			goto failed;
 		}
 		if (info->minor != minor) {
-			log_error("Inconsistent dtree minor number: %u != %u",
+			log_error(0, "Inconsistent dtree minor number: %u != %u",
 				  minor, info->minor);
 			goto failed;
 		}
 		if (!(*name = dm_pool_strdup(mem, dm_task_get_name(*dmt)))) {
-			log_error("name pool_strdup failed");
+			log_error(0, "name pool_strdup failed");
 			goto failed;
 		}
 		if (!(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(*dmt)))) {
-			log_error("uuid pool_strdup failed");
+			log_error(0, "uuid pool_strdup failed");
 			goto failed;
 		}
 		*deps = dm_task_get_deps(*dmt);
@@ -511,12 +511,12 @@ static int _node_clear_table(struct dm_tree_node *dnode)
 	int r;
 
 	if (!(info = &dnode->info)) {
-		log_error("_node_clear_table failed: missing info");
+		log_error(0, "_node_clear_table failed: missing info");
 		return 0;
 	}
 
 	if (!(name = dm_tree_node_get_name(dnode))) {
-		log_error("_node_clear_table failed: missing name");
+		log_error(0, "_node_clear_table failed: missing name");
 		return 0;
 	}
 
@@ -529,13 +529,13 @@ static int _node_clear_table(struct dm_tree_node *dnode)
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CLEAR))) {
 		dm_task_destroy(dmt);
-		log_error("Table clear dm_task creation failed for %s", name);
+		log_error(0, "Table clear dm_task creation failed for %s", name);
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, info->major) ||
 	    !dm_task_set_minor(dmt, info->minor)) {
-		log_error("Failed to set device number for %s table clear", name);
+		log_error(0, "Failed to set device number for %s table clear", name);
 		dm_task_destroy(dmt);
 		return 0;
 	}
@@ -543,7 +543,7 @@ static int _node_clear_table(struct dm_tree_node *dnode)
 	r = dm_task_run(dmt);
 
 	if (!dm_task_get_info(dmt, info)) {
-		log_error("_node_clear_table failed: info missing after running task for %s", name);
+		log_error(0, "_node_clear_table failed: info missing after running task for %s", name);
 		r = 0;
 	}
 
@@ -568,11 +568,11 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
 	/* Do we need to add node to tree? */
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
 		if (!(name2 = dm_pool_strdup(dtree->mem, name))) {
-			log_error("name pool_strdup failed");
+			log_error(0, "name pool_strdup failed");
 			return NULL;
 		}
 		if (!(uuid2 = dm_pool_strdup(dtree->mem, uuid))) {
-			log_error("uuid pool_strdup failed");
+			log_error(0, "uuid pool_strdup failed");
 			return NULL;
 		}
 
@@ -598,7 +598,7 @@ struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
 	} else if (strcmp(name, dnode->name)) {
 		/* Do we need to rename node? */
 		if (!(dnode->props.new_name = dm_pool_strdup(dtree->mem, name))) {
-			log_error("name pool_strdup failed");
+			log_error(0, "name pool_strdup failed");
 			return 0;
 		}
 	}
@@ -798,18 +798,18 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	int r;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_info_by_dev: dm_task creation failed");
+		log_error(0, "_info_by_dev: dm_task creation failed");
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("_info_by_dev: Failed to set device number");
+		log_error(0, "_info_by_dev: Failed to set device number");
 		dm_task_destroy(dmt);
 		return 0;
 	}
 
 	if (!with_open_count && !dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, info);
@@ -827,18 +827,18 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor)
 	log_verbose("Removing %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_REMOVE))) {
-		log_error("Deactivation dm_task creation failed for %s", name);
+		log_error(0, "Deactivation dm_task creation failed for %s", name);
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("Failed to set device number for %s deactivation", name);
+		log_error(0, "Failed to set device number for %s deactivation", name);
 		dm_task_destroy(dmt);
 		return 0;
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	r = dm_task_run(dmt);
 
@@ -860,12 +860,12 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
 	log_verbose("Renaming %s (%" PRIu32 ":%" PRIu32 ") to %s", old_name, major, minor, new_name);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME))) {
-		log_error("Rename dm_task creation failed for %s", old_name);
+		log_error(0, "Rename dm_task creation failed for %s", old_name);
 		return 0;
 	}
 
 	if (!dm_task_set_name(dmt, old_name)) {
-		log_error("Failed to set name for %s rename.", old_name);
+		log_error(0, "Failed to set name for %s rename.", old_name);
 		goto out;
 	}
 
@@ -873,7 +873,7 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
                 goto_out;
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	r = dm_task_run(dmt);
 
@@ -894,28 +894,28 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RESUME))) {
-		log_error("Suspend dm_task creation failed for %s", name);
+		log_error(0, "Suspend dm_task creation failed for %s", name);
 		return 0;
 	}
 
 	/* FIXME Kernel should fill in name on return instead */
 	if (!dm_task_set_name(dmt, name)) {
-		log_error("Failed to set readahead device name for %s", name);
+		log_error(0, "Failed to set readahead device name for %s", name);
 		dm_task_destroy(dmt);
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("Failed to set device number for %s resumption.", name);
+		log_error(0, "Failed to set device number for %s resumption.", name);
 		dm_task_destroy(dmt);
 		return 0;
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
-		log_error("Failed to set read ahead");
+		log_error(0, "Failed to set read ahead");
 
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, newinfo);
@@ -937,24 +937,24 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 		    no_flush ? "" : " with device flush");
 
 	if (!(dmt = dm_task_create(DM_DEVICE_SUSPEND))) {
-		log_error("Suspend dm_task creation failed for %s", name);
+		log_error(0, "Suspend dm_task creation failed for %s", name);
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
-		log_error("Failed to set device number for %s suspension.", name);
+		log_error(0, "Failed to set device number for %s suspension.", name);
 		dm_task_destroy(dmt);
 		return 0;
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if (skip_lockfs && !dm_task_skip_lockfs(dmt))
-		log_error("Failed to set skip_lockfs flag.");
+		log_error(0, "Failed to set skip_lockfs flag.");
 
 	if (no_flush && !dm_task_no_flush(dmt))
-		log_error("Failed to set no_flush flag.");
+		log_error(0, "Failed to set no_flush flag.");
 
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, newinfo);
@@ -1001,7 +1001,7 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (!_deactivate_node(name, info.major, info.minor)) {
-			log_error("Unable to deactivate %s (%" PRIu32
+			log_error(0, "Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
 			continue;
@@ -1067,7 +1067,7 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 		if (!_suspend_node(name, info.major, info.minor,
 				   child->dtree->skip_lockfs,
 				   child->dtree->no_flush, &newinfo)) {
-			log_error("Unable to suspend %s (%" PRIu32
+			log_error(0, "Unable to suspend %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
 			continue;
@@ -1145,7 +1145,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			/* Rename? */
 			if (child->props.new_name) {
 				if (!_rename_node(name, child->props.new_name, child->info.major, child->info.minor)) {
-					log_error("Failed to rename %s (%" PRIu32
+					log_error(0, "Failed to rename %s (%" PRIu32
 						  ":%" PRIu32 ") to %s", name, child->info.major,
 						  child->info.minor, child->props.new_name);
 					return 0;
@@ -1160,7 +1160,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead,
 					  child->props.read_ahead_flags, &newinfo)) {
-				log_error("Unable to resume %s (%" PRIu32
+				log_error(0, "Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
 				continue;
@@ -1184,34 +1184,34 @@ static int _create_node(struct dm_tree_node *dnode)
 	log_verbose("Creating %s", dnode->name);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CREATE))) {
-		log_error("Create dm_task creation failed for %s", dnode->name);
+		log_error(0, "Create dm_task creation failed for %s", dnode->name);
 		return 0;
 	}
 
 	if (!dm_task_set_name(dmt, dnode->name)) {
-		log_error("Failed to set device name for %s", dnode->name);
+		log_error(0, "Failed to set device name for %s", dnode->name);
 		goto out;
 	}
 
 	if (!dm_task_set_uuid(dmt, dnode->uuid)) {
-		log_error("Failed to set uuid for %s", dnode->name);
+		log_error(0, "Failed to set uuid for %s", dnode->name);
 		goto out;
 	}
 
 	if (dnode->props.major &&
 	    (!dm_task_set_major(dmt, dnode->props.major) ||
 	     !dm_task_set_minor(dmt, dnode->props.minor))) {
-		log_error("Failed to set device number for %s creation.", dnode->name);
+		log_error(0, "Failed to set device number for %s creation.", dnode->name);
 		goto out;
 	}
 
 	if (dnode->props.read_only && !dm_task_set_ro(dmt)) {
-		log_error("Failed to set read only flag for %s", dnode->name);
+		log_error(0, "Failed to set read only flag for %s", dnode->name);
 		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	if ((r = dm_task_run(dmt)))
 		r = dm_task_get_info(dmt, &dnode->info);
@@ -1226,7 +1226,7 @@ out:
 static int _build_dev_string(char *devbuf, size_t bufsize, struct dm_tree_node *node)
 {
 	if (!dm_format_dev(devbuf, bufsize, node->info.major, node->info.minor)) {
-                log_error("Failed to format %s device number for %s as dm "
+                log_error(0, "Failed to format %s device number for %s as dm "
                           "target (%u,%u)",
                           node->name, node->uuid, node->info.major, node->info.minor);
                 return 0;
@@ -1392,7 +1392,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 
 	do {
 		if (!(params = dm_malloc(paramsize))) {
-			log_error("Insufficient space for target parameters.");
+			log_error(0, "Insufficient space for target parameters.");
 			return 0;
 		}
 
@@ -1413,7 +1413,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 		paramsize *= 2;
 	} while (paramsize < MAX_TARGET_PARAMSIZE);
 
-	log_error("Target parameter size too big. Aborting.");
+	log_error(0, "Target parameter size too big. Aborting.");
 	return 0;
 }
 
@@ -1428,23 +1428,23 @@ static int _load_node(struct dm_tree_node *dnode)
 		    dnode->info.major, dnode->info.minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD))) {
-		log_error("Reload dm_task creation failed for %s", dnode->name);
+		log_error(0, "Reload dm_task creation failed for %s", dnode->name);
 		return 0;
 	}
 
 	if (!dm_task_set_major(dmt, dnode->info.major) ||
 	    !dm_task_set_minor(dmt, dnode->info.minor)) {
-		log_error("Failed to set device number for %s reload.", dnode->name);
+		log_error(0, "Failed to set device number for %s reload.", dnode->name);
 		goto out;
 	}
 
 	if (dnode->props.read_only && !dm_task_set_ro(dmt)) {
-		log_error("Failed to set read only flag for %s", dnode->name);
+		log_error(0, "Failed to set read only flag for %s", dnode->name);
 		goto out;
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_error(0, "Failed to disable open_count");
 
 	dm_list_iterate_items(seg, &dnode->props.segs)
 		if (!_emit_segment(dmt, dnode->info.major, dnode->info.minor,
@@ -1452,7 +1452,7 @@ static int _load_node(struct dm_tree_node *dnode)
 			goto_out;
 
 	if (!dm_task_suppress_identical_reload(dmt))
-		log_error("Failed to suppress reload of identical tables.");
+		log_error(0, "Failed to suppress reload of identical tables.");
 
 	if ((r = dm_task_run(dmt))) {
 		r = dm_task_get_info(dmt, &dnode->info);
@@ -1527,7 +1527,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
 				  child->props.read_ahead,
 				  child->props.read_ahead_flags, &newinfo)) {
-			log_error("Unable to resume %s (%" PRIu32
+			log_error(0, "Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
 			continue;
@@ -1555,7 +1555,7 @@ int dm_tree_children_use_uuid(struct dm_tree_node *dnode,
 
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 		if (!(uuid = dm_tree_node_get_uuid(child))) {
-			log_error("Failed to get uuid for dtree node.");
+			log_error(0, "Failed to get uuid for dtree node.");
 			return 1;
 		}
 
@@ -1577,7 +1577,7 @@ static struct load_segment *_add_segment(struct dm_tree_node *dnode, unsigned ty
 	struct load_segment *seg;
 
 	if (!(seg = dm_pool_zalloc(dnode->dtree->mem, sizeof(*seg)))) {
-		log_error("dtree node segment allocation failed");
+		log_error(0, "dtree node segment allocation failed");
 		return NULL;
 	}
 
@@ -1608,7 +1608,7 @@ int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
 		return_0;
 
 	if (!(origin_node = dm_tree_find_node_by_uuid(dnode->dtree, origin_uuid))) {
-		log_error("Couldn't find snapshot origin uuid %s.", origin_uuid);
+		log_error(0, "Couldn't find snapshot origin uuid %s.", origin_uuid);
 		return 0;
 	}
 
@@ -1636,7 +1636,7 @@ int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
 		return_0;
 
 	if (!(origin_node = dm_tree_find_node_by_uuid(node->dtree, origin_uuid))) {
-		log_error("Couldn't find snapshot origin uuid %s.", origin_uuid);
+		log_error(0, "Couldn't find snapshot origin uuid %s.", origin_uuid);
 		return 0;
 	}
 
@@ -1645,7 +1645,7 @@ int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
 		return_0;
 
 	if (!(cow_node = dm_tree_find_node_by_uuid(node->dtree, cow_uuid))) {
-		log_error("Couldn't find snapshot origin uuid %s.", cow_uuid);
+		log_error(0, "Couldn't find snapshot origin uuid %s.", cow_uuid);
 		return 0;
 	}
 
@@ -1733,7 +1733,7 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 	struct load_segment *seg;
 
 	if (!node->props.segment_count) {
-		log_error("Internal error: Attempt to add target area to missing segment.");
+		log_error(0, "Internal error: Attempt to add target area to missing segment.");
 		return 0;
 	}
 
@@ -1741,12 +1741,12 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 
 	if (log_uuid) {
 		if (!(seg->uuid = dm_pool_strdup(node->dtree->mem, log_uuid))) {
-			log_error("log uuid pool_strdup failed");
+			log_error(0, "log uuid pool_strdup failed");
 			return 0;
 		}
 		if (!(flags & DM_CORELOG)) {
 			if (!(log_node = dm_tree_find_node_by_uuid(node->dtree, log_uuid))) {
-				log_error("Couldn't find mirror log uuid %s.", log_uuid);
+				log_error(0, "Couldn't find mirror log uuid %s.", log_uuid);
 				return 0;
 			}
 
@@ -1780,7 +1780,7 @@ static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct
 	struct seg_area *area;
 
 	if (!(area = dm_pool_zalloc(node->dtree->mem, sizeof (*area)))) {
-		log_error("Failed to allocate target segment area.");
+		log_error(0, "Failed to allocate target segment area.");
 		return 0;
 	}
 
@@ -1803,25 +1803,25 @@ int dm_tree_node_add_target_area(struct dm_tree_node *node,
 	struct dm_tree_node *dev_node;
 
 	if ((!dev_name || !*dev_name) && (!uuid || !*uuid)) {
-		log_error("dm_tree_node_add_target_area called without device");
+		log_error(0, "dm_tree_node_add_target_area called without device");
 		return 0;
 	}
 
 	if (uuid) {
 		if (!(dev_node = dm_tree_find_node_by_uuid(node->dtree, uuid))) {
-			log_error("Couldn't find area uuid %s.", uuid);
+			log_error(0, "Couldn't find area uuid %s.", uuid);
 			return 0;
 		}
 		if (!_link_tree_nodes(node, dev_node))
 			return_0;
 	} else {
         	if (stat(dev_name, &info) < 0) {
-			log_error("Device %s not found.", dev_name);
+			log_error(0, "Device %s not found.", dev_name);
 			return 0;
 		}
 
         	if (!S_ISBLK(info.st_mode)) {
-			log_error("Device %s is not a block device.", dev_name);
+			log_error(0, "Device %s is not a block device.", dev_name);
 			return 0;
 		}
 
@@ -1831,7 +1831,7 @@ int dm_tree_node_add_target_area(struct dm_tree_node *node,
 	}
 
 	if (!node->props.segment_count) {
-		log_error("Internal error: Attempt to add target area to missing segment.");
+		log_error(0, "Internal error: Attempt to add target area to missing segment.");
 		return 0;
 	}
 
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 749ee4f..cde7144 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -67,7 +67,7 @@ int dm_create_dir(const char *dir)
 	if (S_ISDIR(info.st_mode))
 		return 1;
 
-	log_error("Directory \"%s\" not found", dir);
+	log_error(0, "Directory \"%s\" not found", dir);
 	return 0;
 }
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6784a11..54af552 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -105,7 +105,7 @@ int dm_report_field_string(struct dm_report *rh,
 	char *repstr;
 
 	if (!(repstr = dm_pool_strdup(rh->mem, *data))) {
-		log_error("dm_report_field_string: dm_pool_strdup failed");
+		log_error(0, "dm_report_field_string: dm_pool_strdup failed");
 		return 0;
 	}
 
@@ -123,17 +123,17 @@ int dm_report_field_int(struct dm_report *rh,
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(rh->mem, 13))) {
-		log_error("dm_report_field_int: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_int: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(int64_t)))) {
-		log_error("dm_report_field_int: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_int: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 12, "%d", value) < 0) {
-		log_error("dm_report_field_int: int too big: %d", value);
+		log_error(0, "dm_report_field_int: int too big: %d", value);
 		return 0;
 	}
 
@@ -152,17 +152,17 @@ int dm_report_field_uint32(struct dm_report *rh,
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(rh->mem, 12))) {
-		log_error("dm_report_field_uint32: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_uint32: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
-		log_error("dm_report_field_uint32: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_uint32: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 11, "%u", value) < 0) {
-		log_error("dm_report_field_uint32: uint32 too big: %u", value);
+		log_error(0, "dm_report_field_uint32: uint32 too big: %u", value);
 		return 0;
 	}
 
@@ -181,17 +181,17 @@ int dm_report_field_int32(struct dm_report *rh,
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(rh->mem, 13))) {
-		log_error("dm_report_field_int32: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_int32: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(int64_t)))) {
-		log_error("dm_report_field_int32: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_int32: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 12, "%d", value) < 0) {
-		log_error("dm_report_field_int32: int32 too big: %d", value);
+		log_error(0, "dm_report_field_int32: int32 too big: %d", value);
 		return 0;
 	}
 
@@ -210,17 +210,17 @@ int dm_report_field_uint64(struct dm_report *rh,
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(rh->mem, 22))) {
-		log_error("dm_report_field_uint64: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_uint64: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
-		log_error("dm_report_field_uint64: dm_pool_alloc failed");
+		log_error(0, "dm_report_field_uint64: dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (dm_snprintf(repstr, 21, "%d", value) < 0) {
-		log_error("dm_report_field_uint64: uint64 too big: %d", value);
+		log_error(0, "dm_report_field_uint64: uint64 too big: %d", value);
 		return 0;
 	}
 
@@ -295,7 +295,7 @@ static int _copy_field(struct dm_report *rh, struct field_properties *dest,
 	/* set object type method */
 	dest->type = _find_type(rh, rh->fields[field_num].type);
 	if (!dest->type) {
-		log_error("dm_report: field not match: %s",
+		log_error(0, "dm_report: field not match: %s",
 			  rh->fields[field_num].id);
 		return 0;
 	}
@@ -309,7 +309,7 @@ static struct field_properties * _add_field(struct dm_report *rh,
 	struct field_properties *fp;
 
 	if (!(fp = dm_pool_zalloc(rh->mem, sizeof(struct field_properties)))) {
-		log_error("dm_report: struct field_properties allocation "
+		log_error(0, "dm_report: struct field_properties allocation "
 			  "failed");
 		return NULL;
 	}
@@ -459,7 +459,7 @@ static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
 		return 1;
 
 	if (found->flags & FLD_SORT_KEY) {
-		log_error("dm_report: Ignoring duplicate sort field: %s",
+		log_error(0, "dm_report: Ignoring duplicate sort field: %s",
 			  rh->fields[field_num].id);
 		return 1;
 	}
@@ -492,7 +492,7 @@ static int _key_match(struct dm_report *rh, const char *key, size_t len,
 		flags = FLD_ASCENDING;
 
 	if (!len) {
-		log_error("dm_report: Missing sort field name");
+		log_error(0, "dm_report: Missing sort field name");
 		return 0;
 	}
 
@@ -524,7 +524,7 @@ static int _parse_fields(struct dm_report *rh, const char *format,
 			_display_fields(rh);
 			log_warn(" ");
 			if (strcasecmp(ws, "help") && strcmp(ws, "?"))
-				log_error("Unrecognised field: %.*s",
+				log_error(0, "Unrecognised field: %.*s",
 					  (int) (we - ws), ws);
 			return 0;
 		}
@@ -547,7 +547,7 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			log_error("dm_report: Unrecognised field: %.*s",
+			log_error(0, "dm_report: Unrecognised field: %.*s",
 				  (int) (we - ws), ws);
 			return 0;
 		}
@@ -569,7 +569,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	const struct dm_report_object_type *type;
 
 	if (!(rh = dm_malloc(sizeof(*rh)))) {
-		log_error("dm_report_init: dm_malloc failed");
+		log_error(0, "dm_report_init: dm_malloc failed");
 		return 0;
 	}
 	memset(rh, 0, sizeof(*rh));
@@ -609,7 +609,7 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 		rh->field_prefix = "";
 
 	if (!(rh->mem = dm_pool_create("report", 10 * 1024))) {
-		log_error("dm_report_init: allocation of memory pool failed");
+		log_error(0, "dm_report_init: allocation of memory pool failed");
 		dm_free(rh);
 		return NULL;
 	}
@@ -661,7 +661,7 @@ int dm_report_set_output_field_name_prefix(struct dm_report *rh, const char *out
 	char *prefix;
 
 	if (!(prefix = dm_pool_strdup(rh->mem, output_field_name_prefix))) {
-		log_error("dm_report_set_output_field_name_prefix: dm_pool_strdup failed");
+		log_error(0, "dm_report_set_output_field_name_prefix: dm_pool_strdup failed");
 		return 0;
 	}
 
@@ -692,7 +692,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	void *data = NULL;
 
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
-		log_error("dm_report_object: struct row allocation failed");
+		log_error(0, "dm_report_object: struct row allocation failed");
 		return 0;
 	}
 
@@ -702,7 +702,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	    !(row->sort_fields =
 		dm_pool_zalloc(rh->mem, sizeof(struct dm_report_field *) *
 			       rh->keys_count))) {
-		log_error("dm_report_object: "
+		log_error(0, "dm_report_object: "
 			  "row sort value structure allocation failed");
 		return 0;
 	}
@@ -713,7 +713,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	/* For each field to be displayed, call its report_fn */
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (!(field = dm_pool_zalloc(rh->mem, sizeof(*field)))) {
-			log_error("dm_report_object: "
+			log_error(0, "dm_report_object: "
 				  "struct dm_report_field allocation failed");
 			return 0;
 		}
@@ -726,7 +726,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 		if (!rh->fields[fp->field_num].report_fn(rh, rh->mem,
 							 field, data,
 							 rh->private)) {
-			log_error("dm_report_object: "
+			log_error(0, "dm_report_object: "
 				  "report function failed for field %s",
 				  rh->fields[fp->field_num].id);
 			return 0;
@@ -766,7 +766,7 @@ static int _report_headings(struct dm_report *rh)
 		return 1;
 
 	if (!dm_pool_begin_object(rh->mem, 128)) {
-		log_error("dm_report: "
+		log_error(0, "dm_report: "
 			  "dm_pool_begin_object failed for headings");
 		return 0;
 	}
@@ -780,26 +780,26 @@ static int _report_headings(struct dm_report *rh)
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
-				log_error("dm_report: snprintf heading failed");
+				log_error(0, "dm_report: snprintf heading failed");
 				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, fp->width)) {
-				log_error("dm_report: Failed to generate report headings for printing");
+				log_error(0, "dm_report: Failed to generate report headings for printing");
 				goto bad;
 			}
 		} else if (!dm_pool_grow_object(rh->mem, heading, 0)) {
-			log_error("dm_report: Failed to generate report headings for printing");
+			log_error(0, "dm_report: Failed to generate report headings for printing");
 			goto bad;
 		}
 
 		if (!dm_list_end(&rh->field_props, &fp->list))
 			if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-				log_error("dm_report: Failed to generate report headings for printing");
+				log_error(0, "dm_report: Failed to generate report headings for printing");
 				goto bad;
 			}
 	}
 	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-		log_error("dm_report: Failed to generate report headings for printing");
+		log_error(0, "dm_report: Failed to generate report headings for printing");
 		goto bad;
 	}
 	log_print("%s", (char *) dm_pool_end_object(rh->mem));
@@ -865,7 +865,7 @@ static int _sort_rows(struct dm_report *rh)
 
 	if (!(rows = dm_pool_alloc(rh->mem, sizeof(**rows) *
 				dm_list_size(&rh->rows)))) {
-		log_error("dm_report: sort array allocation failed");
+		log_error(0, "dm_report: sort array allocation failed");
 		return 0;
 	}
 
@@ -894,30 +894,30 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = strdup(rh->fields[field->props->field_num].id))) {
-			log_error("dm_report: Failed to copy field name");
+			log_error(0, "dm_report: Failed to copy field name");
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 
 		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 
 		free(field_id);
 
 		if (!dm_pool_grow_object(rh->mem, "=", 1)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 
 		if (!(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED) &&
 		    !dm_pool_grow_object(rh->mem, "\'", 1)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 	}
@@ -926,7 +926,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	width = field->props->width;
 	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
 		if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 	} else {
@@ -936,21 +936,21 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		if (align & DM_REPORT_FIELD_ALIGN_LEFT) {
 			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
 					 width, width, repstr) < 0) {
-				log_error("dm_report: left-aligned snprintf() failed");
+				log_error(0, "dm_report: left-aligned snprintf() failed");
 				return 0;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
-				log_error("dm_report: Unable to extend output line");
+				log_error(0, "dm_report: Unable to extend output line");
 				return 0;
 			}
 		} else if (align & DM_REPORT_FIELD_ALIGN_RIGHT) {
 			if (dm_snprintf(buf, sizeof(buf), "%*.*s",
 					 width, width, repstr) < 0) {
-				log_error("dm_report: right-aligned snprintf() failed");
+				log_error(0, "dm_report: right-aligned snprintf() failed");
 				return 0;
 			}
 			if (!dm_pool_grow_object(rh->mem, buf, width)) {
-				log_error("dm_report: Unable to extend output line");
+				log_error(0, "dm_report: Unable to extend output line");
 				return 0;
 			}
 		}
@@ -959,7 +959,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	if ((rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) &&
 	    !(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED))
 		if (!dm_pool_grow_object(rh->mem, "\'", 1)) {
-			log_error("dm_report: Unable to extend output line");
+			log_error(0, "dm_report: Unable to extend output line");
 			return 0;
 		}
 
@@ -973,7 +973,7 @@ static int _output_as_rows(struct dm_report *rh)
 	struct row *row;
 
 	if (!dm_pool_begin_object(rh->mem, 512)) {
-		log_error("dm_report: Unable to allocate output line");
+		log_error(0, "dm_report: Unable to allocate output line");
 		return 0;
 	}
 
@@ -988,11 +988,11 @@ static int _output_as_rows(struct dm_report *rh)
 
 		if ((rh->flags & DM_REPORT_OUTPUT_HEADINGS)) {
 			if (!dm_pool_grow_object(rh->mem, rh->fields[fp->field_num].heading, 0)) {
-				log_error("dm_report: Failed to extend row for field name");
+				log_error(0, "dm_report: Failed to extend row for field name");
 				goto bad;
 			}
 			if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-				log_error("dm_report: Failed to extend row with separator");
+				log_error(0, "dm_report: Failed to extend row with separator");
 				goto bad;
 			}
 		}
@@ -1006,13 +1006,13 @@ static int _output_as_rows(struct dm_report *rh)
 
 			if (!dm_list_end(&rh->rows, &row->list))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-					log_error("dm_report: Unable to extend output line");
+					log_error(0, "dm_report: Unable to extend output line");
 					goto bad;
 				}
 		}
 
 		if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-			log_error("dm_report: Failed to terminate row");
+			log_error(0, "dm_report: Failed to terminate row");
 			goto bad;
 		}
 		log_print("%s", (char *) dm_pool_end_object(rh->mem));
@@ -1038,7 +1038,7 @@ static int _output_as_columns(struct dm_report *rh)
 	/* Print and clear buffer */
 	dm_list_iterate_safe(rowh, rtmp, &rh->rows) {
 		if (!dm_pool_begin_object(rh->mem, 512)) {
-			log_error("dm_report: Unable to allocate output line");
+			log_error(0, "dm_report: Unable to allocate output line");
 			return 0;
 		}
 		row = dm_list_item(rowh, struct row);
@@ -1052,14 +1052,14 @@ static int _output_as_columns(struct dm_report *rh)
 
 			if (!dm_list_end(&row->fields, fh))
 				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-					log_error("dm_report: Unable to extend output line");
+					log_error(0, "dm_report: Unable to extend output line");
 					goto bad;
 				}
 
 			dm_list_del(&field->list);
 		}
 		if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-			log_error("dm_report: Unable to terminate output line");
+			log_error(0, "dm_report: Unable to terminate output line");
 			goto bad;
 		}
 		log_print("%s", (char *) dm_pool_end_object(rh->mem));
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index add285a..8b53e5d 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -23,7 +23,7 @@ char *dm_strdup_aux(const char *str, const char *file, int line)
 	char *ret;
 
 	if (!str) {
-		log_error("Internal error: dm_strdup called with NULL pointer");
+		log_error(0, "Internal error: dm_strdup called with NULL pointer");
 		return NULL;
 	}
 
@@ -60,13 +60,13 @@ void *dm_malloc_aux_debug(size_t s, const char *file, int line)
 	size_t tsize = s + sizeof(*nb) + sizeof(unsigned long);
 
 	if (s > 50000000) {
-		log_error("Huge memory allocation (size %" PRIsize_t
+		log_error(0, "Huge memory allocation (size %" PRIsize_t
 			  ") rejected - metadata corruption?", s);
 		return 0;
 	}
 
 	if (!(nb = malloc(tsize))) {
-		log_error("couldn't allocate any memory, size = %" PRIsize_t,
+		log_error(0, "couldn't allocate any memory, size = %" PRIsize_t,
 			  s);
 		return 0;
 	}
@@ -235,7 +235,7 @@ void *dm_malloc_aux(size_t s, const char *file __attribute((unused)),
 		    int line __attribute((unused)))
 {
 	if (s > 50000000) {
-		log_error("Huge memory allocation (size %" PRIsize_t
+		log_error(0, "Huge memory allocation (size %" PRIsize_t
 			  ") rejected - metadata corruption?", s);
 		return 0;
 	}
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index f775dea..c70f3b8 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -51,7 +51,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 	struct dm_pool *mem = dm_malloc(sizeof(*mem));
 
 	if (!mem) {
-		log_error("Couldn't create memory pool %s (size %"
+		log_error(0, "Couldn't create memory pool %s (size %"
 			  PRIsize_t ")", name, sizeof(*mem));
 		return NULL;
 	}
@@ -149,12 +149,12 @@ static struct block *_new_block(size_t s, unsigned alignment)
 	assert(alignment == DEFAULT_ALIGNMENT);
 
 	if (!b) {
-		log_err("Out of memory");
+		log_error(0, "Out of memory");
 		return NULL;
 	}
 
 	if (!(b->data = dm_malloc(s))) {
-		log_err("Out of memory");
+		log_error(0, "Out of memory");
 		dm_free(b);
 		return NULL;
 	}
@@ -237,7 +237,7 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 		new_size = delta;
 
 	if (!(new = _new_block(new_size, DEFAULT_ALIGNMENT))) {
-		log_err("Couldn't extend object.");
+		log_error(0, "Couldn't extend object.");
 		return 0;
 	}
 
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index d34cd9a..425e368 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -41,7 +41,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 	struct dm_pool *p = dm_malloc(sizeof(*p));
 
 	if (!p) {
-		log_error("Couldn't create memory pool %s (size %"
+		log_error(0, "Couldn't create memory pool %s (size %"
 			  PRIsize_t ")", name, sizeof(*p));
 		return 0;
 	}
@@ -132,7 +132,7 @@ void dm_pool_free(struct dm_pool *p, void *ptr)
 	}
 
 	if (!c)
-		log_error("Internal error: pool_free asked to free pointer "
+		log_error(0, "Internal error: pool_free asked to free pointer "
 			  "not in pool");
 	else
 		p->chunk = c;
@@ -224,7 +224,7 @@ struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 		p->spare_chunk = 0;
 	} else {
 		if (!(c = dm_malloc(s))) {
-			log_error("Out of memory.  Requested %" PRIsize_t
+			log_error(0, "Out of memory.  Requested %" PRIsize_t
 				  " bytes.", s);
 			return NULL;
 		}
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 35bfffa..fe96c1a 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -64,14 +64,14 @@ void dm_pools_check_leaks(void)
 	if (dm_list_empty(&_dm_pools))
 		return;
 
-	log_error("You have a memory leak (not released memory pool):");
+	log_error(0, "You have a memory leak (not released memory pool):");
 	dm_list_iterate_items(p, &_dm_pools) {
 #ifdef DEBUG_POOL
-		log_error(" [%p] %s (%u bytes)",
+		log_error(0, " [%p] %s (%u bytes)",
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p]", p);
+		log_error(0, " [%p]", p);
 #endif
 	}
 }
diff --git a/libdm/regex/matcher.c b/libdm/regex/matcher.c
index c2dda3e..869103a 100644
--- a/libdm/regex/matcher.c
+++ b/libdm/regex/matcher.c
@@ -133,7 +133,7 @@ static void _calc_functions(struct dm_regex *m)
 			break;
 
 		default:
-			log_error("Internal error: Unknown calc node type");
+			log_error(0, "Internal error: Unknown calc node type");
 		}
 
 		/*
@@ -300,7 +300,7 @@ struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
 
 	/* parse this expression */
 	if (!(rx = rx_parse_tok(scratch, all, ptr))) {
-		log_error("Couldn't parse regex");
+		log_error(0, "Couldn't parse regex");
 		goto bad;
 	}
 
diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index fdea1a3..3f090f1 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -85,7 +85,7 @@ static int _rx_get_token(struct parse_sp *ps)
 				range = 1;
 				ptr++;
 				if (ptr == ps->rx_end) {
-					log_error("Incomplete range"
+					log_error(0, "Incomplete range"
 						  "specification");
 					return -1;
 				}
@@ -163,7 +163,7 @@ static int _rx_get_token(struct parse_sp *ps)
 		/* escaped character */
 		ptr++;
 		if (ptr >= ps->rx_end) {
-			log_error("Badly quoted character at end "
+			log_error(0, "Badly quoted character at end "
 				  "of expression");
 			ps->type = -1;
 			return -1;
@@ -237,7 +237,7 @@ static struct rx_node *_term(struct parse_sp *ps)
 		_rx_get_token(ps);	/* match '(' */
 		n = _or_term(ps);
 		if (ps->type != ')') {
-			log_error("missing ')' in regular expression");
+			log_error(0, "missing ')' in regular expression");
 			return 0;
 		}
 		_rx_get_token(ps);	/* match ')' */
@@ -319,7 +319,7 @@ static struct rx_node *_or_term(struct parse_sp *ps)
 	_rx_get_token(ps);		/* match '|' */
 
 	if (!(r = _or_term(ps))) {
-		log_error("Badly formed 'or' expression");
+		log_error(0, "Badly formed 'or' expression");
 		return NULL;
 	}
 
@@ -347,7 +347,7 @@ struct rx_node *rx_parse_tok(struct dm_pool *mem,
 	_rx_get_token(ps);		/* load the first token */
 
 	if (!(r = _or_term(ps))) {
-		log_error("Parse error in regex");
+		log_error(0, "Parse error in regex");
 		dm_pool_free(mem, ps);
 	}
 
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 6d27c4d..2841719 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -44,7 +44,7 @@ lvm_t lvm_create(const char *system_dir)
 	/* initialize locking */
 	if (!init_locking(-1, cmd)) {
 		/* FIXME: use EAGAIN as error code here */
-		log_error("Locking initialisation failed.");
+		log_error(0, "Locking initialisation failed.");
 		lvm_destroy((lvm_t) cmd);
 		return NULL;
 	}
diff --git a/old-tests/datastruct/hash_t.c b/old-tests/datastruct/hash_t.c
index e977eab..4c83e2c 100644
--- a/old-tests/datastruct/hash_t.c
+++ b/old-tests/datastruct/hash_t.c
@@ -63,7 +63,7 @@ static void _do_test(int table_size, int num_entries)
 	for (i = 0; i < num_entries; i++) {
 		/* make up a word */
 		if (!(key = _create_word_from_file(i))) {
-			log_error("Ran out of words !\n");
+			log_error(0, "Ran out of words !\n");
 			exit(1);
 		}
 
@@ -76,7 +76,7 @@ static void _do_test(int table_size, int num_entries)
 	for (key = all; key; key = key->next) {
 		tmp = (struct key_list *) hash_lookup(ht, key->key);
 		if (!tmp || (tmp != key)) {
-			log_error("lookup failed\n");
+			log_error(0, "lookup failed\n");
 			exit(1);
 		}
 	}
diff --git a/old-tests/dev-mgr/dev_cache_t.c b/old-tests/dev-mgr/dev_cache_t.c
index 7cd2085..f4b25b9 100644
--- a/old-tests/dev-mgr/dev_cache_t.c
+++ b/old-tests/dev-mgr/dev_cache_t.c
@@ -26,19 +26,19 @@ int main(int argc, char **argv)
 
 	init_log();
 	if (!dev_cache_init()) {
-		log_error("couldn't initialise dev_cache_init failed\n");
+		log_error(0, "couldn't initialise dev_cache_init failed\n");
 		exit(1);
 	}
 
 	for (i = 1; i < argc; i++) {
 		if (!dev_cache_add_dir(argv[i])) {
-			log_error("couldn't add '%s' to dev_cache\n");
+			log_error(0, "couldn't add '%s' to dev_cache\n");
 			exit(1);
 		}
 	}
 
 	if (!(iter = dev_iter_create(NULL))) {
-		log_error("couldn't create iterator\n");
+		log_error(0, "couldn't create iterator\n");
 		exit(1);
 	}
 
diff --git a/old-tests/device/dev_cache_t.c b/old-tests/device/dev_cache_t.c
index f19a56f..63342d4 100644
--- a/old-tests/device/dev_cache_t.c
+++ b/old-tests/device/dev_cache_t.c
@@ -35,19 +35,19 @@ int main(int argc, char **argv)
 	init_debug(_LOG_INFO);
 
 	if (!dev_cache_init()) {
-		log_err("couldn't initialise dev_cache_init failed");
+		log_error(0, "couldn't initialise dev_cache_init failed");
 		exit(1);
 	}
 
 	for (i = 1; i < argc; i++) {
 		if (!dev_cache_add_dir(argv[i])) {
-			log_err("couldn't add '%s' to dev_cache", argv[i]);
+			log_error(0, "couldn't add '%s' to dev_cache", argv[i]);
 			exit(1);
 		}
 	}
 
 	if (!(iter = dev_iter_create(NULL))) {
-		log_err("couldn't create iterator");
+		log_error(0, "couldn't create iterator");
 		exit(1);
 	}
 
diff --git a/old-tests/device/random.c b/old-tests/device/random.c
index d2cac3b..e253119 100644
--- a/old-tests/device/random.c
+++ b/old-tests/device/random.c
@@ -100,7 +100,7 @@ int rand_check(void)
 	rand_init(-314159L);
 
 	if (next_rand(sc) != 119318998)	{
-		log_err("Random number generator failed check 1");
+		log_error(0, "Random number generator failed check 1");
 		return 0;
 	}
 
@@ -108,7 +108,7 @@ int rand_check(void)
 		rand_get();
 
 	if (_uniform(0x55555555L) != 748103812) {
-		log_err("Random number generator failed check 2");
+		log_error(0, "Random number generator failed check 2");
 		return 0;
 	}
 
diff --git a/old-tests/filters/pfilter_t.c b/old-tests/filters/pfilter_t.c
index e9f8af4..7c2b0fd 100644
--- a/old-tests/filters/pfilter_t.c
+++ b/old-tests/filters/pfilter_t.c
@@ -80,7 +80,7 @@ int main(int argc, char **argv)
 	}
 
 	if (!(iter = dev_iter_create(pfilter))) {
-		log_err("couldn't create iterator");
+		log_error(0, "couldn't create iterator");
 		exit(1);
 	}
 
@@ -102,7 +102,7 @@ int main(int argc, char **argv)
 	}
 
 	if (!(iter = dev_iter_create(pfilter))) {
-		log_err("couldn't create iterator");
+		log_error(0, "couldn't create iterator");
 		exit(1);
 	}
 
diff --git a/old-tests/filters/rfilter_t.c b/old-tests/filters/rfilter_t.c
index 6f0bb9d..4bb6dbf 100644
--- a/old-tests/filters/rfilter_t.c
+++ b/old-tests/filters/rfilter_t.c
@@ -73,7 +73,7 @@ int main(int argc, char **argv)
 	}
 
 	if (!(iter = dev_iter_create(filter))) {
-		log_err("couldn't create iterator");
+		log_error(0, "couldn't create iterator");
 		exit(1);
 	}
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3582e4a..1367b3d 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -314,7 +314,7 @@ static char *_extract_uuid_prefix(const char *uuid, const int separator)
 
 	len = ptr ? ptr - uuid : 0;
 	if (!(uuid_prefix = dm_malloc(len + 1))) {
-		log_error("Failed to allocate memory to extract uuid prefix.");
+		log_error(0, "Failed to allocate memory to extract uuid prefix.");
 		return NULL;
 	}
 
@@ -330,7 +330,7 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 	struct dm_split_name *split_name;
 
 	if (!(split_name = dm_malloc(sizeof(*split_name)))) {
-		log_error("Failed to allocate memory to split device name "
+		log_error(0, "Failed to allocate memory to split device name "
 			  "into components.");
 		return NULL;
 	}
@@ -343,7 +343,7 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 	    (!(split_name->vg_name = dm_strdup(name)) ||
 	     !dm_split_lvm_name(NULL, NULL, &split_name->vg_name,
 			        &split_name->lv_name, &split_name->lv_layer)))
-		log_error("Failed to allocate memory to split LVM name "
+		log_error(0, "Failed to allocate memory to split LVM name "
 			  "into components.");
 
 	return split_name;
@@ -1801,18 +1801,18 @@ static int _dm_info_devno_disp(struct dm_report *rh, struct dm_pool *mem,
 	struct dm_info *info = (struct dm_info *) data;
 
 	if (!dm_pool_begin_object(mem, 8)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
 	if (dm_snprintf(buf, sizeof(buf), "%d:%d",
 			info->major, info->minor) < 0) {
-		log_error("dm_pool_alloc failed");
+		log_error(0, "dm_pool_alloc failed");
 		goto out_abandon;
 	}
 
 	if (!dm_pool_grow_object(mem, buf, strlen(buf) + 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		goto out_abandon;
 	}
 
@@ -1836,7 +1836,7 @@ static int _dm_tree_names(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr;
 
 	if (!dm_pool_begin_object(mem, 16)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
@@ -1845,11 +1845,11 @@ static int _dm_tree_names(struct dm_report *rh, struct dm_pool *mem,
 		if (!name || !*name)
 			continue;
 		if (!first_node && !dm_pool_grow_object(mem, ",", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 		if (!dm_pool_grow_object(mem, name, 0)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 		if (first_node)
@@ -1857,7 +1857,7 @@ static int _dm_tree_names(struct dm_report *rh, struct dm_pool *mem,
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		goto out_abandon;
 	}
 
@@ -1897,7 +1897,7 @@ static int _dm_tree_parents_devs_disp(struct dm_report *rh, struct dm_pool *mem,
 	char buf[DM_MAX_TYPE_NAME], *repstr;
 
 	if (!dm_pool_begin_object(mem, 16)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
@@ -1906,16 +1906,16 @@ static int _dm_tree_parents_devs_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (!info->major && !info->minor)
 			continue;
 		if (!first_node && !dm_pool_grow_object(mem, ",", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 		if (dm_snprintf(buf, sizeof(buf), "%d:%d",
 				info->major, info->minor) < 0) {
-			log_error("dm_snprintf failed");
+			log_error(0, "dm_snprintf failed");
 			goto out_abandon;
 		}
 		if (!dm_pool_grow_object(mem, buf, 0)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 		if (first_node)
@@ -1923,7 +1923,7 @@ static int _dm_tree_parents_devs_disp(struct dm_report *rh, struct dm_pool *mem,
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		goto out_abandon;
 	}
 
@@ -1956,7 +1956,7 @@ static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
 	char buf[DM_MAX_TYPE_NAME], *repstr;
 
 	if (!dm_pool_begin_object(mem, 16)) {
-		log_error("dm_pool_begin_object failed");
+		log_error(0, "dm_pool_begin_object failed");
 		return 0;
 	}
 
@@ -1964,21 +1964,21 @@ static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (dm_snprintf(buf, sizeof(buf), "%d:%d",
 		       (int) MAJOR(deps->device[i]),
 		       (int) MINOR(deps->device[i])) < 0) {
-			log_error("dm_snprintf failed");
+			log_error(0, "dm_snprintf failed");
 			goto out_abandon;
 		}
 		if (!dm_pool_grow_object(mem, buf, 0)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 		if (i + 1 < deps->count && !dm_pool_grow_object(mem, ",", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(0, "dm_pool_grow_object failed");
 			goto out_abandon;
 		}
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+		log_error(0, "dm_pool_grow_object failed");
 		goto out_abandon;
 	}
 
@@ -2791,7 +2791,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 					_read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 				_int_args[READAHEAD_ARG] = atoi(optarg);
 				if (_int_args[READAHEAD_ARG] < -1) {
-					log_error("Negative read ahead value "
+					log_error(0, "Negative read ahead value "
 						  "(%d) is not understood.",
 						  _int_args[READAHEAD_ARG]);
 					return 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index f64f6d1..3931149 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -25,20 +25,20 @@ static int lvchange_permission(struct cmd_context *cmd,
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
 	if ((lv_access & LVM_WRITE) && (lv->status & LVM_WRITE)) {
-		log_error("Logical volume \"%s\" is already writable",
+		log_error(0, "Logical volume \"%s\" is already writable",
 			  lv->name);
 		return 0;
 	}
 
 	if (!(lv_access & LVM_WRITE) && !(lv->status & LVM_WRITE)) {
-		log_error("Logical volume \"%s\" is already read only",
+		log_error(0, "Logical volume \"%s\" is already read only",
 			  lv->name);
 		return 0;
 	}
 
 	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
 	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-		log_error("Cannot change permissions of mirror \"%s\" "
+		log_error(0, "Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
 		return 0;
 	}
@@ -58,7 +58,7 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return_0;
 
 	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
+		log_error(0, "Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
 		goto out;
 	}
@@ -70,7 +70,7 @@ static int lvchange_permission(struct cmd_context *cmd,
 
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
+		log_error(0, "Problem reactivating %s", lv->name);
 		goto out;
 	}
 
@@ -86,7 +86,7 @@ static int lvchange_monitoring(struct cmd_context *cmd,
 	struct lvinfo info;
 
 	if (!lv_info(cmd, lv, &info, 0, 0) || !info.exists) {
-		log_error("Logical volume, %s, is not active", lv->name);
+		log_error(0, "Logical volume, %s, is not active", lv->name);
 		return 0;
 	}
 
@@ -174,24 +174,24 @@ static int lvchange_resync(struct cmd_context *cmd,
 	struct logical_volume *log_lv;
 
 	if (!(lv->status & MIRRORED)) {
-		log_error("Unable to resync %s because it is not mirrored.",
+		log_error(0, "Unable to resync %s because it is not mirrored.",
 			  lv->name);
 		return 1;
 	}
 
 	if (lv->status & PVMOVE) {
-		log_error("Unable to resync pvmove volume %s", lv->name);
+		log_error(0, "Unable to resync pvmove volume %s", lv->name);
 		return 0;
 	}
 
 	if (lv->status & LOCKED) {
-		log_error("Unable to resync locked volume %s", lv->name);
+		log_error(0, "Unable to resync locked volume %s", lv->name);
 		return 0;
 	}
 
 	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
-			log_error("Can't resync open logical volume \"%s\"",
+			log_error(0, "Can't resync open logical volume \"%s\"",
 				  lv->name);
 			return 0;
 		}
@@ -218,12 +218,12 @@ static int lvchange_resync(struct cmd_context *cmd,
 	init_dmeventd_monitor(0);
 
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate %s for resync", lv->name);
+		log_error(0, "Unable to deactivate %s for resync", lv->name);
 		return 0;
 	}
 
 	if (vg_is_clustered(lv->vg) && lv_is_active(lv)) {
-		log_error("Can't get exclusive access to clustered volume %s",
+		log_error(0, "Can't get exclusive access to clustered volume %s",
 			  lv->name);
 		return 0;
 	}
@@ -246,7 +246,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 	 */
 	if (!log_lv && !(lv->status & MIRROR_NOTSYNCED)) {
 		if (active && !activate_lv(cmd, lv)) {
-			log_error("Failed to reactivate %s to resynchronize "
+			log_error(0, "Failed to reactivate %s to resynchronize "
 				  "mirror", lv->name);
 			return 0;
 		}
@@ -260,7 +260,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 		detach_mirror_log(first_seg(lv));
 
 		if (!vg_write(lv->vg)) {
-			log_error("Failed to write intermediate VG metadata.");
+			log_error(0, "Failed to write intermediate VG metadata.");
 			if (!attach_mirror_log(first_seg(lv), log_lv))
 				stack;
 			if (active && !activate_lv(cmd, lv))
@@ -269,7 +269,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 		}
 
 		if (!vg_commit(lv->vg)) {
-			log_error("Failed to commit intermediate VG metadata.");
+			log_error(0, "Failed to commit intermediate VG metadata.");
 			if (!attach_mirror_log(first_seg(lv), log_lv))
 				stack;
 			if (active && !activate_lv(cmd, lv))
@@ -280,22 +280,22 @@ static int lvchange_resync(struct cmd_context *cmd,
 		backup(lv->vg);
 
 		if (!activate_lv(cmd, log_lv)) {
-			log_error("Unable to activate %s for mirror log resync",
+			log_error(0, "Unable to activate %s for mirror log resync",
 				  log_lv->name);
 			return 0;
 		}
 
 		log_very_verbose("Clearing log device %s", log_lv->name);
 		if (!set_lv(cmd, log_lv, log_lv->size, 0)) {
-			log_error("Unable to reset sync status for %s", lv->name);
+			log_error(0, "Unable to reset sync status for %s", lv->name);
 			if (!deactivate_lv(cmd, log_lv))
-				log_error("Failed to deactivate log LV after "
+				log_error(0, "Failed to deactivate log LV after "
 					  "wiping failed");
 			return 0;
 		}
 
 		if (!deactivate_lv(cmd, log_lv)) {
-			log_error("Unable to deactivate log LV %s after wiping "
+			log_error(0, "Unable to deactivate log LV %s after wiping "
 				  "for resync", log_lv->name);
 			return 0;
 		}
@@ -307,12 +307,12 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-		log_error("Failed to update metadata on disk.");
+		log_error(0, "Failed to update metadata on disk.");
 		return 0;
 	}
 
 	if (active && !activate_lv(cmd, lv)) {
-		log_error("Failed to reactivate %s after resync", lv->name);
+		log_error(0, "Failed to reactivate %s after resync", lv->name);
 		return 0;
 	}
 
@@ -329,7 +329,7 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 	alloc = arg_uint_value(cmd, alloc_ARG, alloc);
 
 	if (alloc == lv->alloc) {
-		log_error("Allocation policy of logical volume \"%s\" is "
+		log_error(0, "Allocation policy of logical volume \"%s\" is "
 			  "already %s", lv->name, get_alloc_string(alloc));
 		return 0;
 	}
@@ -364,7 +364,7 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	if (read_ahead != DM_READ_AHEAD_AUTO &&
 	    (lv->vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
 	    (read_ahead < 2 || read_ahead > 120)) {
-		log_error("Metadata only supports readahead values between 2 and 120.");
+		log_error(0, "Metadata only supports readahead values between 2 and 120.");
 		return 0;
 	}
 
@@ -380,9 +380,9 @@ static int lvchange_readahead(struct cmd_context *cmd,
 
 	if (lv->read_ahead == read_ahead) {
 		if (read_ahead == DM_READ_AHEAD_AUTO)
-			log_error("Read ahead is already auto for \"%s\"", lv->name);
+			log_error(0, "Read ahead is already auto for \"%s\"", lv->name);
 		else
-			log_error("Read ahead is already %u for \"%s\"",
+			log_error(0, "Read ahead is already %u for \"%s\"",
 				  read_ahead, lv->name);
 		return 0;
 	}
@@ -397,7 +397,7 @@ static int lvchange_readahead(struct cmd_context *cmd,
 		return_0;
 
 	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
+		log_error(0, "Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
 		goto out;
 	}
@@ -409,7 +409,7 @@ static int lvchange_readahead(struct cmd_context *cmd,
 
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
+		log_error(0, "Problem reactivating %s", lv->name);
 		goto out;
 	}
 
@@ -427,7 +427,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 
 	if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "n")) {
 		if (!(lv->status & FIXED_MINOR)) {
-			log_error("Minor number is already not persistent "
+			log_error(0, "Minor number is already not persistent "
 				  "for \"%s\"", lv->name);
 			return 0;
 		}
@@ -438,11 +438,11 @@ static int lvchange_persistent(struct cmd_context *cmd,
 			    lv->name);
 	} else {
 		if (!arg_count(cmd, minor_ARG) && lv->minor < 0) {
-			log_error("Minor number must be specified with -My");
+			log_error(0, "Minor number must be specified with -My");
 			return 0;
 		}
 		if (!arg_count(cmd, major_ARG) && lv->major < 0) {
-			log_error("Major number must be specified with -My");
+			log_error(0, "Major number must be specified with -My");
 			return 0;
 		}
 		if (lv_info(cmd, lv, &info, 0, 0) && info.exists)
@@ -461,7 +461,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 
 		log_verbose("Ensuring %s is inactive.", lv->name);
 		if (!deactivate_lv(cmd, lv)) {
-			log_error("%s: deactivation failed", lv->name);
+			log_error(0, "%s: deactivation failed", lv->name);
 			return 0;
 		}
 		lv->status |= FIXED_MINOR;
@@ -481,7 +481,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	if (active) {
 		log_verbose("Re-activating logical volume \"%s\"", lv->name);
 		if (!activate_lv(cmd, lv)) {
-			log_error("%s: reactivation failed", lv->name);
+			log_error(0, "%s: reactivation failed", lv->name);
 			return 0;
 		}
 	}
@@ -495,25 +495,25 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 	const char *tag;
 
 	if (!(tag = arg_str_value(cmd, arg, NULL))) {
-		log_error("Failed to get tag");
+		log_error(0, "Failed to get tag");
 		return 0;
 	}
 
 	if (!(lv->vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Logical volume %s/%s does not support tags",
+		log_error(0, "Logical volume %s/%s does not support tags",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
 	if ((arg == addtag_ARG)) {
 		if (!str_list_add(cmd->mem, &lv->tags, tag)) {
-			log_error("Failed to add tag %s to %s/%s",
+			log_error(0, "Failed to add tag %s to %s/%s",
 				  tag, lv->vg->name, lv->name);
 			return 0;
 		}
 	} else {
 		if (!str_list_del(&lv->tags, tag)) {
-			log_error("Failed to remove tag %s from %s/%s",
+			log_error(0, "Failed to remove tag %s from %s/%s",
 				  tag, lv->vg->name, lv->name);
 			return 0;
 		}
@@ -541,7 +541,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, alloc_ARG))) {
-		log_error("Only -a permitted with read-only volume "
+		log_error(0, "Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
 		return EINVALID_CMD_LINE;
 	}
@@ -550,32 +550,32 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, alloc_ARG))) {
-		log_error("Can't change logical volume \"%s\" under snapshot",
+		log_error(0, "Can't change logical volume \"%s\" under snapshot",
 			  lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
 	    arg_count(cmd, available_ARG)) {
-		log_error("Can't change snapshot logical volume \"%s\"",
+		log_error(0, "Can't change snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv->status & PVMOVE) {
-		log_error("Unable to change pvmove LV %s", lv->name);
+		log_error(0, "Unable to change pvmove LV %s", lv->name);
 		if (arg_count(cmd, available_ARG))
-			log_error("Use 'pvmove --abort' to abandon a pvmove");
+			log_error(0, "Use 'pvmove --abort' to abandon a pvmove");
 		return ECMD_FAILED;
 	}
 
 	if (lv->status & MIRROR_LOG) {
-		log_error("Unable to change mirror log LV %s directly", lv->name);
+		log_error(0, "Unable to change mirror log LV %s directly", lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv->status & MIRROR_IMAGE) {
-		log_error("Unable to change mirror image LV %s directly",
+		log_error(0, "Unable to change mirror image LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
 	}
@@ -586,7 +586,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		lv = origin;
 
 	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
-		log_error("Unable to change internal LV %s directly",
+		log_error(0, "Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
 	}
@@ -690,7 +690,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	    && !arg_count(cmd, deltag_ARG) && !arg_count(cmd, refresh_ARG)
 	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)
 	    && !arg_count(cmd, resync_ARG)) {
-		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
+		log_error(0, "Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag "
 			  "or --monitor");
 		return EINVALID_CMD_LINE;
@@ -701,28 +701,28 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
 	     arg_count(cmd, refresh_ARG) || arg_count(cmd, alloc_ARG))) {
-		log_error("Only -a permitted with --ignorelockingfailure");
+		log_error(0, "Only -a permitted with --ignorelockingfailure");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!argc) {
-		log_error("Please give logical volume path(s)");
+		log_error(0, "Please give logical volume path(s)");
 		return EINVALID_CMD_LINE;
 	}
 
 	if ((arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) &&
 	    !arg_count(cmd, persistent_ARG)) {
-		log_error("--major and --minor require -My");
+		log_error(0, "--major and --minor require -My");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, minor_ARG) && argc != 1) {
-		log_error("Only give one logical volume when specifying minor");
+		log_error(0, "Only give one logical volume when specifying minor");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, contiguous_ARG) && arg_count(cmd, alloc_ARG)) {
-		log_error("Only one of --alloc and --contiguous permitted");
+		log_error(0, "Only one of --alloc and --contiguous permitted");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index dc8aa55..048cb24 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -51,7 +51,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if (lp->snapshot) {
 		if (!*pargc) {
-			log_error("Please specify a logical volume to act as "
+			log_error(0, "Please specify a logical volume to act as "
 				  "the snapshot origin.");
 			return 0;
 		}
@@ -59,7 +59,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		lp->origin = *pargv[0];
 		(*pargv)++, (*pargc)--;
 		if (!(lp->vg_name = extract_vgname(cmd, lp->origin))) {
-			log_error("The origin name should include the "
+			log_error(0, "The origin name should include the "
 				  "volume group.");
 			return 0;
 		}
@@ -70,7 +70,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	}
 
 	if (!*pargc) {
-		log_error("Please provide logical volume path");
+		log_error(0, "Please provide logical volume path");
 		return 0;
 	}
 
@@ -80,7 +80,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if (strchr(lp->lv_name_full, '/') &&
 	    (vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
 	    lp->vg_name && strcmp(vg_name, lp->vg_name)) {
-		log_error("Please use a single volume group name "
+		log_error(0, "Please use a single volume group name "
 			  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);
 		return 0;
 	}
@@ -89,7 +89,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		lp->vg_name = vg_name;
 
 	if (!validate_name(lp->vg_name)) {
-		log_error("Please provide a valid volume group name");
+		log_error(0, "Please provide a valid volume group name");
 		return 0;
 	}
 
@@ -113,7 +113,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, snapshot_ARG) &&
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
 	     arg_count(cmd, repair_ARG))) {
-		log_error("--snapshot argument cannot be mixed "
+		log_error(0, "--snapshot argument cannot be mixed "
 			  "with --mirrors, --repair or --log");
 		return 0;
 	}
@@ -135,18 +135,18 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	if (lp->snapshot) {
 		if (arg_count(cmd, regionsize_ARG)) {
-			log_error("--regionsize is only available with mirrors");
+			log_error(0, "--regionsize is only available with mirrors");
 			return 0;
 		}
 
 		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid");
+			log_error(0, "Negative chunk size is invalid");
 			return 0;
 		}
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
-			log_error("Chunk size must be a power of 2 in the "
+			log_error(0, "Chunk size must be a power of 2 in the "
 				  "range 4K to 512K");
 			return 0;
 		}
@@ -162,13 +162,13 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	} else {	/* Mirrors */
 		if (arg_count(cmd, chunksize_ARG)) {
-			log_error("--chunksize is only available with "
+			log_error(0, "--chunksize is only available with "
 				  "snapshots");
 			return 0;
 		}
 
 		if (arg_count(cmd, zero_ARG)) {
-			log_error("--zero is only available with snapshots");
+			log_error(0, "--zero is only available with snapshots");
 			return 0;
 		}
 
@@ -180,7 +180,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		if (arg_count(cmd, regionsize_ARG)) {
 			if (arg_sign_value(cmd, regionsize_ARG, 0) ==
 				    SIGN_MINUS) {
-				log_error("Negative regionsize is invalid");
+				log_error(0, "Negative regionsize is invalid");
 				return 0;
 			}
 			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
@@ -189,7 +189,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 						"activation/mirror_region_size",
 						DEFAULT_MIRROR_REGION_SIZE);
 			if (region_size < 0) {
-				log_error("Negative regionsize in "
+				log_error(0, "Negative regionsize in "
 					  "configuration file is invalid");
 				return 0;
 			}
@@ -197,7 +197,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		}
 
 		if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-			log_error("Region size (%" PRIu32 ") must be "
+			log_error(0, "Region size (%" PRIu32 ") must be "
 				  "a multiple of machine memory "
 				  "page size (%d)",
 				  lp->region_size, pagesize >> SECTOR_SHIFT);
@@ -205,13 +205,13 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		}
 
 		if (lp->region_size & (lp->region_size - 1)) {
-			log_error("Region size (%" PRIu32
+			log_error(0, "Region size (%" PRIu32
 				  ") must be a power of 2", lp->region_size);
 			return 0;
 		}
 
 		if (!lp->region_size) {
-			log_error("Non-zero region size must be supplied.");
+			log_error(0, "Non-zero region size must be supplied.");
 			return 0;
 		}
 
@@ -221,7 +221,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
-		log_error("%s: Required device-mapper target(s) not "
+		log_error(0, "%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
 	}
@@ -276,7 +276,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	int r = 0;
 
 	if (!collapse_mirrored_lv(lv)) {
-		log_error("Failed to remove temporary sync layer.");
+		log_error(0, "Failed to remove temporary sync layer.");
 		return 0;
 	}
 
@@ -288,7 +288,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 		return_0;
 
 	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
+		log_error(0, "Failed to lock %s", lv->name);
 		vg_revert(vg);
 		goto out;
 	}
@@ -301,7 +301,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
+		log_error(0, "Problem reactivating %s", lv->name);
 		goto out;
 	}
 
@@ -360,23 +360,23 @@ static int _insert_lvconvert_layer(struct cmd_context *cmd,
 	if (!(format = alloca(len)) ||
 	    !(layer_name = alloca(len)) ||
 	    dm_snprintf(format, len, "%s_mimage_%%d", lv->name) < 0) {
-		log_error("lvconvert: layer name allocation failed.");
+		log_error(0, "lvconvert: layer name allocation failed.");
 		return 0;
 	}
 
 	if (!generate_lv_name(lv->vg, format, layer_name, len) ||
 	    sscanf(layer_name, format, &i) != 1) {
-		log_error("lvconvert: layer name generation failed.");
+		log_error(0, "lvconvert: layer name generation failed.");
 		return 0;
 	}
 
 	if (dm_snprintf(layer_name, len, MIRROR_SYNC_LAYER "_%d", i) < 0) {
-		log_error("layer name allocation failed.");
+		log_error(0, "layer name allocation failed.");
 		return 0;
 	}
 
 	if (!insert_layer_for_lv(cmd, lv, 0, layer_name)) {
-		log_error("Failed to insert resync layer");
+		log_error(0, "Failed to insert resync layer");
 		return 0;
 	}
 
@@ -419,7 +419,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 	struct pv_list *pvl, *new_pvl;
 
 	if (!(failed_pvs = dm_pool_alloc(vg->vgmem, sizeof(*failed_pvs)))) {
-		log_error("Allocation of list of failed_pvs failed.");
+		log_error(0, "Allocation of list of failed_pvs failed.");
 		return_NULL;
 	}
 
@@ -430,7 +430,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 			continue;
 
 		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
-			log_error("Allocation of failed_pvs list entry failed.");
+			log_error(0, "Allocation of failed_pvs list entry failed.");
 			return_NULL;
 		}
 		new_pvl->pv = pvl->pv;
@@ -525,7 +525,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	}
 
 	if (arg_count(cmd, mirrors_ARG) && repair) {
-		log_error("You may only use one of --mirrors and --repair.");
+		log_error(0, "You may only use one of --mirrors and --repair.");
 		return 0;
 	}
 
@@ -551,13 +551,13 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		cmd->partial_activation = 1;
 		lp->need_polling = 0;
 		if (!(lv->status & PARTIAL_LV)) {
-			log_error("The mirror is consistent, nothing to repair.");
+			log_error(0, "The mirror is consistent, nothing to repair.");
 			return 0;
 		}
 		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
 			return_0;
 		lp->mirrors -= failed_mirrors;
-		log_error("Mirror status: %d/%d images failed.",
+		log_error(0, "Mirror status: %d/%d images failed.",
 			  failed_mirrors, existing_mirrors);
 		old_pvh = lp->pvh;
 		if (!(lp->pvh = _failed_pv_list(lv->vg)))
@@ -570,7 +570,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		 * Did the user try to subtract more legs than available?
 		 */
 		if (lp->mirrors < 1) {
-			log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+			log_error(0, "Logical volume %s only has %" PRIu32 " mirrors.",
 				  lv->name, existing_mirrors);
 			return 0;
 		}
@@ -585,7 +585,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 					  corelog ? "core" : DEFAULT_MIRRORLOG);
 		if (!strcmp("disk", mirrorlog)) {
 			if (corelog) {
-				log_error("--mirrorlog disk and --corelog "
+				log_error(0, "--mirrorlog disk and --corelog "
 					  "are incompatible");
 				return 0;
 			}
@@ -593,7 +593,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		} else if (!strcmp("core", mirrorlog))
 			corelog = 1;
 		else {
-			log_error("Unknown mirrorlog type: %s", mirrorlog);
+			log_error(0, "Unknown mirrorlog type: %s", mirrorlog);
 			return 0;
 		}
 
@@ -605,7 +605,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	 */
 	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
 	    (lp->region_size != seg->region_size)) {
-		log_error("Mirror log region size cannot be changed on "
+		log_error(0, "Mirror log region size cannot be changed on "
 			  "an existing mirror.");
 		return 0;
 	}
@@ -615,7 +615,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	 * early if we have encountered one.
 	 */
 	if ((lv->status & MIRRORED) && dm_list_size(&lv->segments) != 1) {
-		log_error("Logical volume %s has multiple "
+		log_error(0, "Logical volume %s has multiple "
 			  "mirror segments.", lv->name);
 		return 0;
 	}
@@ -630,7 +630,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	 */
 	if ((lp->mirrors == 1)) {
 		if (!(lv->status & MIRRORED)) {
-			log_error("Logical volume %s is already not mirrored.",
+			log_error(0, "Logical volume %s is already not mirrored.",
 				  lv->name);
 			return 1;
 		}
@@ -657,7 +657,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		/* FIXME Why is this restriction here?  Fix it! */
 		dm_list_iterate_items(seg, &lv->segments) {
 			if (seg_is_striped(seg) && seg->area_count > 1) {
-				log_error("Mirrors of striped volumes are not yet supported.");
+				log_error(0, "Mirrors of striped volumes are not yet supported.");
 				return 0;
 			}
 		}
@@ -679,7 +679,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 			lp->need_polling = 1;
 	} else if (lp->mirrors > existing_mirrors || failed_mirrors) {
 		if (lv->status & MIRROR_NOTSYNCED) {
-			log_error("Can't add mirror to out-of-sync mirrored "
+			log_error(0, "Can't add mirror to out-of-sync mirrored "
 				  "LV: use lvchange --resync first.");
 			return 0;
 		}
@@ -705,7 +705,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
-			log_error("Failed to insert resync layer");
+			log_error(0, "Failed to insert resync layer");
 			return 0;
 		}
 		/* FIXME: can't have multiple mlogs. force corelog. */
@@ -740,7 +740,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 				return_0;
 		} else {
 			/* No change */
-			log_error("Logical volume %s already has %"
+			log_error(0, "Logical volume %s already has %"
 				  PRIu32 " mirror(s).", lv->name,
 				  lp->mirrors - 1);
 			if (lv->status & CONVERTING)
@@ -755,7 +755,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 		return_0;
 
 	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
+		log_error(0, "Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
 		goto out;
 	}
@@ -768,7 +768,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
+		log_error(0, "Problem reactivating %s", lv->name);
 		goto out;
 	}
 
@@ -802,18 +802,18 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	int r = 0;
 
 	if (!(org = find_lv(lv->vg, lp->origin))) {
-		log_error("Couldn't find origin volume '%s'.", lp->origin);
+		log_error(0, "Couldn't find origin volume '%s'.", lp->origin);
 		return 0;
 	}
 
 	if (org == lv) {
-		log_error("Unable to use \"%s\" as both snapshot and origin.",
+		log_error(0, "Unable to use \"%s\" as both snapshot and origin.",
 			  lv->name);
 		return 0;
 	}
 
 	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
-		log_error("Unable to create a snapshot of a %s LV.",
+		log_error(0, "Unable to create a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
 			  org->status & PVMOVE ? "pvmove" :
 			  org->status & MIRRORED ? "mirrored" :
@@ -824,18 +824,18 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	if (!lp->zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
-		log_error("Aborting. Failed to wipe snapshot "
+		log_error(0, "Aborting. Failed to wipe snapshot "
 			  "exception store.");
 		return 0;
 	}
 
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Couldn't deactivate LV %s.", lv->name);
+		log_error(0, "Couldn't deactivate LV %s.", lv->name);
 		return 0;
 	}
 
 	if (!vg_add_snapshot(org, lv, NULL, org->le_count, lp->chunk_size)) {
-		log_error("Couldn't create snapshot.");
+		log_error(0, "Couldn't create snapshot.");
 		return 0;
 	}
 
@@ -844,7 +844,7 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 		return_0;
 
 	if (!suspend_lv(cmd, org)) {
-		log_error("Failed to suspend origin %s", org->name);
+		log_error(0, "Failed to suspend origin %s", org->name);
 		vg_revert(lv->vg);
 		goto out;
 	}
@@ -853,7 +853,7 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 		goto_out;
 
 	if (!resume_lv(cmd, org)) {
-		log_error("Problem reactivating origin %s", org->name);
+		log_error(0, "Problem reactivating origin %s", org->name);
 		goto out;
 	}
 
@@ -870,35 +870,35 @@ static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lvconvert_params *lp = handle;
 
 	if (lv->status & LOCKED) {
-		log_error("Cannot convert locked LV %s", lv->name);
+		log_error(0, "Cannot convert locked LV %s", lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_origin(lv)) {
-		log_error("Can't convert logical volume \"%s\" under snapshot",
+		log_error(0, "Can't convert logical volume \"%s\" under snapshot",
 			  lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_cow(lv)) {
-		log_error("Can't convert snapshot logical volume \"%s\"",
+		log_error(0, "Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv->status & PVMOVE) {
-		log_error("Unable to convert pvmove LV %s", lv->name);
+		log_error(0, "Unable to convert pvmove LV %s", lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (arg_count(cmd, repair_ARG) && !(lv->status & MIRRORED)) {
-		log_error("Can't repair non-mirrored LV \"%s\".", lv->name);
+		log_error(0, "Can't repair non-mirrored LV \"%s\".", lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lp->snapshot) {
 		if (lv->status & MIRRORED) {
-			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
+			log_error(0, "Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;
 		}
 		if (!archive(lv->vg))
@@ -939,7 +939,7 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		goto out;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
-		log_error("Logical volume \"%s\" not found in "
+		log_error(0, "Logical volume \"%s\" not found in "
 			  "volume group \"%s\"", lp.lv_name, lp.vg_name);
 		goto bad;
 	}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 70f237a..e482ae1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -68,7 +68,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 
 	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		if (!argc) {
-			log_err("Please specify a logical volume to act as "
+			log_error(0, "Please specify a logical volume to act as "
 				"the snapshot origin.");
 			return 0;
 		}
@@ -76,7 +76,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		lp->origin = argv[0];
 		(*pargv)++, (*pargc)--;
 		if (!(lp->vg_name = extract_vgname(cmd, lp->origin))) {
-			log_err("The origin name should include the "
+			log_error(0, "The origin name should include the "
 				"volume group.");
 			return 0;
 		}
@@ -92,14 +92,14 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 		 */
 		if (!argc) {
 			if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
-				log_err("Please provide a volume group name");
+				log_error(0, "Please provide a volume group name");
 				return 0;
 			}
 
 		} else {
 			vg_name = skip_dev_dir(cmd, argv[0], NULL);
 			if (strrchr(vg_name, '/')) {
-				log_error("Volume group name expected "
+				log_error(0, "Volume group name expected "
 					  "(no slash)");
 				return 0;
 			}
@@ -114,7 +114,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 					return 0;
 
 				if (strcmp(lp->vg_name, vg_name)) {
-					log_error("Inconsistent volume group "
+					log_error(0, "Inconsistent volume group "
 						  "names "
 						  "given: \"%s\" and \"%s\"",
 						  lp->vg_name, vg_name);
@@ -128,7 +128,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 	}
 
 	if (!validate_name(lp->vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_error(0, "Volume group name %s has invalid characters",
 			  lp->vg_name);
 		return 0;
 	}
@@ -141,7 +141,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 			return_0;
 
 		if (!validate_name(lp->lv_name)) {
-			log_error("Logical volume name \"%s\" is invalid",
+			log_error(0, "Logical volume name \"%s\" is invalid",
 				  lp->lv_name);
 			return 0;
 		}
@@ -154,13 +154,13 @@ static int _read_size_params(struct lvcreate_params *lp,
 			     struct cmd_context *cmd)
 {
 	if (arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) != 1) {
-		log_error("Please specify either size or extents (not both)");
+		log_error(0, "Please specify either size or extents (not both)");
 		return 0;
 	}
 
 	if (arg_count(cmd, extents_ARG)) {
 		if (arg_sign_value(cmd, extents_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative number of extents is invalid");
+			log_error(0, "Negative number of extents is invalid");
 			return 0;
 		}
 		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
@@ -170,7 +170,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, size_ARG)) {
 		if (arg_sign_value(cmd, size_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative size is invalid");
+			log_error(0, "Negative size is invalid");
 			return 0;
 		}
 		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
@@ -180,13 +180,13 @@ static int _read_size_params(struct lvcreate_params *lp,
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, virtualsize_ARG)) {
 		if (arg_sign_value(cmd, virtualsize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative virtual origin size is invalid");
+			log_error(0, "Negative virtual origin size is invalid");
 			return 0;
 		}
 		lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG,
 						   UINT64_C(0));
 		if (!lp->voriginsize) {
-			log_error("Virtual origin size may not be zero");
+			log_error(0, "Virtual origin size may not be zero");
 			return 0;
 		}
 	}
@@ -215,7 +215,7 @@ static int _validate_stripe_params(struct cmd_context *cmd,
 	}
 
 	if (lp->stripes < 1 || lp->stripes > MAX_STRIPES) {
-		log_error("Number of stripes (%d) must be between %d and %d",
+		log_error(0, "Number of stripes (%d) must be between %d and %d",
 			  lp->stripes, 1, MAX_STRIPES);
 		return 0;
 	}
@@ -223,7 +223,7 @@ static int _validate_stripe_params(struct cmd_context *cmd,
 	/* MAX size check is in _lvcreate */
 	if (lp->stripes > 1 && (lp->stripe_size < STRIPE_SIZE_MIN ||
 				lp->stripe_size & (lp->stripe_size - 1))) {
-		log_error("Invalid stripe size %s",
+		log_error(0, "Invalid stripe size %s",
 			  display_size(cmd, (uint64_t) lp->stripe_size));
 		return 0;
 	}
@@ -240,12 +240,12 @@ static int _read_stripe_params(struct lvcreate_params *lp,
 {
 	if (arg_count(cmd, stripesize_ARG)) {
 		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative stripesize is invalid");
+			log_error(0, "Negative stripesize is invalid");
 			return 0;
 		}
 		/* Check to make sure we won't overflow lp->stripe_size */
 		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-			log_error("Stripe size cannot be larger than %s",
+			log_error(0, "Stripe size cannot be larger than %s",
 				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 			return 0;
 		}
@@ -269,20 +269,20 @@ static int _validate_mirror_params(const struct cmd_context *cmd __attribute((un
 	int pagesize = lvm_getpagesize();
 
 	if (lp->region_size & (lp->region_size - 1)) {
-		log_error("Region size (%" PRIu32 ") must be a power of 2",
+		log_error(0, "Region size (%" PRIu32 ") must be a power of 2",
 			  lp->region_size);
 		return 0;
 	}
 
 	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
-		log_error("Region size (%" PRIu32 ") must be a multiple of "
+		log_error(0, "Region size (%" PRIu32 ") must be a multiple of "
 			  "machine memory page size (%d)",
 			  lp->region_size, pagesize >> SECTOR_SHIFT);
 		return 0;
 	}
 
 	if (!lp->region_size) {
-		log_error("Non-zero region size must be supplied.");
+		log_error(0, "Non-zero region size must be supplied.");
 		return 0;
 	}
 
@@ -303,7 +303,7 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 
 	if (!strcmp("disk", mirrorlog)) {
 		if (lp->corelog) {
-			log_error("--mirrorlog disk and --corelog "
+			log_error(0, "--mirrorlog disk and --corelog "
 				  "are incompatible");
 			return 0;
 		}
@@ -311,7 +311,7 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 	} else if (!strcmp("core", mirrorlog))
 		lp->corelog = 1;
 	else {
-		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		log_error(0, "Unknown mirrorlog type: %s", mirrorlog);
 		return 0;
 	}
 
@@ -321,7 +321,7 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 
 	if (arg_count(cmd, regionsize_ARG)) {
 		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative regionsize is invalid");
+			log_error(0, "Negative regionsize is invalid");
 			return 0;
 		}
 		lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
@@ -330,7 +330,7 @@ static int _read_mirror_params(struct lvcreate_params *lp,
 					"activation/mirror_region_size",
 					DEFAULT_MIRROR_REGION_SIZE);
 		if (region_size < 0) {
-			log_error("Negative regionsize in configuration file "
+			log_error(0, "Negative regionsize in configuration file "
 				  "is invalid");
 			return 0;
 		}
@@ -377,24 +377,24 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 		if (lp->mirrors == 1)
 			log_print("Redundant mirrors argument: default is 0");
 		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
+			log_error(0, "Mirrors argument may not be negative");
 			return 0;
 		}
 	}
 
 	if (lp->snapshot) {
 		if (arg_count(cmd, zero_ARG)) {
-			log_error("-Z is incompatible with snapshots");
+			log_error(0, "-Z is incompatible with snapshots");
 			return 0;
 		}
 		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid");
+			log_error(0, "Negative chunk size is invalid");
 			return 0;
 		}
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
-			log_error("Chunk size must be a power of 2 in the "
+			log_error(0, "Chunk size must be a power of 2 in the "
 				  "range 4K to 512K");
 			return 0;
 		}
@@ -404,20 +404,20 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 			return_0;
 	} else {
 		if (arg_count(cmd, chunksize_ARG)) {
-			log_error("-c is only available with snapshots");
+			log_error(0, "-c is only available with snapshots");
 			return 0;
 		}
 	}
 
 	if (lp->mirrors > 1) {
 		if (lp->snapshot) {
-			log_error("mirrors and snapshots are currently "
+			log_error(0, "mirrors and snapshots are currently "
 				  "incompatible");
 			return 0;
 		}
 
 		if (lp->stripes > 1) {
-			log_error("mirrors and stripes are currently "
+			log_error(0, "mirrors and stripes are currently "
 				  "incompatible");
 			return 0;
 		}
@@ -426,19 +426,19 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 			return_0;
 	} else {
 		if (arg_count(cmd, corelog_ARG)) {
-			log_error("--corelog is only available with mirrors");
+			log_error(0, "--corelog is only available with mirrors");
 			return 0;
 		}
 
 		if (arg_count(cmd, nosync_ARG)) {
-			log_error("--nosync is only available with mirrors");
+			log_error(0, "--nosync is only available with mirrors");
 			return 0;
 		}
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
-		log_error("%s: Required device-mapper target(s) not "
+		log_error(0, "%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
 	}
@@ -465,7 +465,7 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 	lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
 
 	if (contiguous && (lp->alloc != ALLOC_CONTIGUOUS)) {
-		log_error("Conflicting contiguous and alloc arguments");
+		log_error(0, "Conflicting contiguous and alloc arguments");
 		return 0;
 	}
 
@@ -504,24 +504,24 @@ static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, persistent_ARG)) {
 		if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
 			if (lp->minor == -1) {
-				log_error("Please specify minor number with "
+				log_error(0, "Please specify minor number with "
 					  "--minor when using -My");
 				return 0;
 			}
 			if (lp->major == -1) {
-				log_error("Please specify major number with "
+				log_error(0, "Please specify major number with "
 					  "--major when using -My");
 				return 0;
 			}
 		} else {
 			if ((lp->minor != -1) || (lp->major != -1)) {
-				log_error("--major and --minor incompatible "
+				log_error(0, "--major and --minor incompatible "
 					  "with -Mn");
 				return 0;
 			}
 		}
 	} else if (arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) {
-		log_error("--major and --minor require -My");
+		log_error(0, "--major and --minor require -My");
 		return 0;
 	}
 
@@ -541,7 +541,7 @@ static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
 	}
 
 	if (size > (uint64_t) UINT32_MAX * extent_size) {
-		log_error("Volume too large (%s) for extent size %s. "
+		log_error(0, "Volume too large (%s) for extent size %s. "
 			  "Upper limit is %s.",
 			  display_size(cmd, size),
 			  display_size(cmd, (uint64_t) extent_size),
@@ -565,14 +565,14 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	struct logical_volume *lv;
 
 	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
-		log_error("Zero segment type for virtual origin not found");
+		log_error(0, "Zero segment type for virtual origin not found");
 		return NULL;
 	}
 
 	len = strlen(lv_name) + 32;
 	if (!(vorigin_name = alloca(len)) ||
 	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
-		log_error("Virtual origin name allocation failed.");
+		log_error(0, "Virtual origin name allocation failed.");
 		return NULL;
 	}
 
@@ -608,19 +608,19 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t pv_extent_count;
 
 	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
-		log_error("Logical volume \"%s\" already exists in "
+		log_error(0, "Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
 		return 0;
 	}
 
 	if (vg_max_lv_reached(vg)) {
-		log_error("Maximum number of logical volumes (%u) reached "
+		log_error(0, "Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
 		return 0;
 	}
 
 	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
-		log_error("Metadata does not support mirroring.");
+		log_error(0, "Metadata does not support mirroring.");
 		return 0;
 	}
 
@@ -628,12 +628,12 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	    lp->read_ahead != DM_READ_AHEAD_NONE &&
 	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
 	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
-		log_error("Metadata only supports readahead values between 2 and 120.");
+		log_error(0, "Metadata only supports readahead values between 2 and 120.");
 		return 0;
 	}
 
 	if (lp->stripe_size > vg->extent_size) {
-		log_error("Reducing requested stripe size %s to maximum, "
+		log_error(0, "Reducing requested stripe size %s to maximum, "
 			  "physical extent size %s",
 			  display_size(cmd, (uint64_t) lp->stripe_size),
 			  display_size(cmd, (uint64_t) vg->extent_size));
@@ -644,7 +644,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	if (lp->stripes > 1 &&
 	    !(vg->fid->fmt->features & FMT_UNLIMITED_STRIPESIZE) &&
 	    (lp->stripe_size > STRIPE_SIZE_MAX)) {
-		log_error("Stripe size may not exceed %s",
+		log_error(0, "Stripe size may not exceed %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_MAX));
 		return 0;
 	}
@@ -677,7 +677,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			break;
 		case PERCENT_PVS:
 			if (!lp->pv_count) {
-				log_error("Please specify physical volume(s) "
+				log_error(0, "Please specify physical volume(s) "
 					  "with %%PVS");
 				return 0;
 			}
@@ -685,7 +685,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			lp->extents = lp->extents * pv_extent_count / 100;
 			break;
 		case PERCENT_LV:
-			log_error("Please express size as %%VG, %%PVS, or "
+			log_error(0, "Please express size as %%VG, %%PVS, or "
 				  "%%FREE.");
 			return 0;
 		case PERCENT_NONE:
@@ -700,7 +700,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (lp->zero && !activation()) {
-		log_error("Can't wipe start of new LV without using "
+		log_error(0, "Can't wipe start of new LV without using "
 			  "device-mapper kernel driver");
 		return 0;
 	}
@@ -709,13 +709,13 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->snapshot) {
 		if (!activation()) {
-			log_error("Can't create snapshot without using "
+			log_error(0, "Can't create snapshot without using "
 				  "device-mapper kernel driver");
 			return 0;
 		}
 		/* FIXME Allow exclusive activation. */
 		if (vg_is_clustered(vg)) {
-			log_error("Clustered snapshots are not yet supported.");
+			log_error(0, "Clustered snapshots are not yet supported.");
 			return 0;
 		}
 
@@ -727,35 +727,35 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		else {
 
 			if (!(org = find_lv(vg, lp->origin))) {
-				log_error("Couldn't find origin volume '%s'.",
+				log_error(0, "Couldn't find origin volume '%s'.",
 					  lp->origin);
 				return 0;
 			}
 			if (lv_is_virtual_origin(org)) {
-				log_error("Can't share virtual origins. "
+				log_error(0, "Can't share virtual origins. "
 					  "Use --virtualsize.");
 				return 0;
 			}
 			if (lv_is_cow(org)) {
-				log_error("Snapshots of snapshots are not "
+				log_error(0, "Snapshots of snapshots are not "
 					  "supported yet.");
 				return 0;
 			}
 			if (org->status & LOCKED) {
-				log_error("Snapshots of locked devices are not "
+				log_error(0, "Snapshots of locked devices are not "
 					  "supported yet");
 				return 0;
 			}
 			if (org->status & MIRROR_IMAGE ||
 			    org->status & MIRROR_LOG ||
 			    org->status & MIRRORED) {
-				log_error("Snapshots and mirrors may not yet "
+				log_error(0, "Snapshots and mirrors may not yet "
 					  "be mixed.");
 				return 0;
 			}
 
 			if (!lv_info(cmd, org, &info, 0, 0)) {
-				log_error("Check for existence of snapshot "
+				log_error(0, "Check for existence of snapshot "
 					  "origin '%s' failed.", org->name);
 				return 0;
 			}
@@ -764,26 +764,26 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!lp->extents) {
-		log_error("Unable to create new logical volume with no extents");
+		log_error(0, "Unable to create new logical volume with no extents");
 		return 0;
 	}
 
 	if (!seg_is_virtual(lp) &&
 	    vg->free_count < lp->extents) {
-		log_error("Insufficient free extents (%u) in volume group %s: "
+		log_error(0, "Insufficient free extents (%u) in volume group %s: "
 			  "%u required", vg->free_count, vg->name, lp->extents);
 		return 0;
 	}
 
 	if (lp->stripes > dm_list_size(pvh) && lp->alloc != ALLOC_ANYWHERE) {
-		log_error("Number of stripes (%u) must not exceed "
+		log_error(0, "Number of stripes (%u) must not exceed "
 			  "number of physical volumes (%d)", lp->stripes,
 			  dm_list_size(pvh));
 		return 0;
 	}
 
 	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
+		log_error(0, "Can't create mirror without using "
 			  "device-mapper kernel driver.");
 		return 0;
 	}
@@ -800,7 +800,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		lv_name = lp->lv_name;
 	else {
 		if (!generate_lv_name(vg, "lvol%d", lv_name_buf, sizeof(lv_name_buf))) {
-			log_error("Failed to generate LV name.");
+			log_error(0, "Failed to generate LV name.");
 			return 0;
 		}
 		lv_name = &lv_name_buf[0];
@@ -808,12 +808,12 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
+			log_error(0, "Failed to get tag");
 			return 0;
 		}
 
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group %s does not support tags",
+			log_error(0, "Volume group %s does not support tags",
 				  vg->name);
 			return 0;
 		}
@@ -847,7 +847,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (tag && !str_list_add(cmd->mem, &lv->tags, tag)) {
-		log_error("Failed to add tag %s to %s/%s",
+		log_error(0, "Failed to add tag %s to %s/%s",
 			  tag, lv->vg->name, lv->name);
 		return 0;
 	}
@@ -878,24 +878,24 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Aborting. Failed to activate snapshot "
+			log_error(0, "Aborting. Failed to activate snapshot "
 				  "exception store.");
 			goto revert_new_lv;
 		}
 	} else if (!activate_lv(cmd, lv)) {
 		if (lp->zero) {
-			log_error("Aborting. Failed to activate new LV to wipe "
+			log_error(0, "Aborting. Failed to activate new LV to wipe "
 				  "the start of it.");
 			goto deactivate_and_revert_new_lv;
 		}
-		log_error("Failed to activate new LV.");
+		log_error(0, "Failed to activate new LV.");
 		return 0;
 	}
 
 	if (!lp->zero && !lp->snapshot)
-		log_error("WARNING: \"%s\" not zeroed", lv->name);
+		log_error(0, "WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
-		log_error("Aborting. Failed to wipe %s.",
+		log_error(0, "Aborting. Failed to wipe %s.",
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
 		goto deactivate_and_revert_new_lv;
@@ -908,7 +908,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* COW area must be deactivated if origin is not active */
 		if (!origin_active && !deactivate_lv(cmd, lv)) {
-			log_error("Aborting. Couldn't deactivate snapshot "
+			log_error(0, "Aborting. Couldn't deactivate snapshot "
 				  "COW area. Manual intervention required.");
 			return 0;
 		}
@@ -919,7 +919,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 						    lp->permission,
 						    lp->voriginextents)) ||
 		     !activate_lv(cmd, org))) {
-			log_error("Couldn't create virtual origin for LV %s",
+			log_error(0, "Couldn't create virtual origin for LV %s",
 				  lv->name);
 			if (org && !lv_remove(org))
 				stack;
@@ -930,7 +930,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 		if (!vg_add_snapshot(org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
-			log_error("Couldn't create snapshot.");
+			log_error(0, "Couldn't create snapshot.");
 			goto deactivate_and_revert_new_lv;
 		}
 
@@ -939,7 +939,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			return_0;
 
 		if (!suspend_lv(cmd, org)) {
-			log_error("Failed to suspend origin %s", org->name);
+			log_error(0, "Failed to suspend origin %s", org->name);
 			vg_revert(vg);
 			return 0;
 		}
@@ -948,7 +948,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			return_0;
 
 		if (!resume_lv(cmd, org)) {
-			log_error("Problem reactivating origin %s", org->name);
+			log_error(0, "Problem reactivating origin %s", org->name);
 			return 0;
 		}
 	}
@@ -966,7 +966,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate failed new LV. "
+		log_error(0, "Unable to deactivate failed new LV. "
 			  "Manual intervention required.");
 		return 0;
 	}
@@ -974,7 +974,7 @@ deactivate_and_revert_new_lv:
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
 	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
-		log_error("Manual intervention may be required to remove "
+		log_error(0, "Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	else
 		backup(vg);
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index f5531cb..d0efe71 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -36,7 +36,7 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (arg_count(cmd, columns_ARG)) {
 		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG)) {
-			log_error("Incompatible options selected");
+			log_error(0, "Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return lvs(cmd, argc, argv);
@@ -45,12 +45,12 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		   arg_count(cmd, options_ARG) ||
 		   arg_count(cmd, separator_ARG) ||
 		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
-		log_error("Incompatible options selected");
+		log_error(0, "Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, colon_ARG) && arg_count(cmd, verbose_ARG)) {
-		log_error("Options -v and -c are incompatible");
+		log_error(0, "Options -v and -c are incompatible");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvm.c b/tools/lvm.c
index e1f7900..1f4b1f8 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -148,7 +148,7 @@ static int _hist_file(char *buffer, size_t size)
 	char *e = getenv("HOME");
 
 	if (dm_snprintf(buffer, size, "%s/.lvm_history", e) < 0) {
-		log_error("$HOME/.lvm_history: path too long");
+		log_error(0, "$HOME/.lvm_history: path too long");
 		return 0;
 	}
 
@@ -213,7 +213,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		argv = args;
 
 		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
-			log_error("Too many arguments, sorry.");
+			log_error(0, "Too many arguments, sorry.");
 			continue;
 		}
 
@@ -227,18 +227,18 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
 			remove_history(history_length - 1);
-			log_error("Exiting.");
+			log_error(0, "Exiting.");
 			break;
 		}
 
 		ret = lvm_run_command(cmd, argc, argv);
 		if (ret == ENO_SUCH_CMD)
-			log_error("No such command '%s'.  Try 'help'.",
+			log_error(0, "No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
                 if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 			log_debug("Internal error: Failed command did not use log_error");
-			log_error("Command failed with status code %d.", ret);
+			log_error(0, "Command failed with status code %d.", ret);
 		}
 		_write_history();
 	}
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 5cde0c4..1815743 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -52,7 +52,7 @@ int lvm2_run(void *handle, const char *cmdline)
 	if (!handle) {
 		oneoff = 1;
 		if (!(handle = lvm2_init())) {
-			log_error("Handle initialisation failed.");
+			log_error(0, "Handle initialisation failed.");
 			return ECMD_FAILED;
 		}
 	}
@@ -62,19 +62,19 @@ int lvm2_run(void *handle, const char *cmdline)
 	cmd->argv = argv;
 
 	if (!(cmdcopy = dm_strdup(cmdline))) {
-		log_error("Cmdline copy failed.");
+		log_error(0, "Cmdline copy failed.");
 		ret = ECMD_FAILED;
 		goto out;
 	}
 
 	if (lvm_split(cmdcopy, &argc, argv, MAX_ARGS) == MAX_ARGS) {
-		log_error("Too many arguments.  Limit is %d.", MAX_ARGS);
+		log_error(0, "Too many arguments.  Limit is %d.", MAX_ARGS);
 		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
 	if (!argc) {
-		log_error("No command supplied");
+		log_error(0, "No command supplied");
 		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 555be8f..210dd49 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -284,7 +284,7 @@ static int _size_arg(struct cmd_context *cmd __attribute((unused)), struct arg *
 			adjustment = v_tmp % 512;
 			if (adjustment) {
 				v_tmp += (512 - adjustment);
-				log_error("Size is not a multiple of 512. "
+				log_error(0, "Size is not a multiple of 512. "
 					  "Try using %"PRIu64" or %"PRIu64".",
 					  v_tmp - 512, v_tmp);
 				return 0;
@@ -375,7 +375,7 @@ int minor_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 		return 0;
 
 	if (a->i_value > 255) {
-		log_error("Minor number outside range 0-255");
+		log_error(0, "Minor number outside range 0-255");
 		return 0;
 	}
 
@@ -390,7 +390,7 @@ int major_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 		return 0;
 
 	if (a->i_value > 255) {
-		log_error("Major number outside range 0-255");
+		log_error(0, "Major number outside range 0-255");
 		return 0;
 	}
 
@@ -582,7 +582,7 @@ static struct command *_find_command(const char *name)
 
 static void _short_usage(const char *name)
 {
-	log_error("Run `%s --help' for more information.", name);
+	log_error(0, "Run `%s --help' for more information.", name);
 }
 
 static int _usage(const char *name)
@@ -694,7 +694,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 		}
 
 		if (a->count && !(a->flags & ARG_REPEATABLE)) {
-			log_error("Option%s%c%s%s may not be repeated",
+			log_error(0, "Option%s%c%s%s may not be repeated",
 				  a->short_arg ? " -" : "",
 				  a->short_arg ? : ' ',
 				  (a->short_arg && a->long_arg) ?
@@ -704,14 +704,14 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 
 		if (a->fn) {
 			if (!optarg) {
-				log_error("Option requires argument.");
+				log_error(0, "Option requires argument.");
 				return 0;
 			}
 
 			a->value = optarg;
 
 			if (!a->fn(cmd, a)) {
-				log_error("Invalid argument %s", optarg);
+				log_error(0, "Invalid argument %s", optarg);
 				return 0;
 			}
 		}
@@ -730,7 +730,7 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 	struct arg *new;
 
 	if (arg_count(cmd, oldarg) && arg_count(cmd, newarg)) {
-		log_error("%s and %s are synonyms.  Please only supply one.",
+		log_error(0, "%s and %s are synonyms.  Please only supply one.",
 			  _cmdline.the_args[oldarg].long_arg, _cmdline.the_args[newarg].long_arg);
 		return 0;
 	}
@@ -815,13 +815,13 @@ static int _get_settings(struct cmd_context *cmd)
 		if (!(cmd->current_settings.unit_factor =
 		      units_to_bytes(arg_str_value(cmd, units_ARG, ""),
 				     &cmd->current_settings.unit_type))) {
-			log_error("Invalid units specification");
+			log_error(0, "Invalid units specification");
 			return EINVALID_CMD_LINE;
 		}
 
 	if (arg_count(cmd, trustcache_ARG)) {
 		if (arg_count(cmd, all_ARG)) {
-			log_error("--trustcache is incompatible with --all");
+			log_error(0, "--trustcache is incompatible with --all");
 			return EINVALID_CMD_LINE;
 		}
 		init_trust_cache(1);
@@ -860,14 +860,14 @@ static void _display_help(void)
 {
 	int i;
 
-	log_error("Available lvm commands:");
-	log_error("Use 'lvm help <command>' for more information");
-	log_error(" ");
+	log_error(0, "Available lvm commands:");
+	log_error(0, "Use 'lvm help <command>' for more information");
+	log_error(0, " ");
 
 	for (i = 0; i < _cmdline.num_commands; i++) {
 		struct command *com = _cmdline.commands + i;
 
-		log_error("%-16.16s%s", com->name, com->desc);
+		log_error(0, "%-16.16s%s", com->name, com->desc);
 	}
 }
 
@@ -890,7 +890,7 @@ int help(struct cmd_context *cmd __attribute((unused)), int argc, char **argv)
 static int _override_settings(struct cmd_context *cmd)
 {
 	if (!(cmd->cft_override = create_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, "")))) {
-		log_error("Failed to set overridden configuration entries.");
+		log_error(0, "Failed to set overridden configuration entries.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -955,7 +955,7 @@ static char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
 	return dm_pool_end_object(cmd->mem);
 
       bad:
-	log_err("Couldn't copy command line.");
+	log_error(0, "Couldn't copy command line.");
 	dm_pool_abandon_object(cmd->mem);
 	return NULL;
 }
@@ -979,7 +979,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return ENO_SUCH_CMD;
 
 	if (!_process_command_line(cmd, &argc, &argv)) {
-		log_error("Error during parsing of command line.");
+		log_error(0, "Error during parsing of command line.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -992,7 +992,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
-			log_error("Updated config file invalid. Aborting.");
+			log_error(0, "Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}
 	}
@@ -1016,7 +1016,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		locking_type = -1;
 
 	if (!init_locking(locking_type, cmd)) {
-		log_error("Locking type %d initialisation failed.",
+		log_error(0, "Locking type %d initialisation failed.",
 			  locking_type);
 		ret = ECMD_FAILED;
 		goto out;
@@ -1227,14 +1227,14 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 		if ((strlen(buffer) == sizeof(buffer) - 1)
 		    && (buffer[sizeof(buffer) - 1] - 2 != '\n')) {
 			buffer[50] = '\0';
-			log_error("Line too long (max 255) beginning: %s",
+			log_error(0, "Line too long (max 255) beginning: %s",
 				  buffer);
 			ret = EINVALID_CMD_LINE;
 			break;
 		}
 		if (lvm_split(buffer, &argc, argv, MAX_ARGS) == MAX_ARGS) {
 			buffer[50] = '\0';
-			log_error("Too many arguments: %s", buffer);
+			log_error(0, "Too many arguments: %s", buffer);
 			ret = EINVALID_CMD_LINE;
 			break;
 		}
@@ -1246,7 +1246,7 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 		if (ret != ECMD_PROCESSED) {
 			if (!error_message_produced()) {
 				log_debug("Internal error: Failed command did not use log_error");
-				log_error("Command failed with status code %d.", ret);
+				log_error(0, "Command failed with status code %d.", ret);
 			}
 			break;
 		}
@@ -1286,7 +1286,7 @@ static void _exec_lvm1_command(char **argv)
 	char path[PATH_MAX];
 
 	if (dm_snprintf(path, sizeof(path), "%s.lvm1", argv[0]) < 0) {
-		log_error("Failed to create LVM1 tool pathname");
+		log_error(0, "Failed to create LVM1 tool pathname");
 		return;
 	}
 
@@ -1335,7 +1335,7 @@ int lvm2_main(int argc, char **argv)
 			alias = 0;
 		}
 		if (!argc) {
-			log_error("Falling back to LVM1 tools, but no "
+			log_error(0, "Falling back to LVM1 tools, but no "
 				  "command specified.");
 			return ECMD_FAILED;
 		}
@@ -1367,11 +1367,11 @@ int lvm2_main(int argc, char **argv)
 	if ((ret == ENO_SUCH_CMD) && (!alias))
 		ret = _run_script(cmd, argc, argv);
 	if (ret == ENO_SUCH_CMD)
-		log_error("No such command.  Try 'help'.");
+		log_error(0, "No such command.  Try 'help'.");
 
 	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 		log_debug("Internal error: Failed command did not use log_error");
-		log_error("Command failed with status code %d.", ret);
+		log_error(0, "Command failed with status code %d.", ret);
 	}
 
       out:
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index c91f5f2..328fc80 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -35,7 +35,7 @@ static int _get_max_dev_name_len(struct dev_filter *filter)
 	struct device *dev;
 
 	if (!(iter = dev_iter_create(filter, 1))) {
-		log_error("dev_iter_create failed");
+		log_error(0, "dev_iter_create failed");
 		return 0;
 	}
 
@@ -80,12 +80,12 @@ static int _check_device(struct cmd_context *cmd, struct device *dev)
 		return 0;
 	}
 	if (!dev_get_size(dev, &size)) {
-		log_error("Couldn't get size of \"%s\"", dev_name(dev));
+		log_error(0, "Couldn't get size of \"%s\"", dev_name(dev));
 	}
 	_print(cmd, dev, size, NULL);
 	_count(dev, &disks_found, &parts_found);
 	if (!dev_close(dev)) {
-		log_error("dev_close on \"%s\" failed", dev_name(dev));
+		log_error(0, "dev_close on \"%s\" failed", dev_name(dev));
 		return 0;
 	}
 	return 1;
@@ -111,7 +111,7 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute((unused)),
 	max_len = _get_max_dev_name_len(cmd->filter);
 
 	if (!(iter = dev_iter_create(cmd->filter, 0))) {
-		log_error("dev_iter_create failed");
+		log_error(0, "dev_iter_create failed");
 		return ECMD_FAILED;
 	}
 
@@ -120,7 +120,7 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute((unused)),
 		/* Try if it is a PV first */
 		if ((label_read(dev, &label, UINT64_C(0)))) {
 			if (!dev_get_size(dev, &size)) {
-				log_error("Couldn't get size of \"%s\"",
+				log_error(0, "Couldn't get size of \"%s\"",
 					  dev_name(dev));
 				continue;
 			}
diff --git a/tools/lvremove.c b/tools/lvremove.c
index be2107a..15299ad 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -35,7 +35,7 @@ static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 int lvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc) {
-		log_error("Please enter one or more logical volume paths");
+		log_error(0, "Please enter one or more logical volume paths");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 7411854..f4725fe 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -39,7 +39,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		if (strchr(lv_name_old, '/') &&
 		    (vg_name_old = extract_vgname(cmd, lv_name_old)) &&
 		    strcmp(vg_name_old, vg_name)) {
-			log_error("Please use a single volume group name "
+			log_error(0, "Please use a single volume group name "
 				  "(\"%s\" or \"%s\")", vg_name, vg_name_old);
 			return EINVALID_CMD_LINE;
 		}
@@ -48,19 +48,19 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		lv_name_new = argv[1];
 		vg_name = extract_vgname(cmd, lv_name_old);
 	} else {
-		log_error("Old and new logical volume names required");
+		log_error(0, "Old and new logical volume names required");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!validate_name(vg_name)) {
-		log_error("Please provide a valid volume group name");
+		log_error(0, "Please provide a valid volume group name");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (strchr(lv_name_new, '/') &&
 	    (vg_name_new = extract_vgname(cmd, lv_name_new)) &&
 	    strcmp(vg_name, vg_name_new)) {
-		log_error("Logical volume names must "
+		log_error(0, "Logical volume names must "
 			  "have the same volume group (\"%s\" or \"%s\")",
 			  vg_name, vg_name_new);
 		return EINVALID_CMD_LINE;
@@ -75,13 +75,13 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	/* Check sanity of new name */
 	maxlen = NAME_LEN - strlen(vg_name) - strlen(cmd->dev_dir) - 3;
 	if (strlen(lv_name_new) > maxlen) {
-		log_error("New logical volume path exceeds maximum length "
+		log_error(0, "New logical volume path exceeds maximum length "
 			  "of %" PRIsize_t "!", maxlen);
 		return ECMD_FAILED;
 	}
 
 	if (!*lv_name_new) {
-		log_error("New logical volume name may not be blank");
+		log_error(0, "New logical volume name may not be blank");
 		return ECMD_FAILED;
 	}
 
@@ -91,13 +91,13 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!validate_name(lv_name_new)) {
-		log_error("New logical volume name \"%s\" is invalid",
+		log_error(0, "New logical volume name \"%s\" is invalid",
 		     lv_name_new);
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!strcmp(lv_name_old, lv_name_new)) {
-		log_error("Old and new logical volume names must differ");
+		log_error(0, "Old and new logical volume names must differ");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -109,7 +109,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
-		log_error("Existing logical volume \"%s\" not found in "
+		log_error(0, "Existing logical volume \"%s\" not found in "
 			  "volume group \"%s\"", lv_name_old, vg_name);
 		goto error;
 	}
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 033078f..2aa14e3 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -51,12 +51,12 @@ static int _validate_stripesize(struct cmd_context *cmd,
 				struct lvresize_params *lp)
 {
 	if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
-		log_error("Stripesize may not be negative.");
+		log_error(0, "Stripesize may not be negative.");
 		return 0;
 	}
 
 	if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-		log_error("Stripe size cannot be larger than %s",
+		log_error(0, "Stripe size cannot be larger than %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
 	}
@@ -64,7 +64,7 @@ static int _validate_stripesize(struct cmd_context *cmd,
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
 	else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size * 2) {
-		log_error("Reducing stripe size %s to maximum, "
+		log_error(0, "Reducing stripe size %s to maximum, "
 			  "physical extent size %s",
 			  display_size(cmd,
 				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0)),
@@ -74,11 +74,11 @@ static int _validate_stripesize(struct cmd_context *cmd,
 		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 
 	if (lp->mirrors) {
-		log_error("Mirrors and striping cannot be combined yet.");
+		log_error(0, "Mirrors and striping cannot be combined yet.");
 		return 0;
 	}
 	if (lp->stripe_size & (lp->stripe_size - 1)) {
-		log_error("Stripe size must be power of 2");
+		log_error(0, "Stripe size must be power of 2");
 		return 0;
 	}
 
@@ -95,13 +95,13 @@ static int _request_confirmation(struct cmd_context *cmd,
 	memset(&info, 0, sizeof(info));
 
 	if (!lv_info(cmd, lv, &info, 1, 0) && driver_version(NULL, 0)) {
-		log_error("lv_info failed: aborting");
+		log_error(0, "lv_info failed: aborting");
 		return 0;
 	}
 
 	if (lp->resizefs) {
 		if (!info.exists) {
-			log_error("Logical volume %s must be activated "
+			log_error(0, "Logical volume %s must be activated "
 				  "before resizing filesystem", lp->lv_name);
 			return 0;
 		}
@@ -163,7 +163,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
 			lp->lv_name) < 0) {
-		log_error("Couldn't create LV path for %s", lp->lv_name);
+		log_error(0, "Couldn't create LV path for %s", lp->lv_name);
 		return 0;
 	}
 
@@ -172,7 +172,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	if (fcmd == FSADM_CMD_RESIZE) {
 		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
 				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
-			log_error("Couldn't generate new LV size string");
+			log_error(0, "Couldn't generate new LV size string");
 			return 0;
 		}
 
@@ -212,7 +212,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->sign = SIGN_PLUS;
 	} else if ((arg_count(cmd, extents_ARG) +
 		    arg_count(cmd, size_ARG) != 1)) {
-		log_error("Please specify either size or extents but not "
+		log_error(0, "Please specify either size or extents but not "
 			  "both.");
 		return 0;
 	}
@@ -231,12 +231,12 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {
-		log_error("Negative argument not permitted - use lvreduce");
+		log_error(0, "Negative argument not permitted - use lvreduce");
 		return 0;
 	}
 
 	if (lp->resize == LV_REDUCE && lp->sign == SIGN_PLUS) {
-		log_error("Positive sign not permitted - use lvextend");
+		log_error(0, "Positive sign not permitted - use lvextend");
 		return 0;
 	}
 
@@ -244,7 +244,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->nofsck = arg_count(cmd, nofsck_ARG) ? 1 : 0;
 
 	if (!argc) {
-		log_error("Please provide the logical volume name");
+		log_error(0, "Please provide the logical volume name");
 		return 0;
 	}
 
@@ -254,12 +254,12 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, &dev_dir_found)) ||
 	    !(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
-		log_error("Please provide a volume group name");
+		log_error(0, "Please provide a volume group name");
 		return 0;
 	}
 
 	if (!validate_name(lp->vg_name)) {
-		log_error("Volume group name %s has invalid characters",
+		log_error(0, "Volume group name %s has invalid characters",
 			  lp->vg_name);
 		return 0;
 	}
@@ -294,7 +294,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
-		log_error("Logical volume %s not found in volume group %s",
+		log_error(0, "Logical volume %s not found in volume group %s",
 			  lp->lv_name, lp->vg_name);
 		return ECMD_FAILED;
 	}
@@ -312,7 +312,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		else
 			log_warn("Mirrors not supported. Ignoring.");
 		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
-			log_error("Mirrors argument may not be negative");
+			log_error(0, "Mirrors argument may not be negative");
 			return EINVALID_CMD_LINE;
 		}
 	}
@@ -324,12 +324,12 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	lv = lvl->lv;
 
 	if (lv->status & LOCKED) {
-		log_error("Can't resize locked LV %s", lv->name);
+		log_error(0, "Can't resize locked LV %s", lv->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv->status & CONVERTING) {
-		log_error("Can't resize %s while lvconvert in progress", lv->name);
+		log_error(0, "Can't resize %s while lvconvert in progress", lv->name);
 		return ECMD_FAILED;
 	}
 
@@ -379,7 +379,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->sign == SIGN_MINUS) {
 		if (lp->extents >= lv->le_count) {
-			log_error("Unable to reduce %s below 1 extent",
+			log_error(0, "Unable to reduce %s below 1 extent",
 				  lp->lv_name);
 			return EINVALID_CMD_LINE;
 		}
@@ -388,13 +388,13 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!lp->extents) {
-		log_error("New size of 0 not permitted");
+		log_error(0, "New size of 0 not permitted");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (lp->extents == lv->le_count) {
 		if (!lp->resizefs) {
-			log_error("New size (%d extents) matches existing size "
+			log_error(0, "New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, lv->le_count);
 			return EINVALID_CMD_LINE;
 		}
@@ -410,7 +410,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* FIXME Support LVs with mixed segment types */
 	if (lp->segtype != arg_ptr_value(cmd, type_ARG, lp->segtype)) {
-		log_error("VolumeType does not match (%s)", lp->segtype->name);
+		log_error(0, "VolumeType does not match (%s)", lp->segtype->name);
 		return EINVALID_CMD_LINE;
 	}
 
@@ -427,7 +427,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			if ((seg_stripesize && seg_stripesize != sz &&
 			     !lp->stripe_size) ||
 			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
-				log_error("Please specify number of "
+				log_error(0, "Please specify number of "
 					  "stripes (-i) and stripesize (-I)");
 				return EINVALID_CMD_LINE;
 			}
@@ -471,7 +471,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
 		    (lp->mirrors != seg_mirrors)) {
-			log_error("Cannot vary number of mirrors in LV yet.");
+			log_error(0, "Cannot vary number of mirrors in LV yet.");
 			return EINVALID_CMD_LINE;
 		}
 	}
@@ -481,7 +481,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		extents_used = 0;
 
 		if (lp->stripes || lp->stripe_size || lp->mirrors)
-			log_error("Ignoring stripes, stripesize and mirrors "
+			log_error(0, "Ignoring stripes, stripesize and mirrors "
 				  "arguments when reducing");
 
 		dm_list_iterate_items(seg, &lv->segments) {
@@ -510,7 +510,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (lp->stripes > 1 && !lp->stripe_size) {
-		log_error("Stripesize for striped segment should not be 0!");
+		log_error(0, "Stripesize for striped segment should not be 0!");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -526,7 +526,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
-			log_error("Invalid stripe size %s",
+			log_error(0, "Invalid stripe size %s",
 				  display_size(cmd, (uint64_t) lp->stripe_size));
 			return EINVALID_CMD_LINE;
 		}
@@ -534,7 +534,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lp->extents < lv->le_count) {
 		if (lp->resize == LV_EXTEND) {
-			log_error("New size given (%d extents) not larger "
+			log_error(0, "New size given (%d extents) not larger "
 				  "than existing size (%d extents)",
 				  lp->extents, lv->le_count);
 			return EINVALID_CMD_LINE;
@@ -542,7 +542,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		lp->resize = LV_REDUCE;
 	} else if (lp->extents > lv->le_count) {
 		if (lp->resize == LV_REDUCE) {
-			log_error("New size given (%d extents) not less than "
+			log_error(0, "New size given (%d extents) not less than "
 				  "existing size (%d extents)", lp->extents,
 				  lv->le_count);
 			return EINVALID_CMD_LINE;
@@ -552,7 +552,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
-			log_error("Snapshot origin volumes cannot be reduced "
+			log_error(0, "Snapshot origin volumes cannot be reduced "
 				  "in size yet.");
 			return ECMD_FAILED;
 		}
@@ -560,7 +560,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		memset(&info, 0, sizeof(info));
 
 		if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-			log_error("Snapshot origin volumes can be resized "
+			log_error(0, "Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
 			return ECMD_FAILED;
 		}
@@ -627,7 +627,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		lock_lv = lv;
 
 	if (!suspend_lv(cmd, lock_lv)) {
-		log_error("Failed to suspend %s", lp->lv_name);
+		log_error(0, "Failed to suspend %s", lp->lv_name);
 		vg_revert(vg);
 		backup(vg);
 		return ECMD_FAILED;
@@ -641,7 +641,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!resume_lv(cmd, lock_lv)) {
-		log_error("Problem reactivating %s", lp->lv_name);
+		log_error(0, "Problem reactivating %s", lp->lv_name);
 		backup(vg);
 		return ECMD_FAILED;
 	}
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 21bf01c..e47c282 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -76,7 +76,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (argc) {
-		log_error("No additional command line arguments allowed");
+		log_error(0, "No additional command line arguments allowed");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 4dcbc22..2429548 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -36,7 +36,7 @@ static int _become_daemon(struct cmd_context *cmd)
 	sigaction(SIGCHLD, &act, NULL);
 
 	if ((pid = fork()) == -1) {
-		log_error("fork failed: %s", strerror(errno));
+		log_error(0, "fork failed: %s", strerror(errno));
 		return 1;
 	}
 
@@ -46,7 +46,7 @@ static int _become_daemon(struct cmd_context *cmd)
 
 	/* Child */
 	if (setsid() == -1)
-		log_error("Background process failed to setsid: %s",
+		log_error(0, "Background process failed to setsid: %s",
 			  strerror(errno));
 	init_verbose(VERBOSE_BASE_LEVEL);
 
@@ -78,7 +78,7 @@ static int _check_mirror_status(struct cmd_context *cmd,
 
 	if (parms->aborting) {
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-			log_error("Failed to generate list of copied LVs: "
+			log_error(0, "Failed to generate list of copied LVs: "
 				  "can't abort.");
 			return 0;
 		}
@@ -88,7 +88,7 @@ static int _check_mirror_status(struct cmd_context *cmd,
 
 	if (!lv_mirror_percent(cmd, lv_mirr, !parms->interval, &segment_percent,
 			       &event_nr)) {
-		log_error("ABORTING: Mirror percentage check failed.");
+		log_error(0, "ABORTING: Mirror percentage check failed.");
 		return 0;
 	}
 
@@ -107,7 +107,7 @@ static int _check_mirror_status(struct cmd_context *cmd,
 	}
 
 	if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-		log_error("ABORTING: Failed to generate list of copied LVs");
+		log_error(0, "ABORTING: Failed to generate list of copied LVs");
 		return 0;
 	}
 
@@ -119,7 +119,7 @@ static int _check_mirror_status(struct cmd_context *cmd,
 	} else {
 		if (!parms->poll_fns->update_metadata(cmd, vg, lv_mirr,
 						      lvs_changed, 0)) {
-			log_error("ABORTING: Segment progression failed.");
+			log_error(0, "ABORTING: Segment progression failed.");
 			parms->poll_fns->finish_copy(cmd, vg, lv_mirr,
 						     lvs_changed);
 			return 0;
@@ -151,14 +151,14 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, co
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
 			vg_release(vg);
-			log_error("ABORTING: Can't reread VG for %s", name);
+			log_error(0, "ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
 		}
 
 		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
 							     parms->lv_type))) {
-			log_error("ABORTING: Can't find mirror LV in %s for %s",
+			log_error(0, "ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index def78cc..ef37175 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -47,7 +47,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
 				      "y");
 	else if (tagarg && !(tag = arg_str_value(cmd, tagarg, NULL))) {
-		log_error("Failed to get tag");
+		log_error(0, "Failed to get tag");
 		return 0;
 	}
 
@@ -64,17 +64,17 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
+			log_error(0, "Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
 			goto out;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group containing %s does not "
+			log_error(0, "Volume group containing %s does not "
 				  "support tags", pv_name);
 			goto out;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
-			log_error("Volume group containing %s has active "
+			log_error(0, "Volume group containing %s has active "
 				  "logical volumes", pv_name);
 			goto out;
 		}
@@ -83,7 +83,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 			goto out;
 	} else {
 		if (tagarg) {
-			log_error("Can't change tag on Physical Volume %s not "
+			log_error(0, "Can't change tag on Physical Volume %s not "
 				  "in volume group", pv_name);
 			return 0;
 		}
@@ -91,13 +91,13 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		vg_name = VG_ORPHANS;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
+			log_error(0, "Can't get lock for orphans");
 			return 0;
 		}
 
 		if (!(pv = pv_read(cmd, pv_name, NULL, &sector, 1, 0))) {
 			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
+			log_error(0, "Unable to read PV \"%s\"", pv_name);
 			return 0;
 		}
 	}
@@ -105,21 +105,21 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	if (arg_count(cmd, allocatable_ARG)) {
 		if (is_orphan(pv) &&
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
-			log_error("Allocatability not supported by orphan "
+			log_error(0, "Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
 			goto out;
 		}
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
-			log_error("Physical volume \"%s\" is already "
+			log_error(0, "Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
 			r = 1;
 			goto out;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
-			log_error("Physical volume \"%s\" is already "
+			log_error(0, "Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
 			r = 1;
 			goto out;
@@ -138,13 +138,13 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		/* tag or deltag */
 		if ((tagarg == addtag_ARG)) {
 			if (!str_list_add(cmd->mem, &pv->tags, tag)) {
-				log_error("Failed to add tag %s to physical "
+				log_error(0, "Failed to add tag %s to physical "
 					  "volume %s", tag, pv_name);
 				goto out;
 			}
 		} else {
 			if (!str_list_del(&pv->tags, tag)) {
-				log_error("Failed to remove tag %s from "
+				log_error(0, "Failed to remove tag %s from "
 					  "physical volume" "%s", tag, pv_name);
 				goto out;
 			}
@@ -152,7 +152,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
-			log_error("Failed to generate new random UUID for %s.",
+			log_error(0, "Failed to generate new random UUID for %s.",
 				  pv_name);
 			goto out;
 		}
@@ -171,7 +171,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-				log_error("pv_write with new uuid failed "
+				log_error(0, "pv_write with new uuid failed "
 					  "for %s.", pv_name);
 				goto out;
 			}
@@ -187,13 +187,13 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (!is_orphan(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to store physical volume \"%s\" in "
+			log_error(0, "Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			goto out;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-		log_error("Failed to store physical volume \"%s\"",
+		log_error(0, "Failed to store physical volume \"%s\"",
 			  pv_name);
 		goto out;
 	}
@@ -221,18 +221,18 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
 	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
-		log_error("Please give exactly one option of -x, -uuid, "
+		log_error(0, "Please give exactly one option of -x, -uuid, "
 			  "--addtag or --deltag");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!(arg_count(cmd, all_ARG)) && !argc) {
-		log_error("Please give a physical volume path");
+		log_error(0, "Please give a physical volume path");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, all_ARG) && argc) {
-		log_error("Option a and PhysicalVolumePath are exclusive");
+		log_error(0, "Option a and PhysicalVolumePath are exclusive");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -242,7 +242,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			pv_name = argv[opt];
 			dm_list_init(&mdas);
 			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
-				log_error("Failed to read physical volume %s",
+				log_error(0, "Failed to read physical volume %s",
 					  pv_name);
 				continue;
 			}
@@ -255,13 +255,13 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			 */
 			if (is_orphan(pv) && !dm_list_size(&mdas)) {
 				if (!scan_vgs_for_pvs(cmd)) {
-					log_error("Rescan for PVs without "
+					log_error(0, "Rescan for PVs without "
 						  "metadata areas failed.");
 					continue;
 				}
 				if (!(pv = pv_read(cmd, pv_name,
 						   NULL, NULL, 1, 0))) {
-					log_error("Failed to read "
+					log_error(0, "Failed to read "
 						  "physical volume %s",
 						  pv_name);
 					continue;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 0f71df5..ede77a2 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -68,7 +68,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
 	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
-		log_error("Can't initialize physical volume \"%s\" of "
+		log_error(0, "Can't initialize physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
 		return 0;
 	}
@@ -94,7 +94,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 		init_md_filtering(0);
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphan PVs");
+			log_error(0, "Can't get lock for orphan PVs");
 			init_md_filtering(1);
 			return 0;
 		}
@@ -103,7 +103,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	}
 
 	if (!dev) {
-		log_error("Device %s not found (or ignored by filtering).", name);
+		log_error(0, "Device %s not found (or ignored by filtering).", name);
 		return 0;
 	}
 
@@ -112,7 +112,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 */
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
+		log_error(0, "Can't open %s exclusively.  Mounted filesystem?",
 			  name);
 		return 0;
 	}
@@ -124,14 +124,14 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
 		log_print("Wiping software RAID md superblock on %s", name);
 		if (!dev_set(dev, md_superblock, 4, 0)) {
-			log_error("Failed to wipe RAID md superblock on %s",
+			log_error(0, "Failed to wipe RAID md superblock on %s",
 				  name);
 			return 0;
 		}
 	}
 
 	if (wipe_md == -1) {
-		log_error("Fatal error while trying to detect software "
+		log_error(0, "Fatal error while trying to detect software "
 			  "RAID md superblock on %s", name);
 		return 0;
 	}
@@ -142,13 +142,13 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 			    name) == 'y'))) {
 		log_print("Wiping swap signature on %s", name);
 		if (!dev_set(dev, swap_signature, 10, 0)) {
-			log_error("Failed to wipe swap signature on %s", name);
+			log_error(0, "Failed to wipe swap signature on %s", name);
 			return 0;
 		}
 	}
 
 	if (wipe_swap == -1) {
-		log_error("Fatal error while trying to detect swap "
+		log_error(0, "Fatal error while trying to detect swap "
 			  "signature on %s", name);
 		return 0;
 	}
@@ -178,14 +178,14 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
-			log_error("uuid %s already in use on \"%s\"",
+			log_error(0, "uuid %s already in use on \"%s\"",
 				  pp->idp->uuid, dev_name(dev));
 			return 0;
 		}
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return 0;
 	}
 
@@ -196,7 +196,7 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		goto error;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("%s: Couldn't find device.  Check your filters?",
+		log_error(0, "%s: Couldn't find device.  Check your filters?",
 			  pv_name);
 		goto error;
 	}
@@ -207,7 +207,7 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 			     pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
-		log_error("Failed to setup physical volume \"%s\"", pv_name);
+		log_error(0, "Failed to setup physical volume \"%s\"", pv_name);
 		goto error;
 	}
 
@@ -216,19 +216,19 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 
 	/* Wipe existing label first */
 	if (!label_remove(pv_dev(pv))) {
-		log_error("Failed to wipe existing label on %s", pv_name);
+		log_error(0, "Failed to wipe existing label on %s", pv_name);
 		goto error;
 	}
 
 	if (pp->zero) {
 		log_verbose("Zeroing start of device %s", pv_name);
 		if (!dev_open_quiet(dev)) {
-			log_error("%s not opened: device not zeroed", pv_name);
+			log_error(0, "%s not opened: device not zeroed", pv_name);
 			goto error;
 		}
 
 		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
-			log_error("%s not wiped: aborting", pv_name);
+			log_error(0, "%s not wiped: aborting", pv_name);
 			dev_close(dev);
 			goto error;
 		}
@@ -239,7 +239,7 @@ static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 			 pv_name);
 	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
 		       pp->labelsector))) {
-		log_error("Failed to write physical volume \"%s\"", pv_name);
+		log_error(0, "Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}
 
@@ -273,17 +273,17 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	memset(pp, 0, sizeof(*pp));
 
 	if (!argc) {
-		log_error("Please enter a physical volume path");
+		log_error(0, "Please enter a physical volume path");
 		return 0;
 	}
 
 	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
-		log_error("--uuid is required with --restorefile");
+		log_error(0, "--uuid is required with --restorefile");
 		return 0;
 	}
 
 	if (arg_count(cmd, uuidstr_ARG) && argc != 1) {
-		log_error("Can only set uuid on one volume at once");
+		log_error(0, "Can only set uuid on one volume at once");
 		return 0;
 	}
 
@@ -298,12 +298,12 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 		pp->restorefile = arg_str_value(cmd, restorefile_ARG, "");
 		/* The uuid won't already exist */
 		if (!(vg = backup_read_vg(cmd, NULL, pp->restorefile))) {
-			log_error("Unable to read volume group from %s",
+			log_error(0, "Unable to read volume group from %s",
 				  pp->restorefile);
 			return 0;
 		}
 		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp))) {
-			log_error("Can't find uuid %s in backup file %s",
+			log_error(0, "Can't find uuid %s in backup file %s",
 				  uuid, pp->restorefile);
 			return 0;
 		}
@@ -314,7 +314,7 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	}
 
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
+		log_error(0, "Option y can only be given with option f");
 		return 0;
 	}
 
@@ -322,7 +322,7 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	pp->force = arg_count(cmd, force_ARG);
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu",
+		log_error(0, "labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);
 		return 0;
 	} else {
@@ -334,14 +334,14 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	    (arg_count(cmd, metadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG)   ||
 	     arg_count(cmd, dataalignment_ARG))) {
-		log_error("Metadata and data alignment parameters only "
+		log_error(0, "Metadata and data alignment parameters only "
 			  "apply to text format.");
 		return 0;
 	}
 
 	if (arg_count(cmd, metadatacopies_ARG) &&
 	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
+		log_error(0, "Metadatacopies may only be 0, 1 or 2");
 		return 0;
 	}
 
@@ -353,19 +353,19 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 		pp->zero = 1;
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume size may not be negative");
+		log_error(0, "Physical volume size may not be negative");
 		return 0;
 	}
 	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
 	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume data alignment may not be negative");
+		log_error(0, "Physical volume data alignment may not be negative");
 		return 0;
 	}
 	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
 
 	if (pp->data_alignment > ULONG_MAX) {
-		log_error("Physical volume data alignment is too big.");
+		log_error(0, "Physical volume data alignment is too big.");
 		return 0;
 	}
 
@@ -378,7 +378,7 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 	}
 
 	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative");
+		log_error(0, "Metadata size may not be negative");
 		return 0;
 	}
 
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index c8c4a88..2c24a2d 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -31,7 +31,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		vg_name = pv_vg_name(pv);
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
-		 	log_error("Skipping volume group %s", vg_name);
+		 	log_error(0, "Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
 	 	}
@@ -41,7 +41,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		 * allocated in vg_read_internal() path.
 		 */
 		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			 log_error("Unable to find \"%s\" in volume group \"%s\"",
+			 log_error(0, "Unable to find \"%s\" in volume group \"%s\"",
 				   pv_name, vg->name);
 			 ret = ECMD_FAILED;
 			 goto out;
@@ -94,7 +94,7 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, columns_ARG)) {
 		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG) ||
 		    arg_count(cmd, short_ARG)) {
-			log_error("Incompatible options selected");
+			log_error(0, "Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return pvs(cmd, argc, argv);
@@ -104,12 +104,12 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		   arg_count(cmd, options_ARG) ||
 		   arg_count(cmd, separator_ARG) ||
 		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
-		log_error("Incompatible options selected");
+		log_error(0, "Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, colon_ARG) && arg_count(cmd, maps_ARG)) {
-		log_error("Option -v not allowed with option -c");
+		log_error(0, "Option -v not allowed with option -c");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 2490863..f2ee8e1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -70,18 +70,18 @@ static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 	while (*lvname == '/')
 		lvname++;
 	if (!strchr(lvname, '/')) {
-		log_error("--name takes a logical volume name");
+		log_error(0, "--name takes a logical volume name");
 		return NULL;
 	}
 	if (strncmp(vgname, lvname, strlen(vgname)) ||
 	    (lvname += strlen(vgname), *lvname != '/')) {
-		log_error("Named LV and old PV must be in the same VG");
+		log_error(0, "Named LV and old PV must be in the same VG");
 		return NULL;
 	}
 	while (*lvname == '/')
 		lvname++;
 	if (!*lvname) {
-		log_error("Incomplete LV name supplied with --name");
+		log_error(0, "Incomplete LV name supplied with --name");
 		return NULL;
 	}
 	return lvname;
@@ -126,7 +126,7 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 	}
 
 	if (dm_list_empty(allocatable_pvs)) {
-		log_error("No extents available for allocation");
+		log_error(0, "No extents available for allocation");
 		return NULL;
 	}
 
@@ -185,14 +185,14 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
 					ALLOC_CONTIGUOUS, vg))) {
-		log_error("Creation of temporary pvmove LV failed");
+		log_error(0, "Creation of temporary pvmove LV failed");
 		return NULL;
 	}
 
 	lv_mirr->status |= (PVMOVE | LOCKED);
 
 	if (!(*lvs_changed = dm_pool_alloc(cmd->mem, sizeof(**lvs_changed)))) {
-		log_error("lvs_changed list struct allocation failed");
+		log_error(0, "lvs_changed list struct allocation failed");
 		return NULL;
 	}
 
@@ -234,24 +234,24 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	}
 
 	if (lv_name && !lv_found) {
-		log_error("Logical volume %s not found.", lv_name);
+		log_error(0, "Logical volume %s not found.", lv_name);
 		return NULL;
 	}
 
 	/* Is temporary mirror empty? */
 	if (!lv_mirr->le_count) {
-		log_error("No data to move for %s", vg->name);
+		log_error(0, "No data to move for %s", vg->name);
 		return NULL;
 	}
 
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, log_count,
 			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
-		log_error("Failed to convert pvmove LV to mirrored");
+		log_error(0, "Failed to convert pvmove LV to mirrored");
 		return_NULL;
 	}
 
 	if (!split_parent_segments_for_layer(cmd, lv_mirr)) {
-		log_error("Failed to split segments being moved");
+		log_error(0, "Failed to split segments being moved");
 		return_NULL;
 	}
 
@@ -281,7 +281,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 
 	log_verbose("Updating volume group metadata");
 	if (!vg_write(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
+		log_error(0, "ABORTING: Volume group metadata update failed.");
 		return 0;
 	}
 
@@ -300,7 +300,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
+		log_error(0, "ABORTING: Volume group metadata update failed.");
 		if (!first_time)
 			resume_lv(cmd, lv_mirr);
 		resume_lvs(cmd, lvs_changed);
@@ -318,14 +318,14 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			/*
 			 * Nothing changed yet, try to revert pvmove.
 			 */
-			log_error("Temporary pvmove mirror activation failed.");
+			log_error(0, "Temporary pvmove mirror activation failed.");
 			if (!_finish_pvmove(cmd, vg, lv_mirr, lvs_changed))
-				log_error("ABORTING: Restoring original configuration "
+				log_error(0, "ABORTING: Restoring original configuration "
 					  "before pvmove failed. Run pvmove --abort.");
 			goto out;
 		}
 	} else if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
+		log_error(0, "Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
 		resume_lvs(cmd, lvs_changed);
 		goto out;
@@ -333,7 +333,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Unsuspend LVs */
 	if (!resume_lvs(cmd, lvs_changed)) {
-		log_error("Unable to resume logical volumes");
+		log_error(0, "Unable to resume logical volumes");
 		goto out;
 	}
 
@@ -377,7 +377,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		}
 
 		if (!validate_name(lv_name)) {
-			log_error("Logical volume name %s is invalid", lv_name);
+			log_error(0, "Logical volume name %s is invalid", lv_name);
 			return EINVALID_CMD_LINE;
 		}
 	}
@@ -397,16 +397,16 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print("Detected pvmove in progress for %s", pv_name);
 		if (argc || lv_name)
-			log_error("Ignoring remaining command line arguments");
+			log_error(0, "Ignoring remaining command line arguments");
 
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-			log_error("ABORTING: Failed to generate list of moving LVs");
+			log_error(0, "ABORTING: Failed to generate list of moving LVs");
 			goto out;
 		}
 
 		/* Ensure mirror LV is active */
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			log_error("ABORTING: Temporary mirror activation failed.");
+			log_error(0, "ABORTING: Temporary mirror activation failed.");
 			goto out;
 		}
 
@@ -469,7 +469,7 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
-		log_error("ABORTING: Removal of temporary mirror failed");
+		log_error(0, "ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
 
@@ -479,26 +479,26 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_write(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
+		log_error(0, "ABORTING: Failed to write new data locations "
 			  "to disk.");
 		return 0;
 	}
 
 	/* Suspend LVs changed */
 	if (!suspend_lvs(cmd, lvs_changed)) {
-		log_error("Locking LVs to remove temporary mirror failed");
+		log_error(0, "Locking LVs to remove temporary mirror failed");
 		r = 0;
 	}
 
 	/* Suspend mirror LV to flush pending I/O */
 	if (!suspend_lv(cmd, lv_mirr)) {
-		log_error("Suspension of temporary mirror LV failed");
+		log_error(0, "Suspension of temporary mirror LV failed");
 		r = 0;
 	}
 
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_commit(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
+		log_error(0, "ABORTING: Failed to write new data locations "
 			  "to disk.");
 		vg_revert(vg);
 		resume_lv(cmd, lv_mirr);
@@ -508,7 +508,7 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Release mirror LV.  (No pending I/O because it's been suspended.) */
 	if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
+		log_error(0, "Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
 		r = 0;
 	}
@@ -518,21 +518,21 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
-		log_error("ABORTING: Unable to deactivate temporary logical "
+		log_error(0, "ABORTING: Unable to deactivate temporary logical "
 			  "volume \"%s\"", lv_mirr->name);
 		r = 0;
 	}
 
 	log_verbose("Removing temporary pvmove LV");
 	if (!lv_remove(lv_mirr)) {
-		log_error("ABORTING: Removal of temporary pvmove LV failed");
+		log_error(0, "ABORTING: Removal of temporary pvmove LV failed");
 		return 0;
 	}
 
 	/* Store it on disks */
 	log_verbose("Writing out final volume group after pvmove");
 	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
+		log_error(0, "ABORTING: Failed to write new data locations "
 			  "to disk.");
 		return 0;
 	}
@@ -550,7 +550,7 @@ static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 
 	/* Reread all metadata in case it got changed */
 	if (!(pv = find_pv_by_name(cmd, name))) {
-		log_error("ABORTING: Can't reread PV %s", name);
+		log_error(0, "ABORTING: Can't reread PV %s", name);
 		/* What more could we do here? */
 		return NULL;
 	}
@@ -581,7 +581,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 
 	/* dm raid1 target must be present in every case */
 	if (!_pvmove_target_present(cmd, 0)) {
-		log_error("Required device-mapper target(s) not "
+		log_error(0, "Required device-mapper target(s) not "
 			  "detected in your kernel");
 		return ECMD_FAILED;
 	}
@@ -594,7 +594,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 			if (!(pv_name = dm_pool_strndup(cmd->mem, pv_name,
 						     (unsigned) (colon -
 								 pv_name)))) {
-				log_error("Failed to clone PV name");
+				log_error(0, "Failed to clone PV name");
 				return ECMD_FAILED;
 			}
 		}
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 3d75480..172901d 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -36,7 +36,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 	if (!(pv = pv_read(cmd, name, &mdas, NULL, 1, 0))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
-		log_error("Physical Volume %s not found", name);
+		log_error(0, "Physical Volume %s not found", name);
 		return 0;
 	}
 
@@ -49,12 +49,12 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 	 */
 	if (is_orphan(pv) && !dm_list_size(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd)) {
-			log_error("Rescan for PVs without metadata areas "
+			log_error(0, "Rescan for PVs without metadata areas "
 				  "failed.");
 			return 0;
 		}
 		if (!(pv = pv_read(cmd, name, NULL, NULL, 1, 0))) {
-			log_error("Failed to read physical volume %s", name);
+			log_error(0, "Failed to read physical volume %s", name);
 			return 0;
 		}
 	}
@@ -66,7 +66,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 	/* Allow partial & exported VGs to be destroyed. */
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
-		log_error("Can't pvremove physical volume \"%s\" of "
+		log_error(0, "Can't pvremove physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
 		return 0;
 	}
@@ -96,7 +96,7 @@ static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	int ret = ECMD_FAILED;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
@@ -104,21 +104,21 @@ static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto error;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("%s: Couldn't find device.  Check your filters?",
+		log_error(0, "%s: Couldn't find device.  Check your filters?",
 			  pv_name);
 		goto error;
 	}
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */
-		log_error("Can't open %s exclusively - not removing. "
+		log_error(0, "Can't open %s exclusively - not removing. "
 			  "Mounted filesystem?", dev_name(dev));
 		goto error;
 	}
 
 	/* Wipe existing label(s) */
 	if (!label_remove(dev)) {
-		log_error("Failed to wipe existing label(s) on %s", pv_name);
+		log_error(0, "Failed to wipe existing label(s) on %s", pv_name);
 		goto error;
 	}
 
@@ -139,12 +139,12 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 	int ret = ECMD_PROCESSED;
 
 	if (!argc) {
-		log_error("Please enter a physical volume path");
+		log_error(0, "Please enter a physical volume path");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
+		log_error(0, "Option y can only be given with option f");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 964d6a5..60788e1 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -44,13 +44,13 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	if (is_orphan_vg(pv_vg_name(pv))) {
 		vg_name = VG_ORPHANS;
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
+			log_error(0, "Can't get lock for orphans");
 			return 0;
 		}
 
 		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
 			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
+			log_error(0, "Unable to read PV \"%s\"", pv_name);
 			return 0;
 		}
 
@@ -64,7 +64,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
+			log_error(0, "Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
 			goto bad;
 		}
@@ -72,7 +72,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		pv = pvl->pv;
 
 		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
-			log_error("Can't get info for PV %s in volume group %s",
+			log_error(0, "Can't get info for PV %s in volume group %s",
 				  pv_name, vg->name);
 			goto bad;
 		}
@@ -85,19 +85,19 @@ static int _pv_resize_single(struct cmd_context *cmd,
 
 	/* FIXME Create function to test compatibility properly */
 	if (mda_count > 1) {
-		log_error("%s: too many metadata areas for pvresize", pv_name);
+		log_error(0, "%s: too many metadata areas for pvresize", pv_name);
 		goto bad;
 	}
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
-		log_error("Physical volume %s format does not support resizing.",
+		log_error(0, "Physical volume %s format does not support resizing.",
 			  pv_name);
 		goto bad;
 	}
 
 	/* Get new size */
 	if (!dev_get_size(pv_dev(pv), &size)) {
-		log_error("%s: Couldn't get size.", pv_name);
+		log_error(0, "%s: Couldn't get size.", pv_name);
 		goto bad;
 	}
 
@@ -111,13 +111,13 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	}
 
 	if (size < PV_MIN_SIZE) {
-		log_error("%s: Size must exceed minimum of %ld sectors.",
+		log_error(0, "%s: Size must exceed minimum of %ld sectors.",
 			  pv_name, PV_MIN_SIZE);
 		goto bad;
 	}
 
 	if (size < pv_pe_start(pv)) {
-		log_error("%s: Size must exceed physical extent start of "
+		log_error(0, "%s: Size must exceed physical extent start of "
 			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
 		goto bad;
 	}
@@ -129,7 +129,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		new_pe_count = pv_size(pv) / vg->extent_size;
 
  		if (!new_pe_count) {
-			log_error("%s: Size must leave space for at "
+			log_error(0, "%s: Size must leave space for at "
 				  "least one physical extent of "
 				  "%" PRIu32 " sectors.", pv_name,
 				  pv_pe_size(pv));
@@ -146,13 +146,13 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (!is_orphan_vg(pv_vg_name(pv))) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to store physical volume \"%s\" in "
+			log_error(0, "Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			goto bad;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-		log_error("Failed to store physical volume \"%s\"",
+		log_error(0, "Failed to store physical volume \"%s\"",
 			  pv_name);
 		goto bad;;
 	}
@@ -190,12 +190,12 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	if (!argc) {
-		log_error("Please supply physical volume(s)");
+		log_error(0, "Please supply physical volume(s)");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume size may not be negative");
+		log_error(0, "Physical volume size may not be negative");
 		return 0;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 494af3d..fb7ee32 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -115,7 +115,7 @@ int pvscan(struct cmd_context *cmd, int argc __attribute((unused)),
 	vg_max_name_len = 0;
 
 	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
-		log_error("Options -e and -n are incompatible");
+		log_error(0, "Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -125,7 +125,7 @@ int pvscan(struct cmd_context *cmd, int argc __attribute((unused)),
 			  "of exported volume group(s)" : "in no volume group");
 
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
-		log_error("Unable to obtain global lock.");
+		log_error(0, "Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/reporter.c b/tools/reporter.c
index d1368d4..bcc8b14 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -137,7 +137,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
-			log_error("Skipping volume group %s", vg_name);
+			log_error(0, "Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
 
@@ -146,7 +146,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		 * allocated in vg_read_internal() path.
 		*/
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
+			log_error(0, "Unable to find \"%s\" in volume group \"%s\"",
 				  pv_dev_name(pv), vg->name);
 			ret = ECMD_FAILED;
 			goto out;
@@ -296,13 +296,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (arg_count(cmd, options_ARG)) {
 		opts = arg_str_value(cmd, options_ARG, "");
 		if (!opts || !*opts) {
-			log_error("Invalid options string: %s", opts);
+			log_error(0, "Invalid options string: %s", opts);
 			return EINVALID_CMD_LINE;
 		}
 		if (*opts == '+') {
 			if (!(str = dm_pool_alloc(cmd->mem,
 					 strlen(options) + strlen(opts) + 1))) {
-				log_error("options string allocation failed");
+				log_error(0, "options string allocation failed");
 				return ECMD_FAILED;
 			}
 			strcpy(str, options);
@@ -350,7 +350,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (report_type & PVSEGS)
 		report_type |= PVS;
 	if ((report_type & LVS) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
-		log_error("Can't report LV and PV fields at the same time");
+		log_error(0, "Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
 	}
diff --git a/tools/stub.h b/tools/stub.h
index 1523797..2d19403 100644
--- a/tools/stub.h
+++ b/tools/stub.h
@@ -14,7 +14,7 @@
  */
 
 #define unimplemented \
-	log_error("Command not implemented yet."); return ECMD_FAILED
+	log_error(0, "Command not implemented yet."); return ECMD_FAILED
 
 /*int e2fsadm(struct cmd_context *cmd, int argc, char **argv) unimplemented*/
 int lvmsadc(struct cmd_context *cmd __attribute((unused)),
@@ -35,9 +35,9 @@ int pvdata(struct cmd_context *cmd __attribute((unused)),
 	   int argc __attribute((unused)),
 	   char **argv __attribute((unused)))
 {
-	log_error("There's no 'pvdata' command in LVM2.");
-	log_error("Use lvs, pvs, vgs instead; or use vgcfgbackup and read the text file backup.");
-	log_error("Metadata in LVM1 format can still be displayed using LVM1's pvdata command.");
+	log_error(0, "There's no 'pvdata' command in LVM2.");
+	log_error(0, "Use lvs, pvs, vgs instead; or use vgcfgbackup and read the text file backup.");
+	log_error(0, "Metadata in LVM1 format can still be displayed using LVM1's pvdata command.");
 	return ECMD_FAILED;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 248fafb..1f63842 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -52,7 +52,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 
 		if (!dm_split_lvm_name(cmd->mem, vg_name, &vgname, &lvname, &layer) ||
 		    *layer) {
-			log_error("skip_dev_dir: Couldn't split up device name %s",
+			log_error(0, "skip_dev_dir: Couldn't split up device name %s",
 				  vg_name);
 			return (char *) vg_name;
 		}
@@ -61,7 +61,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 		    dm_snprintf(vglv, vglv_sz, "%s%s%s", vgname,
 				 *lvname ? "/" : "",
 				 lvname) < 0) {
-			log_error("vg/lv string alloc failed");
+			log_error(0, "vg/lv string alloc failed");
 			return (char *) vg_name;
 		}
 		return vglv;
@@ -155,7 +155,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	}
 
 	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
-		log_error("One or more specified logical volume(s) not found.");
+		log_error(0, "One or more specified logical volume(s) not found.");
 		if (ret_max < ECMD_FAILED)
 			ret_max = ECMD_FAILED;
 	}
@@ -203,14 +203,14 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 			if (*vgname == '@') {
 				if (!validate_name(vgname + 1)) {
-					log_error("Skipping invalid tag %s",
+					log_error(0, "Skipping invalid tag %s",
 						  vgname);
 					continue;
 				}
 				if (!str_list_add(cmd->mem, &tags,
 						  dm_pool_strdup(cmd->mem,
 							      vgname + 1))) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					return ECMD_FAILED;
 				}
 				continue;
@@ -220,7 +220,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			vgname = skip_dev_dir(cmd, vgname, &dev_dir_found);
 
 			if (*vgname == '/') {
-				log_error("\"%s\": Invalid path for Logical "
+				log_error(0, "\"%s\": Invalid path for Logical "
 					  "Volume", argv[opt]);
 				if (ret_max < ECMD_FAILED)
 					ret_max = ECMD_FAILED;
@@ -245,7 +245,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 			if (!str_list_add(cmd->mem, &arg_vgnames,
 					  dm_pool_strdup(cmd->mem, vgname))) {
-				log_error("strlist allocation failed");
+				log_error(0, "strlist allocation failed");
 				return ECMD_FAILED;
 			}
 
@@ -253,7 +253,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				if (!str_list_add(cmd->mem, &arg_lvnames,
 						  dm_pool_strdup(cmd->mem,
 							      vgname))) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					return ECMD_FAILED;
 				}
 			} else {
@@ -261,11 +261,11 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
 				    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname,
 						 lv_name) < 0) {
-					log_error("vg/lv string alloc failed");
+					log_error(0, "vg/lv string alloc failed");
 					return ECMD_FAILED;
 				}
 				if (!str_list_add(cmd->mem, &arg_lvnames, vglv)) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					return ECMD_FAILED;
 				}
 			}
@@ -276,7 +276,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
 		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
-			log_error("No volume groups found");
+			log_error(0, "No volume groups found");
 			return ret_max;
 		}
 	}
@@ -291,7 +291,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		if (vg_read_error(vg)) {
 			vg_release(vg);
 			if (ret_max < ECMD_FAILED) {
-				log_error("Skipping volume group %s", vgname);
+				log_error(0, "Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
 			}
 			continue;
@@ -313,7 +313,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					vg_release(vg);
 					return ECMD_FAILED;
 				}
@@ -355,7 +355,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
 			vg_release(vg);
-			log_error("Skipping volume group %s", vg_name);
+			log_error(0, "Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
 
@@ -364,7 +364,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		 * allocated in vg_read_internal() path.
 		 */
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
-			 log_error("Unable to find %s in volume group %s",
+			 log_error(0, "Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
 			vg_release(vg);
 			return ECMD_FAILED;
@@ -475,14 +475,14 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 			vg_name = argv[opt];
 			if (*vg_name == '@') {
 				if (!validate_name(vg_name + 1)) {
-					log_error("Skipping invalid tag %s",
+					log_error(0, "Skipping invalid tag %s",
 						  vg_name);
 					continue;
 				}
 				if (!str_list_add(cmd->mem, &tags,
 						  dm_pool_strdup(cmd->mem,
 							      vg_name + 1))) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					return ECMD_FAILED;
 				}
 				continue;
@@ -490,13 +490,13 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 			vg_name = skip_dev_dir(cmd, vg_name, NULL);
 			if (strchr(vg_name, '/')) {
-				log_error("Invalid volume group name: %s",
+				log_error(0, "Invalid volume group name: %s",
 					  vg_name);
 				continue;
 			}
 			if (!str_list_add(cmd->mem, &arg_vgnames,
 					  dm_pool_strdup(cmd->mem, vg_name))) {
-				log_error("strlist allocation failed");
+				log_error(0, "strlist allocation failed");
 				return ECMD_FAILED;
 			}
 		}
@@ -507,7 +507,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
 		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
-			log_error("No volume groups found");
+			log_error(0, "No volume groups found");
 			return ret_max;
 		}
 		dm_list_iterate_items(sl, vgids) {
@@ -581,7 +581,7 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	}
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
+		log_error(0, "dev_iter creation failed");
 		return ECMD_FAILED;
 	}
 
@@ -636,7 +636,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	dm_list_init(&tags);
 
 	if (lock_global && !lock_vol(cmd, VG_GLOBAL, lock_type)) {
-		log_error("Unable to obtain global lock.");
+		log_error(0, "Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
@@ -647,7 +647,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				tagname = argv[opt] + 1;
 
 				if (!validate_name(tagname)) {
-					log_error("Skipping invalid tag %s",
+					log_error(0, "Skipping invalid tag %s",
 						  tagname);
 					if (ret_max < EINVALID_CMD_LINE)
 						ret_max = EINVALID_CMD_LINE;
@@ -656,14 +656,14 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				if (!str_list_add(cmd->mem, &tags,
 						  dm_pool_strdup(cmd->mem,
 							      tagname))) {
-					log_error("strlist allocation failed");
+					log_error(0, "strlist allocation failed");
 					goto bad;
 				}
 				continue;
 			}
 			if (vg) {
 				if (!(pvl = find_pv_in_vg(vg, argv[opt]))) {
-					log_error("Physical Volume \"%s\" not "
+					log_error(0, "Physical Volume \"%s\" not "
 						  "found in Volume Group "
 						  "\"%s\"", argv[opt],
 						  vg->name);
@@ -674,7 +674,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			} else {
 				if (!(pv = pv_read(cmd, argv[opt], NULL,
 						   NULL, 1, scan_label_only))) {
-					log_error("Failed to read physical "
+					log_error(0, "Failed to read physical "
 						  "volume \"%s\"", argv[opt]);
 					ret_max = ECMD_FAILED;
 					continue;
@@ -698,7 +698,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 					if (!(pv = pv_read(cmd, argv[opt],
 							   NULL, NULL, 1,
 							   scan_label_only))) {
-						log_error("Failed to read "
+						log_error(0, "Failed to read "
 							  "physical volume "
 							  "\"%s\"", argv[opt]);
 						ret_max = ECMD_FAILED;
@@ -717,12 +717,12 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
-					log_error("Can't lock %s: skipping", sll->str);
+					log_error(0, "Can't lock %s: skipping", sll->str);
 					ret_max = ECMD_FAILED;
 					continue;
 				}
 				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
-					log_error("Volume group \"%s\" not found", sll->str);
+					log_error(0, "Volume group \"%s\" not found", sll->str);
 					unlock_vg(cmd, sll->str);
 					ret_max = ECMD_FAILED;
 					continue;
@@ -817,7 +817,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 				vg_name++;
 		}
 		if (*vg_name == '/') {
-			log_error("\"%s\": Invalid path for Logical "
+			log_error(0, "\"%s\": Invalid path for Logical "
 				  "Volume", lv_name);
 			return 0;
 		}
@@ -828,14 +828,14 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 				st++;
 
 		if (!strchr(vg_name, '/') || strchr(st, '/')) {
-			log_error("\"%s\": Invalid path for Logical Volume",
+			log_error(0, "\"%s\": Invalid path for Logical Volume",
 				  lv_name);
 			return 0;
 		}
 
 		vg_name = dm_pool_strdup(cmd->mem, vg_name);
 		if (!vg_name) {
-			log_error("Allocation of vg_name failed");
+			log_error(0, "Allocation of vg_name failed");
 			return 0;
 		}
 
@@ -845,7 +845,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 
 	if (!(vg_name = default_vgname(cmd))) {
 		if (lv_name)
-			log_error("Path required for Logical Volume \"%s\"",
+			log_error(0, "Path required for Logical Volume \"%s\"",
 				  lv_name);
 		return 0;
 	}
@@ -868,7 +868,7 @@ char *default_vgname(struct cmd_context *cmd)
 	vg_path = skip_dev_dir(cmd, vg_path, NULL);
 
 	if (strchr(vg_path, '/')) {
-		log_error("Environment Volume Group in LVM_VG_NAME invalid: "
+		log_error(0, "Environment Volume Group in LVM_VG_NAME invalid: "
 			  "\"%s\"", vg_path);
 		return 0;
 	}
@@ -892,7 +892,7 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 		if (((start < per->start) && (start + count - 1 >= per->start))
 		    || ((start >= per->start) &&
 			(per->start + per->count - 1) >= start)) {
-			log_error("Overlapping PE ranges specified (%" PRIu32
+			log_error(0, "Overlapping PE ranges specified (%" PRIu32
 				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")"
 				  " on %s",
 				  start, start + count - 1, per->start,
@@ -902,7 +902,7 @@ static int _add_pe_range(struct dm_pool *mem, const char *pvname,
 	}
 
 	if (!(per = dm_pool_alloc(mem, sizeof(*per)))) {
-		log_error("Allocation of list failed");
+		log_error(0, "Allocation of list failed");
 		return 0;
 	}
 
@@ -974,7 +974,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 			goto error;
 
 		if ((start > end) || (end > size - 1)) {
-			log_error("PE range error: start extent %" PRIu32 " to "
+			log_error(0, "PE range error: start extent %" PRIu32 " to "
 				  "end extent %" PRIu32, start, end);
 			return 0;
 		}
@@ -987,7 +987,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 	return 1;
 
       error:
-	log_error("Physical extent parsing error at %s", c);
+	log_error(0, "Physical extent parsing error at %s", c);
 	return 0;
 }
 
@@ -1000,18 +1000,18 @@ static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 
 	pvname = pv_dev_name(pvl->pv);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
-		log_error("Physical volume %s not allocatable", pvname);
+		log_error(0, "Physical volume %s not allocatable", pvname);
 		return 1;
 	}
 
 	if (allocatable_only && (pvl->pv->status & MISSING_PV)) {
-		log_error("Physical volume %s is missing", pvname);
+		log_error(0, "Physical volume %s is missing", pvname);
 		return 1;
 	}
 
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
-		log_err("No free extents on physical volume \"%s\"", pvname);
+		log_error(0, "No free extents on physical volume \"%s\"", pvname);
 		return 1;
 	}
 
@@ -1023,14 +1023,14 @@ static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 	
 	if (!new_pvl) {
 		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
-			log_err("Unable to allocate physical volume list.");
+			log_error(0, "Unable to allocate physical volume list.");
 			return 0;
 		}
 
 		memcpy(new_pvl, pvl, sizeof(*new_pvl));
 
 		if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
-			log_error("Allocation of pe_ranges list failed");
+			log_error(0, "Allocation of pe_ranges list failed");
 			return 0;
 		}
 		dm_list_init(pe_ranges);
@@ -1058,7 +1058,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 
 	/* Build up list of PVs */
 	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed");
+		log_error(0, "Allocation of list failed");
 		return NULL;
 	}
 	dm_list_init(r);
@@ -1070,7 +1070,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 		if (*argv[i] == '@') {
 			tagname = argv[i] + 1;
 			if (!validate_name(tagname)) {
-				log_error("Skipping invalid tag %s", tagname);
+				log_error(0, "Skipping invalid tag %s", tagname);
 				continue;
 			}
 			dm_list_iterate_items(pvl, &vg->pvs) {
@@ -1091,13 +1091,13 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 			if (!(pvname = dm_pool_strndup(mem, pvname,
 						    (unsigned) (colon -
 								pvname)))) {
-				log_error("Failed to clone PV name");
+				log_error(0, "Failed to clone PV name");
 				return NULL;
 			}
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pvname))) {
-			log_err("Physical Volume \"%s\" not found in "
+			log_error(0, "Physical Volume \"%s\" not found in "
 				"Volume Group \"%s\"", pvname, vg->name);
 			return NULL;
 		}
@@ -1106,7 +1106,7 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 	}
 
 	if (dm_list_empty(r))
-		log_error("No specified PVs have space available");
+		log_error(0, "No specified PVs have space available");
 
 	return dm_list_empty(r) ? NULL : r;
 }
@@ -1118,14 +1118,14 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 
 	/* Build up list of PVs */
 	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed");
+		log_error(0, "Allocation of list failed");
 		return NULL;
 	}
 	dm_list_init(r);
 
 	dm_list_iterate_items(pvl, pvsl) {
 		if (!(new_pvl = dm_pool_zalloc(mem, sizeof(*new_pvl)))) {
-			log_error("Unable to allocate physical volume list.");
+			log_error(0, "Unable to allocate physical volume list.");
 			return NULL;
 		}
 
@@ -1139,31 +1139,31 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 int apply_lvname_restrictions(const char *name)
 {
 	if (!strncmp(name, "snapshot", 8)) {
-		log_error("Names starting \"snapshot\" are reserved. "
+		log_error(0, "Names starting \"snapshot\" are reserved. "
 			  "Please choose a different LV name.");
 		return 0;
 	}
 
 	if (!strncmp(name, "pvmove", 6)) {
-		log_error("Names starting \"pvmove\" are reserved. "
+		log_error(0, "Names starting \"pvmove\" are reserved. "
 			  "Please choose a different LV name.");
 		return 0;
 	}
 
 	if (strstr(name, "_mlog")) {
-		log_error("Names including \"_mlog\" are reserved. "
+		log_error(0, "Names including \"_mlog\" are reserved. "
 			  "Please choose a different LV name.");
 		return 0;
 	}
 
 	if (strstr(name, "_mimage")) {
-		log_error("Names including \"_mimage\" are reserved. "
+		log_error(0, "Names including \"_mimage\" are reserved. "
 			  "Please choose a different LV name.");
 		return 0;
 	}
 
 	if (strstr(name, "_vorigin")) {
-		log_error("Names including \"_vorigin\" are reserved. "
+		log_error(0, "Names including \"_vorigin\" are reserved. "
 			  "Please choose a different LV name.");
 		return 0;
 	}
@@ -1212,17 +1212,17 @@ int fill_vg_create_params(struct cmd_context *cmd,
 		vp_new->clustered = locking_is_clustered();
 
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
+		log_error(0, "Physical extent size may not be negative");
 		return 1;
 	}
 
 	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("Max Logical Volumes may not be negative");
+		log_error(0, "Max Logical Volumes may not be negative");
 		return 1;
 	}
 
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("Max Physical Volumes may not be negative");
+		log_error(0, "Max Physical Volumes may not be negative");
 		return 1;
 	}
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index c8ae40c..9336eed 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -24,18 +24,18 @@ static char *_expand_filename(const char *template, const char *vg_name,
 		return dm_strdup(template);
 
 	if (!(filename = dm_malloc(PATH_MAX))) {
-		log_error("Failed to allocate filename.");
+		log_error(0, "Failed to allocate filename.");
 		return NULL;
 	}
 
 	if (snprintf(filename, PATH_MAX, template, vg_name) < 0) {
-		log_error("Error processing filename template %s",
+		log_error(0, "Error processing filename template %s",
 			   template);
 		dm_free(filename);	
 		return NULL;
 	}
 	if (*last_filename && !strncmp(*last_filename, filename, PATH_MAX)) {
-		log_error("VGs must be backed up into different files. "
+		log_error(0, "VGs must be backed up into different files. "
 			  "Use %%s in filename for VG name.");
 		dm_free(filename);
 		return NULL;
@@ -68,7 +68,7 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 			return ECMD_FAILED;
 	} else {
 		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
-			log_error("No backup taken: specify filename with -f "
+			log_error(0, "No backup taken: specify filename with -f "
 				  "to backup an inconsistent VG");
 			stack;
 			return ECMD_FAILED;
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 6ec20d1..6ed9077 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -22,11 +22,11 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		if (!validate_name(vg_name)) {
-			log_error("Volume group name \"%s\" is invalid", vg_name);
+			log_error(0, "Volume group name \"%s\" is invalid", vg_name);
 			return ECMD_FAILED;
 		}
 	} else if (!(arg_count(cmd, list_ARG) && arg_count(cmd, file_ARG))) {
-		log_err("Please specify a *single* volume group to restore.");
+		log_error(0, "Please specify a *single* volume group to restore.");
 		return ECMD_FAILED;
 	}
 
@@ -44,12 +44,12 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Unable to lock orphans");
+		log_error(0, "Unable to lock orphans");
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Unable to lock volume group %s", vg_name);
+		log_error(0, "Unable to lock volume group %s", vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
@@ -60,7 +60,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	      backup_restore(cmd, vg_name))) {
 		unlock_vg(cmd, vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
-		log_err("Restore failed.");
+		log_error(0, "Restore failed.");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a5121fc..2e7f9b5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -133,13 +133,13 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 
 	/* FIXME: Force argument to deactivate them? */
 	if (!activate && (lv_open = lvs_in_vg_opened(vg))) {
-		log_error("Can't deactivate volume group \"%s\" with %d open "
+		log_error(0, "Can't deactivate volume group \"%s\" with %d open "
 			  "logical volume(s)", vg->name, lv_open);
 		return ECMD_FAILED;
 	}
 
 	if (activate && lockingfailed() && (vg_is_clustered(vg))) {
-		log_error("Locking inactive: ignoring clustered "
+		log_error(0, "Locking inactive: ignoring clustered "
 			  "volume group %s", vg->name);
 		return ECMD_FAILED;
 	}
@@ -180,13 +180,13 @@ static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
 	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
+		log_error(0, "Volume Group allocation policy cannot inherit "
 			  "from anything");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (alloc == vg->alloc) {
-		log_error("Volume group allocation policy is already %s",
+		log_error(0, "Volume group allocation policy is already %s",
 			  get_alloc_string(vg->alloc));
 		return ECMD_FAILED;
 	}
@@ -212,13 +212,13 @@ static int _vgchange_resizeable(struct cmd_context *cmd,
 	int resizeable = !strcmp(arg_str_value(cmd, resizeable_ARG, "n"), "y");
 
 	if (resizeable && (vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is already resizeable",
+		log_error(0, "Volume group \"%s\" is already resizeable",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (!resizeable && !(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" is already not resizeable",
+		log_error(0, "Volume group \"%s\" is already not resizeable",
 			  vg->name);
 		return ECMD_FAILED;
 	}
@@ -248,13 +248,13 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 	struct lv_list *lvl;
 
 	if (clustered && (vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already clustered",
+		log_error(0, "Volume group \"%s\" is already clustered",
 			  vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (!clustered && !(vg_is_clustered(vg))) {
-		log_error("Volume group \"%s\" is already not clustered",
+		log_error(0, "Volume group \"%s\" is already not clustered",
 			  vg->name);
 		return ECMD_FAILED;
 	}
@@ -262,7 +262,7 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 	if (clustered) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
-				log_error("Volume group %s contains snapshots "
+				log_error(0, "Volume group %s contains snapshots "
 					  "that are not yet supported.",
 					  vg->name);
 				return ECMD_FAILED;
@@ -294,7 +294,7 @@ static int _vgchange_logicalvolume(struct cmd_context *cmd,
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
 	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
+		log_error(0, "Volume group \"%s\" must be resizeable "
 			  "to change MaxLogicalVolume", vg->name);
 		return ECMD_FAILED;
 	}
@@ -303,13 +303,13 @@ static int _vgchange_logicalvolume(struct cmd_context *cmd,
 		if (!max_lv)
 			max_lv = 255;
 		else if (max_lv > 255) {
-			log_error("MaxLogicalVolume limit is 255");
+			log_error(0, "MaxLogicalVolume limit is 255");
 			return ECMD_FAILED;
 		}
 	}
 
 	if (max_lv && max_lv < vg_visible_lvs(vg)) {
-		log_error("MaxLogicalVolume is less than the current number "
+		log_error(0, "MaxLogicalVolume is less than the current number "
 			  "%d of LVs for %s", vg_visible_lvs(vg),
 			  vg->name);
 		return ECMD_FAILED;
@@ -336,13 +336,13 @@ static int _vgchange_physicalvolumes(struct cmd_context *cmd,
 	uint32_t max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 
 	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
+		log_error(0, "Volume group \"%s\" must be resizeable "
 			  "to change MaxPhysicalVolumes", vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("MaxPhysicalVolumes may not be negative");
+		log_error(0, "MaxPhysicalVolumes may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -350,13 +350,13 @@ static int _vgchange_physicalvolumes(struct cmd_context *cmd,
 		if (!max_pv)
 			max_pv = 255;
 		else if (max_pv > 255) {
-			log_error("MaxPhysicalVolume limit is 255");
+			log_error(0, "MaxPhysicalVolume limit is 255");
 			return ECMD_FAILED;
 		}
 	}
 
 	if (max_pv && max_pv < vg->pv_count) {
-		log_error("MaxPhysicalVolumes is less than the current number "
+		log_error(0, "MaxPhysicalVolumes is less than the current number "
 			  "%d of PVs for \"%s\"", vg->pv_count,
 			  vg->name);
 		return ECMD_FAILED;
@@ -382,37 +382,37 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 	uint32_t extent_size;
 
 	if (!(vg_status(vg) & RESIZEABLE_VG)) {
-		log_error("Volume group \"%s\" must be resizeable "
+		log_error(0, "Volume group \"%s\" must be resizeable "
 			  "to change PE size", vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
+		log_error(0, "Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
 	if (!extent_size) {
-		log_error("Physical extent size may not be zero");
+		log_error(0, "Physical extent size may not be zero");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (extent_size == vg->extent_size) {
-		log_error("Physical extent size of VG %s is already %s",
+		log_error(0, "Physical extent size of VG %s is already %s",
 			  vg->name, display_size(cmd, (uint64_t) extent_size));
 		return ECMD_PROCESSED;
 	}
 
 	if (extent_size & (extent_size - 1)) {
-		log_error("Physical extent size must be a power of 2.");
+		log_error(0, "Physical extent size must be a power of 2.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (extent_size > vg->extent_size) {
 		if ((uint64_t) vg->extent_size * vg->extent_count % extent_size) {
 			/* FIXME Adjust used PV sizes instead */
-			log_error("New extent size is not a perfect fit");
+			log_error(0, "New extent size is not a perfect fit");
 			return EINVALID_CMD_LINE;
 		}
 	}
@@ -441,12 +441,12 @@ static int _vgchange_tag(struct cmd_context *cmd, struct volume_group *vg,
 	const char *tag;
 
 	if (!(tag = arg_str_value(cmd, arg, NULL))) {
-		log_error("Failed to get tag");
+		log_error(0, "Failed to get tag");
 		return ECMD_FAILED;
 	}
 
 	if (!(vg->fid->fmt->features & FMT_TAGS)) {
-		log_error("Volume group %s does not support tags", vg->name);
+		log_error(0, "Volume group %s does not support tags", vg->name);
 		return ECMD_FAILED;
 	}
 
@@ -455,13 +455,13 @@ static int _vgchange_tag(struct cmd_context *cmd, struct volume_group *vg,
 
 	if ((arg == addtag_ARG)) {
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
+			log_error(0, "Failed to add tag %s to volume group %s",
 				  tag, vg->name);
 			return ECMD_FAILED;
 		}
 	} else {
 		if (!str_list_del(&vg->tags, tag)) {
-			log_error("Failed to remove tag %s from volume group "
+			log_error(0, "Failed to remove tag %s from volume group "
 				  "%s", tag, vg->name);
 			return ECMD_FAILED;
 		}
@@ -483,7 +483,7 @@ static int _vgchange_uuid(struct cmd_context *cmd __attribute((unused)),
 	struct lv_list *lvl;
 
 	if (lvs_in_vg_activated(vg)) {
-		log_error("Volume group has active logical volumes");
+		log_error(0, "Volume group has active logical volumes");
 		return ECMD_FAILED;
 	}
 
@@ -491,7 +491,7 @@ static int _vgchange_uuid(struct cmd_context *cmd __attribute((unused)),
 		return ECMD_FAILED;
 
 	if (!id_create(&vg->id)) {
-		log_error("Failed to generate new random UUID for VG %s.",
+		log_error(0, "Failed to generate new random UUID for VG %s.",
 			  vg->name);
 		return ECMD_FAILED;
 	}
@@ -530,7 +530,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 
 	if (vg_status(vg) & EXPORTED_VG) {
-		log_error("Volume group \"%s\" is exported", vg_name);
+		log_error(0, "Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -587,7 +587,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
 	     arg_count(cmd, monitor_ARG) + arg_count(cmd, refresh_ARG))) {
-		log_error("One of -a, -c, -l, -p, -s, -x, --refresh, "
+		log_error(0, "One of -a, -c, -l, -p, -s, -x, --refresh, "
 				"--uuid, --alloc, --addtag or --deltag required");
 		return EINVALID_CMD_LINE;
 	}
@@ -599,20 +599,20 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	    arg_count(cmd, addtag_ARG) + arg_count(cmd, alloc_ARG) +
 	    arg_count(cmd, uuid_ARG) + arg_count(cmd, clustered_ARG) +
 	    arg_count(cmd, physicalextentsize_ARG) > 1) {
-		log_error("Only one of -a, -c, -l, -p, -s, -x, --uuid, "
+		log_error(0, "Only one of -a, -c, -l, -p, -s, -x, --uuid, "
 			  "--alloc, --addtag or --deltag allowed");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) &&
 	    !arg_count(cmd, available_ARG)) {
-		log_error("--ignorelockingfailure only available with -a");
+		log_error(0, "--ignorelockingfailure only available with -a");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, available_ARG) == 1
 	    && arg_count(cmd, autobackup_ARG)) {
-		log_error("-A option not necessary with -a option");
+		log_error(0, "-A option not necessary with -a option");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 0996d95..baf9aee 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -39,14 +39,14 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 
 	if (vg->fid->fmt == cmd->fmt) {
-		log_error("Volume group \"%s\" already uses format %s",
+		log_error(0, "Volume group \"%s\" already uses format %s",
 			  vg_name, cmd->fmt->name);
 		return ECMD_FAILED;
 	}
 
 	if (cmd->fmt->features & FMT_MDAS) {
 		if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
-			log_error("Metadata size may not be negative");
+			log_error(0, "Metadata size may not be negative");
 			return EINVALID_CMD_LINE;
 		}
 
@@ -67,7 +67,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!archive(vg)) {
-		log_error("Archive of \"%s\" metadata failed.", vg_name);
+		log_error(0, "Archive of \"%s\" metadata failed.", vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -85,7 +85,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	    cmd->fmt->features & FMT_RESTRICTED_LVIDS)
 		dm_list_iterate_items(lvl, &vg->lvs)
 			if (!lvid_in_restricted_range(&lvl->lv->lvid)) {
-				log_error("Logical volume %s lvid format is"
+				log_error(0, "Logical volume %s lvid format is"
 					  " incompatible with requested"
 					  " metadata format.", lvl->lv->name);
 				return ECMD_FAILED;
@@ -100,7 +100,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			if (lvnum_from_lvid(&lv->lvid) < MAX_RESTRICTED_LVS)
 				continue;
 			if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-				log_error("Logical volume %s must be "
+				log_error(0, "Logical volume %s must be "
 					  "deactivated before conversion.",
 					   lv->name);
 				active++;
@@ -127,10 +127,10 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
-			log_error("Failed to setup physical volume \"%s\"",
+			log_error(0, "Failed to setup physical volume \"%s\"",
 				  pv_dev_name(existing_pv));
 			if (change_made)
-				log_error("Use pvcreate and vgcfgrestore to "
+				log_error(0, "Use pvcreate and vgcfgrestore to "
 					  "repair from archived metadata.");
 			return ECMD_FAILED;
 		}
@@ -143,9 +143,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 		/* Wipe existing label first */
 		if (!label_remove(pv_dev(pv))) {
-			log_error("Failed to wipe existing label on %s",
+			log_error(0, "Failed to wipe existing label on %s",
 				  pv_dev_name(pv));
-			log_error("Use pvcreate and vgcfgrestore to repair "
+			log_error(0, "Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
@@ -155,9 +155,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		if (!(pv_write(cmd, pv, &mdas,
 			       arg_int64_value(cmd, labelsector_ARG,
 					       DEFAULT_LABELSECTOR)))) {
-			log_error("Failed to write physical volume \"%s\"",
+			log_error(0, "Failed to write physical volume \"%s\"",
 				  pv_dev_name(pv));
-			log_error("Use pvcreate and vgcfgrestore to repair "
+			log_error(0, "Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
@@ -168,9 +168,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_verbose("Deleting existing metadata for VG %s", vg_name);
 	if (!vg_remove(vg)) {
-		log_error("Removal of existing metadata for %s failed.",
+		log_error(0, "Removal of existing metadata for %s failed.",
 			  vg_name);
-		log_error("Use pvcreate and vgcfgrestore to repair "
+		log_error(0, "Use pvcreate and vgcfgrestore to repair "
 			  "from archived metadata.");
 		return ECMD_FAILED;
 	}
@@ -185,8 +185,8 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
 	if (!backup_restore_vg(cmd, vg)) {
-		log_error("Conversion failed for volume group %s.", vg_name);
-		log_error("Use pvcreate and vgcfgrestore to repair from "
+		log_error(0, "Conversion failed for volume group %s.", vg_name);
+		log_error(0, "Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");
 		return ECMD_FAILED;
 	}
@@ -200,12 +200,12 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc) {
-		log_error("Please enter volume group(s)");
+		log_error(0, "Please enter volume group(s)");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu",
+		log_error(0, "labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);
 		return EINVALID_CMD_LINE;
 	}
@@ -213,13 +213,13 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 	if (!(cmd->fmt->features & FMT_MDAS) &&
 	    (arg_count(cmd, metadatacopies_ARG) ||
 	     arg_count(cmd, metadatasize_ARG))) {
-		log_error("Metadata parameters only apply to text format");
+		log_error(0, "Metadata parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, metadatacopies_ARG) &&
 	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
+		log_error(0, "Metadatacopies may only be 0, 1 or 2");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 232b570..f840106 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -24,13 +24,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	const char *clustered_message = "";
 
 	if (!argc) {
-		log_error("Please provide volume group name and "
+		log_error(0, "Please provide volume group name and "
 			  "physical volumes");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc == 1) {
-		log_error("Please enter physical volume name(s)");
+		log_error(0, "Please enter physical volume name(s)");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -47,12 +47,12 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	    return EINVALID_CMD_LINE;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
 	if (vg_lock_newname(cmd, vp_new.vg_name) != SUCCESS) {
-		log_error("Can't get lock for %s", vp_new.vg_name);
+		log_error(0, "Can't get lock for %s", vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
@@ -73,17 +73,17 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
+			log_error(0, "Failed to get tag");
 			goto bad;
 		}
 
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group format does not support tags");
+			log_error(0, "Volume group format does not support tags");
 			goto bad;
 		}
 
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
+			log_error(0, "Failed to add tag %s to volume group %s",
 				  tag, vp_new.vg_name);
 			goto bad;
 		}
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index bbabcee..d2e006e 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -59,7 +59,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 		if (arg_count(cmd, colon_ARG) ||
 		    arg_count(cmd, activevolumegroups_ARG) ||
 		    arg_count(cmd, short_ARG)) {
-			log_error("Incompatible options selected");
+			log_error(0, "Incompatible options selected");
 			return EINVALID_CMD_LINE;
 		}
 		return vgs(cmd, argc, argv);
@@ -68,17 +68,17 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 		   arg_count(cmd, options_ARG) ||
 		   arg_count(cmd, separator_ARG) ||
 		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
-		log_error("Incompatible options selected");
+		log_error(0, "Incompatible options selected");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, colon_ARG) && arg_count(cmd, short_ARG)) {
-		log_error("Option -c is not allowed with option -s");
+		log_error(0, "Option -c is not allowed with option -s");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc && arg_count(cmd, activevolumegroups_ARG)) {
-		log_error("Option -A is not allowed with volume group names");
+		log_error(0, "Option -A is not allowed with volume group names");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 59627b9..7ed293e 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -27,7 +27,7 @@ static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
 		goto error;
 
 	if (lvs_in_vg_activated(vg)) {
-		log_error("Volume group \"%s\" has active logical volumes",
+		log_error(0, "Volume group \"%s\" has active logical volumes",
 			  vg_name);
 		goto error;
 	}
@@ -58,12 +58,12 @@ static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
 int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_count(cmd, all_ARG)) {
-		log_error("Please supply volume groups or use -a for all.");
+		log_error(0, "Please supply volume groups or use -a for all.");
 		return ECMD_FAILED;
 	}
 
 	if (argc && arg_count(cmd, all_ARG)) {
-		log_error("No arguments permitted when using -a for all.");
+		log_error(0, "No arguments permitted when using -a for all.");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 1000dc2..2690be8 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -22,13 +22,13 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	int r = ECMD_FAILED;
 
 	if (!argc) {
-		log_error("Please enter volume group name and "
+		log_error(0, "Please enter volume group name and "
 			  "physical volume(s)");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc == 1) {
-		log_error("Please enter physical volume(s)");
+		log_error(0, "Please enter physical volume(s)");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -37,7 +37,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 864a700..7ceb8bf 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -27,12 +27,12 @@ static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 		goto error;
 
 	if (!(vg_status(vg) & EXPORTED_VG)) {
-		log_error("Volume group \"%s\" is not exported", vg_name);
+		log_error(0, "Volume group \"%s\" is not exported", vg_name);
 		goto error;
 	}
 
 	if (vg_status(vg) & PARTIAL_VG) {
-		log_error("Volume group \"%s\" is partially missing", vg_name);
+		log_error(0, "Volume group \"%s\" is partially missing", vg_name);
 		goto error;
 	}
 
@@ -62,12 +62,12 @@ static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_count(cmd, all_ARG)) {
-		log_error("Please supply volume groups or use -a for all.");
+		log_error(0, "Please supply volume groups or use -a for all.");
 		return ECMD_FAILED;
 	}
 
 	if (argc && arg_count(cmd, all_ARG)) {
-		log_error("No arguments permitted when using -a for all.");
+		log_error(0, "No arguments permitted when using -a for all.");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 4a9e377..ff9874f 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -23,7 +23,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	int r = ECMD_FAILED;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
-		log_error("Duplicate volume group name \"%s\"", vg_name_from);
+		log_error(0, "Duplicate volume group name \"%s\"", vg_name_from);
 		return ECMD_FAILED;
 	}
 
@@ -75,7 +75,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 
 			if (id_equal(&lvid1->id[1], &lvid2->id[1])) {
 				if (!id_create(&lvid2->id[1])) {
-					log_error("Failed to generate new "
+					log_error(0, "Failed to generate new "
 						  "random LVID for %s",
 						  lvl2->lv->name);
 					goto bad;
@@ -129,7 +129,7 @@ int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 	int ret = 0, ret_max = 0;
 
 	if (argc < 2) {
-		log_error("Please enter 2 or more volume groups to merge");
+		log_error(0, "Please enter 2 or more volume groups to merge");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 44010e3..ec84d62 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -21,7 +21,7 @@ static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 	char uuid[64] __attribute((aligned(8)));
 
 	if (vg->pv_count == 1) {
-		log_error("Volume Groups must always contain at least one PV");
+		log_error(0, "Volume Groups must always contain at least one PV");
 		return 0;
 	}
 
@@ -32,7 +32,7 @@ static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 
 	if (pvl->pv->pe_alloc_count) {
 		if (!silent)
-			log_error("LVs still present on PV with UUID %s: "
+			log_error(0, "LVs still present on PV with UUID %s: "
 				  "Can't remove from VG %s", uuid, vg->name);
 		return 0;
 	}
@@ -67,7 +67,7 @@ static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
 			    "(origin of %s)", snap_seg->origin->name, lv->name);
 
 		if (!test_mode() && !deactivate_lv(cmd, snap_seg->origin)) {
-			log_error("Failed to deactivate LV %s",
+			log_error(0, "Failed to deactivate LV %s",
 				  snap_seg->origin->name);
 			return 0;
 		}
@@ -84,7 +84,7 @@ static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
 
 		if (first && !test_mode() &&
 		    !deactivate_lv(cmd, snap_seg->origin)) {
-			log_error("Failed to deactivate LV %s",
+			log_error(0, "Failed to deactivate LV %s",
 				  snap_seg->origin->name);
 			return 0;
 		}
@@ -116,7 +116,7 @@ static int _remove_lv(struct cmd_context *cmd, struct logical_volume *lv,
 			return_0;
 
 		if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-			log_error("lv_list alloc failed");
+			log_error(0, "lv_list alloc failed");
 			return 0;
 		}
 		lvl->lv = lv;
@@ -196,7 +196,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 				    (pv->status & MISSING_PV)) {
 					if (arg_count(cmd, mirrorsonly_ARG) &&
 					    !(lv->status & MIRROR_IMAGE)) {
-						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
+						log_error(0, "Non-mirror-image LV %s found: can't remove.", lv->name);
 						only_mirror_images_found = 0;
 						continue;
 					}
@@ -210,7 +210,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	if (!only_mirror_images_found) {
-		log_error("Aborting because --mirrorsonly was specified.");
+		log_error(0, "Aborting because --mirrorsonly was specified.");
 		return 0;
 	}
 
@@ -234,7 +234,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 
 	if (!dm_list_empty(&lvs_changed)) {
 		if (!vg_write(vg)) {
-			log_error("Failed to write out a consistent VG for %s",
+			log_error(0, "Failed to write out a consistent VG for %s",
 				  vg->name);
 			return 0;
 		}
@@ -249,7 +249,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 		}
 
 		if (!vg_commit(vg)) {
-			log_error("Failed to commit consistent VG for %s",
+			log_error(0, "Failed to commit consistent VG for %s",
 				  vg->name);
 			vg_revert(vg);
 			return 0;
@@ -257,7 +257,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 
 		if (!test_mode()) {
 			if (!resume_lvs(cmd, &lvs_changed)) {
-				log_error("Failed to resume LVs using error segments.");
+				log_error(0, "Failed to resume LVs using error segments.");
 				return 0;
 			}
 		}
@@ -310,13 +310,13 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 					return_0;
 
 				if (!vg_write(vg)) {
-					log_error("Failed to write out updated "
+					log_error(0, "Failed to write out updated "
 						  "VG for %s", vg->name);
 					return 0;
 				}
 		
 				if (!vg_commit(vg)) {
-					log_error("Failed to commit updated VG "
+					log_error(0, "Failed to commit updated VG "
 						  "for %s", vg->name);
 					vg_revert(vg);
 					return 0;
@@ -348,7 +348,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 					    lvl->lv->name);
 
 				if (!deactivate_lv(cmd, lvl->lv)) {
-					log_error("Failed to deactivate LV %s",
+					log_error(0, "Failed to deactivate LV %s",
 						  lvl->lv->name);
 					/*
 					 * We failed to deactivate.
@@ -386,18 +386,18 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *name = pv_dev_name(pv);
 
 	if (pv_pe_alloc_count(pv)) {
-		log_error("Physical volume \"%s\" still in use", name);
+		log_error(0, "Physical volume \"%s\" still in use", name);
 		return ECMD_FAILED;
 	}
 
 	if (vg->pv_count == 1) {
-		log_error("Can't remove final physical volume \"%s\" from "
+		log_error(0, "Can't remove final physical volume \"%s\" from "
 			  "volume group \"%s\"", name, vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
@@ -415,7 +415,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {
-		log_error("%s: Couldn't get size.", pv_dev_name(pv));
+		log_error(0, "%s: Couldn't get size.", pv_dev_name(pv));
 		goto bad;
 	}
 
@@ -430,19 +430,19 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
-		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
+		log_error(0, "Cannot remove final metadata area on \"%s\" from \"%s\"",
 			  name, vg->name);
 		goto bad;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Removal of physical volume \"%s\" from "
+		log_error(0, "Removal of physical volume \"%s\" from "
 			  "\"%s\" failed", name, vg->name);
 		goto bad;
 	}
 
 	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
-		log_error("Failed to clear metadata from physical "
+		log_error(0, "Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);
 		goto bad;
@@ -467,34 +467,34 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
 	if (!argc && !repairing) {
-		log_error("Please give volume group name and "
+		log_error(0, "Please give volume group name and "
 			  "physical volume paths");
 		return EINVALID_CMD_LINE;
 	}
 	
 	if (!argc && repairing) {
-		log_error("Please give volume group name");
+		log_error(0, "Please give volume group name");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, mirrorsonly_ARG) && !repairing) {
-		log_error("--mirrorsonly requires --removemissing");
+		log_error(0, "--mirrorsonly requires --removemissing");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc == 1 && !arg_count(cmd, all_ARG) && !repairing) {
-		log_error("Please enter physical volume paths or option -a");
+		log_error(0, "Please enter physical volume paths or option -a");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc > 1 && arg_count(cmd, all_ARG)) {
-		log_error("Option -a and physical volume paths mutually "
+		log_error(0, "Option -a and physical volume paths mutually "
 			  "exclusive");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (argc > 1 && repairing) {
-		log_error("Please only specify the volume group");
+		log_error(0, "Please only specify the volume group");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -503,7 +503,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 
 	if (!validate_name(vg_name)) {
-		log_error("Volume group name \"%s\" is invalid",
+		log_error(0, "Volume group name \"%s\" is invalid",
 			  vg_name);
 		return ECMD_FAILED;
 	}
@@ -525,7 +525,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 
 	if (repairing) {
 		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
-			log_error("Volume group \"%s\" is already consistent",
+			log_error(0, "Volume group \"%s\" is already consistent",
 				  vg_name);
 			ret = ECMD_PROCESSED;
 			goto out;
@@ -552,7 +552,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 			fixed = _consolidate_vg(cmd, vg);
 
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to write out a consistent VG for %s",
+			log_error(0, "Failed to write out a consistent VG for %s",
 				  vg_name);
 			goto out;
 		}
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 5956075..102415c 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -31,12 +31,12 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	if (!argc) {
-		log_error("Please enter one or more volume group paths");
+		log_error(0, "Please enter one or more volume group paths");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error(0, "Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 57229e7..094bfb2 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -42,7 +42,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	/* Avoid duplicates */
 	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
-		log_error("No complete volume groups found");
+		log_error(0, "No complete volume groups found");
 		return 0;
 	}
 
@@ -53,7 +53,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 			continue;
 		if (!strcmp(vg_name, vg_name_old)) {
 			if (match) {
-				log_error("Found more than one VG called %s. "
+				log_error(0, "Found more than one VG called %s. "
 					  "Please supply VG uuid.", vg_name_old);
 				return 0;
 			}
@@ -80,7 +80,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
-		log_error("Volume group \"%s\" still has active LVs",
+		log_error(0, "Volume group \"%s\" still has active LVs",
 			  vg_name_old);
 		/* FIXME Remove this restriction */
 		return 0;
@@ -92,12 +92,12 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	if (rc == FAILED_LOCKING) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
-		log_error("Can't get lock for %s", vg_name_new);
+		log_error(0, "Can't get lock for %s", vg_name_new);
 		return 0;
 	}
 
 	if (rc == FAILED_EXIST) {
-		log_error("New volume group \"%s\" already exists",
+		log_error(0, "New volume group \"%s\" already exists",
 			  vg_name_new);
 		unlock_and_release_vg(cmd, vg, vg_name_old);
 		return 0;
@@ -129,7 +129,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 		else if (lvs_in_vg_activated_by_uuid_only(vg)) {
 			if (!vg_refresh_visible(cmd, vg)) {
-				log_error("Renaming \"%s\" to \"%s\" failed", 
+				log_error(0, "Renaming \"%s\" to \"%s\" failed", 
 					old_path, new_path);
 				goto error;
 			}
@@ -162,7 +162,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 int vgrename(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (argc != 2) {
-		log_error("Old and new volume group names need specifying");
+		log_error(0, "Old and new volume group names need specifying");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 769c5cf..cb79159 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -36,12 +36,12 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 	int maxret, ret;
 
 	if (argc) {
-		log_error("Too many parameters on command line");
+		log_error(0, "Too many parameters on command line");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
-		log_error("Unable to obtain global lock.");
+		log_error(0, "Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 9cd90b8..9e8afc0 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -23,7 +23,7 @@ static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 
 	/* FIXME: handle tags */
 	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
-		log_error("Physical volume %s not in volume group %s",
+		log_error(0, "Physical volume %s not in volume group %s",
 			  pv_name, vg_from->name);
 		return 0;
 	}
@@ -55,7 +55,7 @@ static int _move_pvs_used_by_lv(struct volume_group *vg_from,
 
 	/* FIXME: handle tags */
 	if (!(lvl = find_lv_in_vg(vg_from, lv_name))) {
-		log_error("Logical volume %s not in volume group %s",
+		log_error(0, "Logical volume %s not in volume group %s",
 			  lv_name, vg_from->name);
 		return 0;
 	}
@@ -102,7 +102,7 @@ static int _move_one_lv(struct volume_group *vg_from,
 	dm_list_move(&vg_to->lvs, lvh);
 	
 	if (lv_is_active(lv)) {
-		log_error("Logical volume \"%s\" must be inactive", lv->name);
+		log_error(0, "Logical volume \"%s\" must be inactive", lv->name);
 		return 0;
 	}
 
@@ -139,7 +139,7 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 				pv = seg_pv(seg, s);
 				if (vg_with) {
 					if (!pv_is_in_vg(vg_with, pv)) {
-						log_error("Can't split Logical "
+						log_error(0, "Can't split Logical "
 							  "Volume %s between "
 							  "two Volume Groups",
 							  lv->name);
@@ -156,7 +156,7 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 					vg_with = vg_to;
 					continue;
 				}
-				log_error("Physical Volume %s not found",
+				log_error(0, "Physical Volume %s not found",
 					  pv_dev_name(pv));
 				return 0;
 			}
@@ -202,7 +202,7 @@ static int _move_snapshots(struct volume_group *vg_from,
 				continue;
 			if ((!cow_from && origin_from) ||
 			     (cow_from && !origin_from)) {
-				log_error("Can't split snapshot %s between"
+				log_error(0, "Can't split snapshot %s between"
 					  " two Volume Groups", seg->cow->name);
 				return 0;
 			}
@@ -249,7 +249,7 @@ static int _move_mirrors(struct volume_group *vg_from,
 		if ((seg_in && seg_in < seg->area_count) ||
 		    (seg_in && seg->log_lv && !log_in) ||
 		    (!seg_in && seg->log_lv && log_in)) {
-			log_error("Can't split mirror %s between "
+			log_error(0, "Can't split mirror %s between "
 				  "two Volume Groups", lv->name);
 			return 0;
 		}
@@ -287,13 +287,13 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	uint32_t rc;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
-		log_error("Existing VG, new VG and either physical volumes "
+		log_error(0, "Existing VG, new VG and either physical volumes "
 			  "or logical volume required.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, name_ARG) && (argc > 2)) {
-		log_error("A logical volume name cannot be given with "
+		log_error(0, "A logical volume name cannot be given with "
 			  "physical volumes.");
 		return ECMD_FAILED;
 	}
@@ -309,7 +309,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	argv += 2;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
-		log_error("Duplicate volume group name \"%s\"", vg_name_from);
+		log_error(0, "Duplicate volume group name \"%s\"", vg_name_from);
 		return ECMD_FAILED;
 	}
 
@@ -334,7 +334,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	rc = vg_lock_newname(cmd, vg_name_to);
 	if (rc == FAILED_LOCKING) {
-		log_error("Can't get lock for %s", vg_name_to);
+		log_error(0, "Can't get lock for %s", vg_name_to);
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
@@ -349,7 +349,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 			goto_bad;
 
 		if (new_vg_option_specified(cmd)) {
-			log_error("Volume group \"%s\" exists, but new VG "
+			log_error(0, "Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
 			goto_bad;
 		}
@@ -416,7 +416,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
-		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
+		log_error(0, "Cannot split: Nowhere to store metadata for new Volume Group");
 		goto_bad;
 	}
 
@@ -463,7 +463,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED);
 		if (vg_read_error(vg_to)) {
-			log_error("Volume group \"%s\" became inconsistent: "
+			log_error(0, "Volume group \"%s\" became inconsistent: "
 				  "please fix manually", vg_name_to);
 			goto_bad;
 		}
-- 
1.6.2.5


