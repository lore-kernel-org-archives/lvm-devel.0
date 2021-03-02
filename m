From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:37 +0000 (GMT)
Subject: main - device_mapper: zero only secure buffers
Message-ID: <20210302215837.1D29F3834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73bea16c92cf6702a05634d80218297cb953ff36
Commit:        73bea16c92cf6702a05634d80218297cb953ff36
Parent:        00531186fc4ebc3cfeb934c5cb30b54d2f34d30d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 17:08:26 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:56:32 2021 +0100

device_mapper: zero only secure buffers

Securely erase before free() only dm_tasks marked as secure_data.
TODO: think about also using this for libdm/.
---
 device_mapper/ioctl/libdm-iface.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 1140798e6..116fa3dc1 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -493,7 +493,10 @@ static void _dm_task_free_targets(struct dm_task *dmt)
 
 	for (t = dmt->head; t; t = n) {
 		n = t->next;
-		_dm_zfree_string(t->params);
+		if (dmt->secure_data)
+			_dm_zfree_string(t->params);
+		else
+			free(t->params);
 		free(t->type);
 		free(t);
 	}
@@ -504,7 +507,10 @@ static void _dm_task_free_targets(struct dm_task *dmt)
 void dm_task_destroy(struct dm_task *dmt)
 {
 	_dm_task_free_targets(dmt);
-	_dm_zfree_dmi(dmt->dmi.v4);
+	if (dmt->secure_data)
+		_dm_zfree_dmi(dmt->dmi.v4);
+	else
+		free(dmt->dmi.v4);
 	free(dmt->dev_name);
 	free(dmt->mangled_dev_name);
 	free(dmt->newname);


