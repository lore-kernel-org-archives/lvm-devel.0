From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Fri, 06 Oct 2023 17:25:51 +0000
Subject: [Git][lvmteam/lvm2][main] device_id: fix lvmdevices update segfault
Message-ID: <6520431f5bad0_2aa53349051f@gitlab-sidekiq-low-urgency-cpu-bound-v2-845b4dd648-85wf5.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
25a87ea1 by David Teigland at 2023-10-06T12:24:34-05:00
device_id: fix lvmdevices update segfault

>From commit 1901a47df12
&quot;device_id: fix conditions for device_ids_refresh&quot;

- - - - -


1 changed file:

- lib/device/device_id.c


Changes:

=====================================
lib/device/device_id.c
=====================================
@@ -2546,7 +2546,8 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			dev = du->dev;
 			devname = dev_name(du->dev);
 
-			if (!device_list_find_dev(scanned_devs, du->dev) || (du->dev->flags & DEV_SCAN_NOT_READ)) {
+			if ((scanned_devs && !device_list_find_dev(scanned_devs, du->dev)) ||
+			    (du->dev->flags & DEV_SCAN_NOT_READ)) {
 				log_debug("Validate %s %s PVID %s on %s: not scanned",
 					  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", devname);
 			} else {



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/25a87ea16aba335b5f33621cd5ac6ff651f0bbb1

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/25a87ea16aba335b5f33621cd5ac6ff651f0bbb1
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231006/8cd6ab23/attachment.htm>
