From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Jan 2015 20:21:02 +0000 (UTC)
Subject: master - toollib: pvs -a should display VG name for each duplicate PV
Message-ID: <20150114202102.0FB66606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a7c47af0e8840f4f5b5c39294e9f378de386a50
Commit:        3a7c47af0e8840f4f5b5c39294e9f378de386a50
Parent:        57d74a45a05ef14655fbb575586738b6a4cfd4da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 14 14:16:03 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 14 14:16:03 2015 -0600

toollib: pvs -a should display VG name for each duplicate PV

Previously, 'pvs -a' displayed the VG name for only the device
associated with the cached PV (pv->dev), and other duplicate
devices would have a blank VG name.  This commit displays the
VG name for each of the duplicate devices.  The cost of doing
this is not small: for each PV processed, the list of all
devices must be searched for duplicates.
---
 tools/toollib.c |   45 ++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 472e362..41e1581 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2126,6 +2126,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 			goto out;
 		}
 
+		strncpy(dil->pvid, dev->pvid, ID_LEN);
 		dil->dev = dev;
 		dm_list_add(all_devices, &dil->list);
 	}
@@ -2213,7 +2214,8 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct dm_list *all_devices,
 			      struct dm_list *arg_devices,
 			      struct dm_list *arg_tags,
-			      int process_all,
+			      int process_all_pvs,
+			      int process_all_devices,
 			      int skip,
 			      void *handle,
 			      process_single_pv_fn_t process_single_pv)
@@ -2235,7 +2237,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		pv = pvl->pv;
 		pv_name = pv_dev_name(pv);
 
-		process_pv = process_all;
+		process_pv = process_all_pvs;
 
 		/* Remove each arg_devices entry as it is processed. */
 
@@ -2321,12 +2323,38 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 					lvmcache_replace_dev(cmd, pv, dev_orig);
 				}
 			}
+
+			/*
+			 * This is another rare and obscure case where multiple
+			 * duplicate devices are being displayed by pvs -a, and
+			 * we want each of them to be displayed in the context
+			 * of this VG, so that this VG name appears next to it.
+			 * FIXME: the repeated search through all devices is a
+			 * high cost to pay for a very rare benefit.
+			 */
+
+			if (process_all_devices) {
+				while ((dil = _device_list_find_pvid(all_devices, pv))) {
+					_device_list_remove(all_devices, dil->dev);
+
+					dev_orig = pv->dev;
+					lvmcache_replace_dev(cmd, pv, dil->dev);
+
+					ret = process_single_pv(cmd, vg, pv, handle);
+					if (ret != ECMD_PROCESSED)
+						stack;
+					if (ret > ret_max)
+						ret_max = ret;
+
+					lvmcache_replace_dev(cmd, pv, dev_orig);
+				}
+			}
 		}
 
 		/*
 		 * When processing only specific PVs, we can quit once they've all been found.
 	 	 */
-		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
+		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			break;
 	}
 
@@ -2349,7 +2377,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			       struct dm_list *all_devices,
 			       struct dm_list *arg_devices,
 			       struct dm_list *arg_tags,
-			       int process_all,
+			       int process_all_pvs,
+			       int process_all_devices,
 			       void *handle,
 			       process_single_pv_fn_t process_single_pv)
 {
@@ -2383,7 +2412,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		 */
 		
 		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_devices, arg_tags,
-					 process_all, skip, handle, process_single_pv);
+					 process_all_pvs, process_all_devices, skip,
+					 handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
 		if (ret > ret_max)
@@ -2395,7 +2425,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			unlock_and_release_vg(cmd, vg, vg->name);
 
 		/* Quit early when possible. */
-		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
+		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			return ret_max;
 	}
 
@@ -2470,7 +2500,8 @@ int process_each_pv(struct cmd_context *cmd,
 	}
 
 	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
-				  &arg_devices, &arg_tags, process_all_pvs,
+				  &arg_devices, &arg_tags,
+				  process_all_pvs, process_all_devices,
 				  handle, process_single_pv);
 	if (ret != ECMD_PROCESSED)
 		stack;


