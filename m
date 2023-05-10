From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2023 14:22:30 +0000 (GMT)
Subject: main - cov: hide some false positives
Message-ID: <20230510142230.B4194385357B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d418fc14f48ba8feb3f5c561f5626a673aef4863
Commit:        d418fc14f48ba8feb3f5c561f5626a673aef4863
Parent:        cc7c41abbdb51a1e6c60c4a79aa56fe40ab7937a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 13:01:37 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 16:19:46 2023 +0200

cov: hide some false positives

Hide some false positives.

Note: there must not a be blank line after coverity hiding comment.
---
 daemons/dmeventd/dmeventd.c                  | 2 ++
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c | 1 +
 device_mapper/libdm-file.c                   | 1 -
 libdm/dm-tools/dmsetup.c                     | 1 +
 libdm/libdm-file.c                           | 1 -
 tools/toollib.c                              | 2 +-
 6 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d89ab4af8..490768b63 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -987,6 +987,7 @@ static void _monitor_unregister(void *arg)
 	DEBUGLOG("Unregistering monitor for %s.", thread->device.name);
 	_unregister_for_timeout(thread);
 
+	/* coverity[missing_lock] no missing lock here */
 	if ((thread->status != DM_THREAD_REGISTERING) &&
 	    !_do_unregister_device(thread))
 		log_error("%s: %s unregister failed.", __func__,
@@ -1969,6 +1970,7 @@ static void _daemonize(void)
 		(void) close(fd);
 	}
 
+	/* coverity[leaked_handle] dont't care */
 	if ((open("/dev/null", O_RDONLY) < 0) ||
 	    (open("/dev/null", O_WRONLY) < 0) ||
 	    (open("/dev/null", O_WRONLY) < 0))
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 56498170f..cddf6cee8 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -123,6 +123,7 @@ struct dm_pool *dmeventd_lvm2_pool(void)
 
 int dmeventd_lvm2_run(const char *cmdline)
 {
+	/* coverity[missing_lock] no locking for run part */
 	return (lvm2_run(_lvm_handle, cmdline) == LVM2_COMMAND_SUCCEEDED);
 }
 
diff --git a/device_mapper/libdm-file.c b/device_mapper/libdm-file.c
index 74d9968df..9361379a4 100644
--- a/device_mapper/libdm-file.c
+++ b/device_mapper/libdm-file.c
@@ -223,7 +223,6 @@ retry_fcntl:
 	}
 
 	/* coverity[leaked_handle] intentional leak of fd handle here  */
-
 	return 1;
 
 fail_close_unlink:
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index ea03d66c8..5e485af33 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -899,6 +899,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 			goto_out;
 		if (_selection_cmd && selected) {
 			device_name = (char*) dm_task_get_name(dmt);
+			/* coverity[overrun-buffer-val] _setgeometry never called from this place */
 			if (!_selection_cmd->fn(_selection_cmd, NULL, 1, &device_name, NULL, 1))
 				goto_out;
 		}
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 2e5f14f6f..292b56ce7 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -222,7 +222,6 @@ retry_fcntl:
 	}
 
 	/* coverity[leaked_handle] intentional leak of fd handle here  */
-
 	return 1;
 
 fail_close_unlink:
diff --git a/tools/toollib.c b/tools/toollib.c
index c2d93aaf9..6b590189b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -88,6 +88,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 		_exit(ECMD_FAILED);
 	}
 
+	/* coverity[leaked_handle] don't care */
 	if ((dup2(null_fd, STDIN_FILENO) < 0)  || /* reopen stdin */
 	    (dup2(null_fd, STDOUT_FILENO) < 0) || /* reopen stdout */
 	    (dup2(null_fd, STDERR_FILENO) < 0)) { /* reopen stderr */
@@ -113,7 +114,6 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	}
 
 	/* coverity[leaked_handle] null_fd does not leak here */
-
 	return 1;
 }
 

