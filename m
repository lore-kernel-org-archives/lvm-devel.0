From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 12 Oct 2023 11:27:15 +0000
Subject: [Git][lvmteam/lvm2][main] _create_and_load_v4: propagate ioctl errors back to caller
Message-ID: <6527d813470f1_2ca5744647ed@gitlab-sidekiq-low-urgency-cpu-bound-v2-77dd58995b-l6dbp.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
25ef7a7b by Lennart Poettering at 2023-10-11T15:35:33+02:00
_create_and_load_v4: propagate ioctl errors back to caller

When setting up dm-verity devices with signed root hashes it is very
useful to have a recognizable error code when a key is not present in
the kernel keyring. Turns out the kernel actually returns ENOKEY in that
case, but this gets lost in libdevmapper.

This fixes this: in _create_and_load_v4() it copies the error code from
the ioctl from the sub-tasks back to the main task field on failure.

This is not enough to make libcryptsetup actually propagate the ENOKEY
correctly, that also needs a patch to libcryptsetup, but this is part of
the puzzle.

- - - - -


1 changed file:

- libdm/ioctl/libdm-iface.c


Changes:

=====================================
libdm/ioctl/libdm-iface.c
=====================================
@@ -1478,7 +1478,7 @@ static int _create_and_load_v4(struct dm_task *dmt)
 {
 	struct dm_info info;
 	struct dm_task *task;
-	int r;
+	int r, ioctl_errno = 0;
 	uint32_t cookie;
 
 	/* Use new task struct to create the device */
@@ -1504,8 +1504,10 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->cookie_set = dmt->cookie_set;
 	task->add_node = dmt->add_node;
 
-	if (!dm_task_run(task))
+	if (!dm_task_run(task)) {
+		ioctl_errno = task->ioctl_errno;
 		goto_bad;
+	}
 
 	if (!dm_task_get_info(task, &info) || !info.exists)
 		goto_bad;
@@ -1536,6 +1538,8 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->ima_measurement = dmt->ima_measurement;
 
 	r = dm_task_run(task);
+	if (!r)
+		ioctl_errno = task->ioctl_errno;
 
 	task->head = NULL;
 	task->tail = NULL;
@@ -1582,12 +1586,18 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	if (!dm_task_run(dmt))
 		log_error("Failed to revert device creation.");
 
+	if (ioctl_errno != 0)
+		dmt->ioctl_errno =  ioctl_errno;
+
 	return 0;
 
       bad:
 	dm_task_destroy(task);
 	_udev_complete(dmt);
 
+	if (ioctl_errno != 0)
+		dmt->ioctl_errno =  ioctl_errno;
+
 	return 0;
 }
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/25ef7a7b1a876f491bd361369423d7309358f6c1

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/25ef7a7b1a876f491bd361369423d7309358f6c1
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231012/7aa01765/attachment-0001.htm>
