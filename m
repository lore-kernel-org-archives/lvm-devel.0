From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 Aug 2021 19:50:08 +0000 (GMT)
Subject: main - pvremove: apply devices file
Message-ID: <20210827195008.0FB443857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=350f8845bd39dd7aaf5a52ad5deff6859fd06568
Commit:        350f8845bd39dd7aaf5a52ad5deff6859fd06568
Parent:        12ba43ccd0cac480b4da0fb8457db83b4b50b722
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 27 14:48:33 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 27 14:48:33 2021 -0500

pvremove: apply devices file

pvremove was wrongly allowed to operate on a device
not listed in the devices file.
---
 tools/toollib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6d61f49e6..9d488c5a7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5333,7 +5333,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	cmd->use_full_md_check = 1;
 
-	if (cmd->enable_devices_file)
+	if (cmd->enable_devices_file && !pp->is_remove)
 		cmd->filter_deviceid_skip = 1;
 
 	log_debug("Scanning and filtering device args (%u).", dm_list_size(&scan_devs));
@@ -5559,7 +5559,7 @@ do_command:
 	dm_list_iterate_items(devl, &rescan_devs)
 		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
 
-	if (cmd->enable_devices_file)
+	if (cmd->enable_devices_file && !pp->is_remove)
 		cmd->filter_deviceid_skip = 1;
 
 	log_debug("Rescanning and filtering device args with exclusive open");


