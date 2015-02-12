From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Feb 2015 12:46:32 +0000 (UTC)
Subject: master - toollib: process_each_pv: do not acquire list of all devices if not necessary
Message-ID: <20150212124632.90CA161188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d38d047eecc16fdcaab7e7452ac68d673afdf674
Commit:        d38d047eecc16fdcaab7e7452ac68d673afdf674
Parent:        0e9f3dba75af605934a130d9a0ae9517229b0661
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 12 13:28:00 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 12 13:46:11 2015 +0100

toollib: process_each_pv: do not acquire list of all devices if not necessary

List of all devices is only needed if we want to process devices
which are not PVs (e.g. pvs -a). But if this is not the case, it's
useless to get the list of all devices and then discard it without
any use, which is exactly what happened in process_each_pv where
the code was never reached and the list was unused if we were
processing just PVs, not all PV-capable devices:

int process_each_pv(...)
{
	...
	process_all_devices = process_all_pvs &&
			      (cmd->command->flags & ENABLE_ALL_DEVS) &&
			      arg_count(cmd, all_ARG);
	...
	/*
	 * If the caller wants to process all devices (not just PVs), then all PVs
	 * from all VGs are processed first, removing them from all_devices.  Then
	 * any devs remaining in all_devices are processed.
	*/
	_get_all_devices(cmd, &all_devices);
	...
	ret = _process_pvs_in_vgs(...);
	...
	if (!process_all_devices)
		goto out;

        ret = _process_device_list(cmd, &all_devices, handle, process_single_pv);
	...
}

This patch adds missing check for "process_all_devices" and it gets the
list of all (including non-PV) devices only if needed:
---
 tools/toollib.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bdf6494..410122c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2736,7 +2736,8 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
 	 */
-	if ((ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
+	if (process_all_devices &&
+	    (ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}


