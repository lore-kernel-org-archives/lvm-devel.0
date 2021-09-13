From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Sep 2021 19:11:59 +0000 (GMT)
Subject: main - lvmdevices: allow deviceidtype with addpvid
Message-ID: <20210913191159.979183857409@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8935dfee56fe2cfb29152f0af2a4c4c32e62895b
Commit:        8935dfee56fe2cfb29152f0af2a4c4c32e62895b
Parent:        9857b5a3dc7b23295e47e04c5c338d189c3502d5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 13 14:11:07 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 13 14:11:07 2021 -0500

lvmdevices: allow deviceidtype with addpvid

in addition to using with adddev
---
 tools/command-lines.in | 1 +
 tools/lvmdevices.c     | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 73a4c57f9..e63b2bcc3 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1439,6 +1439,7 @@ ID: lvmdevices_edit
 DESC: Remove a device from the devices file.
 
 lvmdevices --addpvid String
+OO: --deviceidtype String
 ID: lvmdevices_edit
 DESC: Find the device with the given PVID and add it to the devices file.
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 367536d6a..8d9634848 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -127,6 +127,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 	struct device_list *devl;
 	struct device *dev;
 	struct dev_use *du, *du2;
+	const char *deviceidtype;
 	int changes = 0;
 
 	dm_list_init(&search_pvids);
@@ -269,7 +270,6 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_is_set(cmd, adddev_ARG)) {
 		const char *devname;
-		const char *deviceidtype;
 
 		if (!(devname = arg_str_value(cmd, adddev_ARG, NULL)))
 			goto_bad;
@@ -366,7 +366,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 			goto bad;
 		}
 		dm_list_iterate_items(devl, &found_devs) {
-			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL))
+			deviceidtype = arg_str_value(cmd, deviceidtype_ARG, NULL);
+			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, deviceidtype, NULL))
 				goto_bad;
 		}
 		if (!device_ids_write(cmd))


