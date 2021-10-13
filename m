From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Oct 2021 18:43:49 +0000 (GMT)
Subject: main - devices file: unmatching system id should just be warning
Message-ID: <20211013184349.076003858015@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=272d1ccac8654c0d74ecf255d13de0a6222ff96f
Commit:        272d1ccac8654c0d74ecf255d13de0a6222ff96f
Parent:        062ea3c4181ef158620556bbab2358bc76eeab90
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 13 13:34:46 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 13 13:42:04 2021 -0500

devices file: unmatching system id should just be warning

there are likely more cases than not where the systemid
does not match and the command should still run.
---
 lib/device/device_id.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index ce43e61ca..e4208c56b 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -543,11 +543,8 @@ int device_ids_read(struct cmd_context *cmd)
 			log_debug("read devices file systemid %s", _devices_file_systemid);
 			if ((!cmd->system_id && _devices_file_systemid[0]) ||
 			    (cmd->system_id && strcmp(cmd->system_id, _devices_file_systemid))) {
-				log_warn("WARNING: ignoring devices file with wrong system id %s vs local %s.",
+				log_warn("WARNING: devices file has unmatching system id %s vs local %s.",
 					  _devices_file_systemid[0] ? _devices_file_systemid : "none", cmd->system_id ?: "none");
-				free_dus(&cmd->use_devices);
-				ret = 0;
-				goto out;
 			}
 			continue;
 		}
@@ -613,7 +610,6 @@ int device_ids_read(struct cmd_context *cmd)
 
 		dm_list_add(&cmd->use_devices, &du->list);
 	}
-out:
 	if (fclose(fp))
 		stack;
 


