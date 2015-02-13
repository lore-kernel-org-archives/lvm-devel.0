From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:39 +0000 (UTC)
Subject: master - tolllib: process_each_pv: always use full_filter unconditionally when getting all devices
Message-ID: <20150213102939.4CECB6102A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0ce7285794da030a3e87d9b0a81217d6155c3bc
Commit:        e0ce7285794da030a3e87d9b0a81217d6155c3bc
Parent:        1c005b557a4b4d282d853e2437536f244bbf72b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 10:59:19 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 11:27:09 2015 +0100

tolllib: process_each_pv: always use full_filter unconditionally when getting all devices

(This reverts patch #d95c6154)

Filter complete device list through full_filter unconditionally when
we're getting the list of *all* devices even in case we're interested
only in fraction of those devices - the PVs, not the other devices
which are not PVs yet (e.g. pvs vs. pvs -a).

We need to do this full filtering whenever we're handling *complete*
list of devices, we need to be safe here, mainly if there are any
future changes and we'd forgot to change to use proper filtering then.
Also properly preventing duplicates if there are any block subsystem
components used (mpath, MD ...).

Thing here is that (under use_lvmetad=1), cmd->filter can be used
only if we're sure that the list of devices we're filtering contains
only PVs. We have to use cmd->full_filter otherwise (like it is in
case of _get_all_devices fn which acquires complete list of devices,
no matter if it is a PV or not).

Of course, cmd->full_filter is more extensive than cmd->filter
which is only a subset of full_filter.

We could optimize this in a way that if we're interested in PVs only
during process_each_pv processing (e.g. using pvs in contrast to pvs -a),
we'd get the list of PV devices directly from lvmetad from the
lvmcache_seed_infos_from_lvmetad fn call which currently updates
lvmcache only. We'd add an additional output arg for this fn to get
the list of PV devices directly in addition, without a need to iterate
over all devices which include non-PVs which we're not interested in
anyway, hence we could use only cmd->filter, not the cmd->full_filter.

So the code would look something like this:

static int _get_all_devices(....)
{
	struct device_id_list *dil;

	if (interested_in_pvs_only)
		lvmcache_seed_infos_from_lvmetad(cmd, &dil); /* new "dil" arg */
		/* the "dil" list would be filtered through cmd->filter inside lvmcache_seed_infos_from_lvmetad */
	else {
		lvmcache_seed_infos_from_lvmetad(cmd, NULL);
		dev_iter_create(cmd->full_filter)
		while (dev = dev_iter_get ...) {
			dm_list_add(all_devices, &dil->list);
		}
	}
}
---
 tools/toollib.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b0f603b..22fd9a6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2328,8 +2328,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices,
-			    int use_full_filter)
+static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -2338,7 +2337,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if (!(iter = dev_iter_create(use_full_filter ? cmd->full_filter : cmd->filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}
@@ -2735,7 +2734,7 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
 	 */
-	if ((ret = _get_all_devices(cmd, &all_devices, process_all_devices) != ECMD_PROCESSED)) {
+	if ((ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
 		stack;
 		return ret;
 	}


