From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:33 +0200
Subject: [RFC][PATCH v3 00/16] fsadm update
Message-ID: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello again,

this is third update of the fsadm.

Changes:

version 2:
The main difference is that all the big features are collapsed into one
patch for better review (since some of the features depends on each other
and has been developed in that way). Also one new test is added to exercise
"remove" command.

version 3:
In version 2 some patches was unintentionally squashed together, which is
fixed in this version.

Here is a link to the first version of the patch set:
http://www.redhat.com/archives/linux-lvm/2011-September/msg00046.html

Comments are welcomed.

Thanks!
-Lukas

-- 
[PATCH v3 01/18] fsadm: Add new commands create,list,add and remove
[PATCH v3 02/18] fsadm: Make all internal math in kilobytes
[PATCH v3 03/18] fsadm: Add simple configuration file
[PATCH v3 04/18] fsadm: Use DEFAULT_DEVICE_POOL when creating volume
[PATCH v3 05/18] fsadm: Add LVOL_PREFIX configuration option
[PATCH v3 06/18] fsadm: Fsck extN before resize only if it is not
[PATCH v3 07/18] fsadm: Only use readlink if link is provided
[PATCH v3 08/18] fsadm: Remove unnecessary modification of PATH
[PATCH v3 09/18] fsadm: Allow to specify lv in vg/lv format
[PATCH v3 10/18] fsadm: Umount ext2 file system prior resize
[PATCH v3 11/18] fsadm: Add help for new commands and update man
[PATCH v3 12/18] lvresize: Specify --resize-fs-only when going to
[PATCH v3 13/18] fsadm: remove -y (YES) option
[PATCH v3 14/18] test: add helper to compute aligned lv size
[PATCH v3 15/18] test: Add test for fsadm add command
[PATCH v3 16/18] test: Add test for fsadm create command
[PATCH v3 17/18] test: Add test for fsadm resize command
[PATCH v3 18/18] test: Add test for fsadm remove command


