From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:14 +0200
Subject: [RFC][PATCH 00/16 v2] fsadm update
Message-ID: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello everyone,

this is the second update of the fsadm. The main difference is that all
the big features are collapsed into one patch for better review (since
some of the features depends on each other and has been developed in
that way). Also one new test is added to exercise "remove" command.

Here is a link to the first version of the patch set:
http://www.redhat.com/archives/linux-lvm/2011-September/msg00046.html

Comments are welcomed.

Thanks!
-Lukas

-- 
[PATCH 01/16] fsadm: Add new commands create,list,add and remove
[PATCH 02/16] fsadm: Make all internal math in kilobytes
[PATCH 03/16] fsadm: Add simple configuration file
[PATCH 04/16] fsadm: Use DEFAULT_DEVICE_POOL when creating volume
[PATCH 05/16] fsadm: Add LVOL_PREFIX configuration option
[PATCH 06/16] fsadm: Fsck extN before resize only if it is not
[PATCH 07/16] fsadm: Only use readlink if link is provided
[PATCH 08/16] fsadm: Remove unnecessary modification of PATH
[PATCH 09/16] fsadm: Umount ext2 file system prior resize
[PATCH 10/16] lvresize: Specify --resize-fs-only when going to use
[PATCH 11/16] fsadm: remove -y (YES) option
[PATCH 12/16] test: add helper to compute aligned lv size
[PATCH 13/16] test: Add test for fsadm add command
[PATCH 14/16] test: Add test for fsadm create command
[PATCH 15/16] test: Add test for fsadm resize command
[PATCH 16/16] test: Add test for fsadm remove command


