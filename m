From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:23 -0500
Subject: master - libdm: set maj:min while creating and reloading device
Message-ID: <93901.119121009462100423@us-mta-354.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4353823306800fda4184a4a4278d036ca345993b
Commit:        4353823306800fda4184a4a4278d036ca345993b
Parent:        df0bc5081c1b84c2ae7c8d8dc92305f90f161683
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:28:44 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:42:59 2019 +0100

libdm: set maj:min while creating and reloading device

Add maj:min to the task structure for RELOAD - which is now
handled in _flatten() and will just skip passing device name.
---
 libdm/ioctl/libdm-iface.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index ae44abf..7ad549c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1429,6 +1429,7 @@ static int _check_uevent_generated(struct dm_ioctl *dmi)
 
 static int _create_and_load_v4(struct dm_task *dmt)
 {
+	struct dm_info info;
 	struct dm_task *task;
 	int r;
 	uint32_t cookie;
@@ -1459,6 +1460,9 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	if (!dm_task_run(task))
 		goto_bad;
 
+	if (!dm_task_get_info(task, &info) || !info.exists)
+		goto_bad;
+
 	dm_task_destroy(task);
 
 	/* Next load the table */
@@ -1476,6 +1480,8 @@ static int _create_and_load_v4(struct dm_task *dmt)
 		goto revert;
 	}
 
+	task->major = info.major;
+	task->minor = info.minor;
 	task->read_only = dmt->read_only;
 	task->head = dmt->head;
 	task->tail = dmt->tail;



