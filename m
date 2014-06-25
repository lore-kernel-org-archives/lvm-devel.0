From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Jun 2014 14:24:39 +0000 (UTC)
Subject: master - filters: always reevaluate filter before creating a PV
Message-ID: <20140625142439.7F70060991@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e80884cd080cad7e10be4588e3493b9000649426
Commit:        e80884cd080cad7e10be4588e3493b9000649426
Parent:        e329c3146d91aba94f77a6d5da149e31b20ce60b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 25 16:19:27 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 25 16:24:28 2014 +0200

filters: always reevaluate filter before creating a PV

...to avoid using cached value (persistent filter) and therefore
not noticing any change made after last scan/filtering - the state
of the device may have changed, for example new signatures added.

$ lvm dumpconfig --type diff
allocation {
	use_blkid_wiping=0
}
devices {
	obtain_device_list_from_udev=0
}

$ cat /etc/lvm/cache/.cache | grep sda

$ vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "fedora" using metadata type lvm2

$ cat /etc/lvm/cache/.cache | grep sda
		"/dev/sda",

$ parted /dev/sda mklabel gpt
Information: You may need to update /etc/fstab.

$ parted /dev/sda print
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 134MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start  End  Size  File system  Name  Flags

$ cat /etc/lvm/cache/.cache | grep sda
		"/dev/sda",

====

Before this patch:
$ pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created

With this patch applied:
$ pvcreate /dev/sda
  Physical volume /dev/sda not found
  Device /dev/sda not found (or ignored by filtering).
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9db42d2..3ab7046 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Always reevaluate filters just before creating PV.
 
 Version 2.02.107 - 23rd June 2014
 =================================
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 599ebb6..0a6e9e9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1337,6 +1337,13 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
+	/*
+	 * Make sure we don't overwrite any existing signature
+	 * that may have been created after last time we did filtering.
+	 */
+	if (cmd->filter->wipe)
+		cmd->filter->wipe(cmd->filter);
+
 	/* Is there a pv here already? */
 	pv = find_pv_by_name(cmd, name, 1, 1);
 


