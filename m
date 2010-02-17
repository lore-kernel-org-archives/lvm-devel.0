From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 17 Feb 2010 11:57:49 -0600
Subject: [PATCH 13 of 13] LVM: 2 mirrored log monitor fixes
Message-ID: <201002171757.o1HHvnpB005275@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm2-mirrored-log-monitor-fixes.patch

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
+		layer = '\0';
+
 	/* FIXME Is any sanity-checking required on %s? */
 	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */


