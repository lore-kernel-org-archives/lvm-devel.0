From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 23 Sep 2013 14:07:09 -0400 (EDT)
Subject: [PATCH] libdm: fix races with udev
In-Reply-To: <523AB2AE.3020103@redhat.com>
References: <alpine.LRH.2.02.1309161523010.9077@file01.intranet.prod.int.rdu2.redhat.com>
	<523AB2AE.3020103@redhat.com>
Message-ID: <alpine.LRH.2.02.1309231404270.4637@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Thu, 19 Sep 2013, Peter Rajnoha wrote:

> On 09/16/2013 09:23 PM, Mikulas Patocka wrote:
> > libdm: fix races with udev
> > 
> > On newer systems (Debian 6 and newer), udev manages nodes in /dev/mapper
> > directory. It creates, deletes and renames the nodes according to the
> > state of the kernel driver.
> > 
> > dmsetup tries to manage nodes in /dev/mapper too, so it can race with
> > udev. dmsetup checks if the node was created/deleted/renamed with the stat
> > syscall, and skips the operation if it was. However, if udev
> > creates/deletes/renames the node after the stat syscall and before the
> > mknod/unlink/rename syscall, dmsetup reports an error.
> > 
> 
> These checks are performed after udev is synchronized (the dm_udev_wait call)
> and after the udev processing is complete, so we normally shouldn't get into this
> problem unless there is some bug in certain version of lvm2/udev rules.
> 
> Is this reproducible with upstream code as well or was that with some older version only
> that is currently in Debian?
> 
> Peter

This race condition can be easily provoked with this patch. Apply it and 
try dmsetup create/remove/rename.

One Debian 6, races in all three operations create/remove/rename can be 
provoked.

On Debian Sid and on RHEL 6, only races in create/rename can be provoked. 
Race in remove doesn't happen.

Mikulas


Index: LVM2.2.02.102/libdm/libdm-common.c
===================================================================
--- LVM2.2.02.102.orig/libdm/libdm-common.c	2013-09-23 16:51:29.000000000 +0200
+++ LVM2.2.02.102/libdm/libdm-common.c	2013-09-23 19:10:32.028514000 +0200
@@ -964,6 +964,8 @@
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
+	fprintf(stderr, "sleeping 1\n"); sleep(3);
+
 	(void) dm_prepare_selinux_context(path, S_IFBLK);
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
@@ -998,6 +1000,8 @@
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
+	fprintf(stderr, "sleeping 2\n"); sleep(3);
+
 	if (unlink(path) < 0) {
 		log_error("Unable to unlink device node for '%s'", dev_name);
 		return 0;
@@ -1054,6 +1058,8 @@
 			 "Falling back to direct node rename.",
 			 oldpath, newpath);
 
+	fprintf(stderr, "sleeping 3\n"); sleep(3);
+
 	if (rename(oldpath, newpath) < 0) {
 		log_error("Unable to rename device node from '%s' to '%s'",
 			  old_name, new_name);


