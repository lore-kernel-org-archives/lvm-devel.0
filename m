From: David Teigland <teigland@sourceware.org>
Date: Wed,  1 Dec 2021 16:08:31 +0000 (GMT)
Subject: main - devices file: don't write in test mode
Message-ID: <20211201160831.B736E3858034@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5402e55f6b9d3a5f407502ce5c7a8a5bfd12243
Commit:        d5402e55f6b9d3a5f407502ce5c7a8a5bfd12243
Parent:        71e7ebb3e409be91b6c29e25ebfdd73c27f02902
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 1 10:08:08 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 1 10:08:08 2021 -0600

devices file: don't write in test mode

---
 lib/device/device_id.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 06d64a494..bfee7d418 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -678,6 +678,9 @@ int device_ids_write(struct cmd_context *cmd)
 		cmd->enable_devices_file = 1;
 	}
 
+	if (test_mode())
+		return 1;
+
 	if (_devices_file_version[0]) {
 		if (sscanf(_devices_file_version, "%u.%u.%u", &df_major, &df_minor, &df_counter) != 3) {
 			/* don't update a file we can't parse */


