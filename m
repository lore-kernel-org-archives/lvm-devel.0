From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:38 -0400
Subject: master - process_each_pv handle outdated pvs
Message-ID: <201906072108.x57L8c94005318@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89914a541f081e1c234a455c17d82269cd90364b
Commit:        89914a541f081e1c234a455c17d82269cd90364b
Parent:        ab61a6d85da4e4f1d540e40ebac77999bf3c9a57
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 13:00:33 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

process_each_pv handle outdated pvs

process_each_pv should account for outdated pvs
in the list of all devices it is processing.
---
 tools/toollib.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8e882e9..78b1745 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4156,12 +4156,16 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct device_id_list *dil;
+	struct device_list *devl;
+	struct dm_list outdated_devs;
 	const char *pv_name;
 	int process_pv;
 	int do_report_ret_code = 1;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
+	dm_list_init(&outdated_devs);
+
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
 
 	vg_uuid[0] = '\0';
@@ -4247,6 +4251,12 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			break;
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
+
+	if (!is_orphan_vg(vg->name))
+		lvmcache_get_outdated_devs(cmd, vg->name, (const char *)&vg->id, &outdated_devs);
+	dm_list_iterate_items(devl, &outdated_devs)
+		_device_list_remove(all_devices, devl->dev);
+
 	do_report_ret_code = 0;
 out:
 	if (do_report_ret_code)


