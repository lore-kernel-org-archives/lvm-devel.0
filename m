From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 5 Mar 2010 17:59:30 -0600
Subject: [PATCH 9 of 10] LVM: mirrored log monitor fixes
Message-ID: <201003052359.o25NxUxM012655@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-mirrored-log-monitor-fixes.patch

If an event is received on a mirrored LV which also happens to
be the log of a mirror, strip off the '_mlog' component extension
of the name and pass the encapsulating LV to 'lvconvert --repair'.


Index: LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -148,6 +148,11 @@ static int _remove_failed_devices(const 
 		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
+	/* strip off the mirror component designations */
+	layer = strstr(lv, "_mlog");
+	if (layer)
+		*layer = '\0';
+
 	/* FIXME Is any sanity-checking required on %s? */
 	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */


