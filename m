From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 14:41:33 -0500
Subject: master - dmeventd: (workaround) fix mirror DSO to work with lvmetad
Message-ID: <201703091941.v29JfXKV026985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76f6951c3e8f0933df9730a42e9c46f273d1da24
Commit:        76f6951c3e8f0933df9730a42e9c46f273d1da24
Parent:        67ddc0c29289c454fbe6203473790bbcd12e3619
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 20:41:07 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 20:41:07 2017 +0100

dmeventd: (workaround) fix mirror DSO to work with lvmetad

Automatic dmeventd repair of mirrors with active lvmetad configured
(mirror_image_fault_policy = "allocate") fails because the lvscan
run before the repair in the mirror DSO does not update the
lvmetad cache properly thus "lvconvert --repair ..." fails.

Need to scan the mirror LV before and after the repair
to have proper cache content after the repair finished.
The cache can't be relied on or the repair will fail.

Resolves: rhbz1380521
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 4ec348f..181b839 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -111,6 +111,9 @@ static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconv
 		return 0;
 	}
 
+	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
+		log_warn("WARNING: Re-scan of mirrored device %s failed.", device);
+
 	log_info("Repair of mirrored device %s finished successfully.", device);
 
 	return 1;
@@ -188,7 +191,7 @@ int register_device(const char *device,
 		goto_bad;
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --repair --use-policies", device))
+				   "lvconvert --config global{use_lvmetad = 0}' --repair --use-policies", device))
 		goto_bad;
 
 	*user = state;


