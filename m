From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 16 Jul 2010 09:39:47 -0500
Subject: [PATCH] check for running cluster log daemon, not just log module
Message-ID: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

	brassow

It's not enough to check for the kernel module in the case of cluster
mirrors, we must also check that the log daemon (cmirrord) is running.
The log module can be auto-loaded, but the daemon cannot be
"auto-started".  Failing to check for the daemon produces cryptic
messages that customers have a hard time deciphering.  (The system
messages do report that the log daemon is not running, but people
don't seem to find this message easily.)

Here are examples of what is printed when the module is available,
but the log daemon has not been started.

[root at bp-01 LVM2]# lvcreate -m1 -l1 -n lv vg
  Shared cluster mirrors are not available.

[root at bp-01 LVM2]# lvcreate -m1 -l1 -n lv vg -v
    Setting logging type to disk
    Finding volume group "vg"
    Archiving volume group "vg" metadata (seqno 3).
    Creating logical volume lv
    Executing: /sbin/modprobe dm-log-userspace
    Cluster mirror log daemon is not running
  Shared cluster mirrors are not available.
    Creating volume group backup "/etc/lvm/backup/vg" (seqno 4).

TODO:
1. check that lvconvert is also covered
2. check pvmove is not negatively affected (should improve pvmove too)

RFC-by: Jonathan Brassow <jbrassow@redhat.com>
Index: LVM2/libdm/libdevmapper.h
===================================================================
--- LVM2.orig/libdm/libdevmapper.h
+++ LVM2/libdm/libdevmapper.h
@@ -988,6 +988,13 @@ int dm_asprintf(char **buf, const char *
  */
 int dm_create_lockfile(const char* lockfile);
 
+/*
+ * Query whether a daemon is running based on its lockfile
+ *
+ * Returns: 1 if running, 0 if not
+ */
+int dm_daemon_is_running(const char* lockfile);
+
 /*********************
  * regular expressions
  *********************/
Index: LVM2/libdm/libdm-file.c
===================================================================
--- LVM2.orig/libdm/libdm-file.c
+++ LVM2/libdm/libdm-file.c
@@ -166,3 +166,30 @@ fail:
 
 	return 0;
 }
+
+int dm_daemon_is_running(const char* lockfile)
+{
+	int fd;
+	struct flock lock;
+
+	if((fd = open(lockfile, O_RDONLY)) < 0)
+		return 0;
+
+	lock.l_type = F_WRLCK;
+	lock.l_start = 0;
+	lock.l_whence = SEEK_SET;
+	lock.l_len = 0;
+	if (fcntl(fd, F_GETLK, &lock) < 0) {
+		log_error("Cannot check lock status of lockfile [%s], error was [%s]",
+			  lockfile, strerror(errno));
+		if (close(fd))
+			stack;
+		return 0;
+	}
+
+	/* Should we also read and check pid? */
+	if (close(fd))
+		stack;
+
+	return (lock.l_type == F_UNLCK) ? 0 : 1;
+}
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -81,6 +81,36 @@ int lv_is_mirrored(const struct logical_
 }
 
 /*
+ * cluster_mirror_is_available
+ *
+ * Check if the proper kernel module and log daemon are running.
+ * Caller should check for 'vg_is_clustered(lv->vg)' before making
+ * this call.
+ *
+ * Returns: 1 if available, 0 otherwise
+ */
+static int cluster_mirror_is_available(struct logical_volume *lv)
+{
+	unsigned attr = 0;
+	struct cmd_context *cmd = lv->vg->cmd;
+	const struct segment_type *segtype;
+
+	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
+		return_0;
+
+	if (!segtype->ops->target_present)
+		return_0;
+
+	if (!segtype->ops->target_present(lv->vg->cmd, NULL, &attr))
+		return_0;
+
+	if (!(attr & MIRROR_LOG_CLUSTERED))
+		return 0;
+
+	return 1;
+}
+
+/*
  * Returns the number of mirrors of the LV
  */
 uint32_t lv_mirror_count(const struct logical_volume *lv)
@@ -1940,6 +1970,12 @@ int lv_add_mirrors(struct cmd_context *c
 		return 0;
 	}
 
+	if (vg_is_clustered(lv->vg) &&  !(lv->status & ACTIVATE_EXCL) &&
+	    !cluster_mirror_is_available(lv)) {
+		log_error("Shared cluster mirrors are not available.");
+		return 0;
+	}
+
 	/* For corelog mirror, activation code depends on
 	 * the global mirror_in_sync status. As we are adding
 	 * a new mirror, it should be set as 'out-of-sync'
Index: LVM2/lib/mirror/mirrored.c
===================================================================
--- LVM2.orig/lib/mirror/mirrored.c
+++ LVM2/lib/mirror/mirrored.c
@@ -519,6 +519,19 @@ static int _mirrored_target_present(stru
 					_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 			} else if (module_present(cmd, "log-userspace"))
 				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+
+			if (!(_mirror_attributes & MIRROR_LOG_CLUSTERED))
+				log_verbose("Cluster mirror log module is not available");
+
+			/*
+			 * The cluster mirror log daemon must be running,
+			 * otherwise, the kernel module will fail to make
+			 * contact.
+			 */
+			if (!dm_daemon_is_running(CMIRRORD_PIDFILE)) {
+				log_verbose("Cluster mirror log daemon is not running");
+				_mirror_attributes &= ~MIRROR_LOG_CLUSTERED;
+			}
 		}
 		*attributes = _mirror_attributes;
 	}



