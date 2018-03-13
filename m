From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:15 -0400
Subject: master - dmsetup: update messages
Message-ID: <201803131204.w2DC4Fq0002409@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ac7cc0ac858462522ef129db4359de69bc6e90d
Commit:        7ac7cc0ac858462522ef129db4359de69bc6e90d
Parent:        9476cf8cdc8ead9dde4b5f768df878f41091c50c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:56:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: update messages

---
 tools/dmsetup.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index df148e4..06eba19 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -636,14 +636,13 @@ static int _do_timerfd_wait(void)
 
 	if (bytes < 0) {
 		/* EBADF from invalid timerfd or EINVAL from too small buffer. */
-		log_error("Interval timer wait failed: %s",
-			  strerror(errno));
+		log_error("Interval timer wait failed: %s.", strerror(errno));
 		return 0;
 	}
 
 	/* read(2) on a timerfd descriptor is guaranteed to return 8 bytes. */
 	if (bytes != 8)
-		log_error("Unexpected byte count on timerfd read: " FMTssize_t, bytes);
+		log_error("Unexpected byte count on timerfd read: " FMTssize_t ".", bytes);
 
 	/* FIXME: attempt to rebase clock? */
 	if (expired > 1)
@@ -708,7 +707,7 @@ static int _do_usleep_wait(void)
 	} else {
 		dm_timestamp_get(_now);
 		delta_t = dm_timestamp_delta(_now, _start_timestamp);
-		log_debug("Interval timer drift: "FMTd64,
+		log_debug("Interval timer drift: "FMTd64".",
 			  (delta_t % _interval));
 
 		/* FIXME: usleep timer drift over large counts. */
@@ -816,12 +815,12 @@ static int _update_interval_times(void)
 		delta_t = _interval;
 
 		/* start the first cycle */
-		log_debug("Beginning first interval");
+		log_debug("Beginning first interval.");
 		_new_interval = 1;
 	}
 
-	log_debug("Interval     #%-4"PRIu64"     time delta: %12"
-		  PRIu64"ns", interval_num, delta_t);
+	log_debug("Interval     #%-4"PRIu64"     time delta: %12"PRIu64"ns.",
+		  interval_num, delta_t);
 
 	if (_new_interval) {
 		/* Update timestamp and interval and clear _new_interval */
@@ -832,9 +831,9 @@ static int _update_interval_times(void)
 		/*
 		 * Log interval duration and current error.
 		 */
-		log_debug("Interval     #%-5"PRIu64"   current err: %12"PRIi64"ns",
+		log_debug("Interval     #%-5"PRIu64"   current err: %12"PRIi64"ns.",
 			  interval_num, ((int64_t)_last_interval - (int64_t)_interval));
-		log_debug("End interval #%-9"PRIu64"  duration: %12"PRIu64"ns",
+		log_debug("End interval #%-9"PRIu64"  duration: %12"PRIu64"ns.",
 			  interval_num, _last_interval);
 	}
 
@@ -924,7 +923,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		/* Update timestamps and handle end-of-interval accounting. */
 		_update_interval_times();
 
-		log_debug("Adjusted sample interval duration: %12"PRIu64"ns", _last_interval);
+		log_debug("Adjusted sample interval duration: %12"PRIu64"ns.", _last_interval);
 		/* use measured approximation for calculations */
 		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
 	} else if (!obj.stats && (_report_type & DR_STATS_META)
@@ -1907,7 +1906,7 @@ static int _udevcomplete_all(CMD_ARGS)
 			if (semctl(sid, 0, IPC_RMID, 0) < 0) {
 				log_error("Could not cleanup notification semaphore "
 					  "with semid %d and cookie value "
-					  FMTu32 " (0x" FMTx32 ")", sid,
+					  FMTu32 " (0x" FMTx32 ").", sid,
 					  sdata.sem_perm.__key, sdata.sem_perm.__key);
 				continue;
 			}
@@ -5153,7 +5152,7 @@ static int _stats_group_segments(struct dm_stats *dms, uint64_t *region_ids,
 		       regions, group_id, (alias) ? " with alias " : "",
 		       (alias) ? : "");
 	else
-		log_error("Failed to create group for regions %s", regions);
+		log_error("Failed to create group for regions %s.", regions);
 
 bad:
 	dm_free(regions);
@@ -5434,7 +5433,7 @@ static int _stats_create_file(CMD_ARGS)
 						  bounds, alias);
 
 	if (!regions) {
-		log_error("Could not create regions from file %s", abspath);
+		log_error("Could not create regions from file %s.", abspath);
 		goto bad;
 	}
 
@@ -5445,7 +5444,7 @@ static int _stats_create_file(CMD_ARGS)
 	}
 
 	if (close(fd))
-		log_error("Error closing %s", abspath);
+		log_error("Error closing %s.", abspath);
 
 	fd = -1;
 
@@ -7141,7 +7140,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			else if (!strcasecmp(optarg, "hex"))
 				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLING_HEX;
 			else {
-				log_error("Unknown name mangling mode");
+				log_error("Unknown name mangling mode.");
 				return 0;
 			}
 			dm_set_name_mangling_mode((dm_string_mangling_t) _int_args[MANGLENAME_ARG]);


