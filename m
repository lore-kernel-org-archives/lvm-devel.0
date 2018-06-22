From: Gang He <ghe@suse.com>
Date: Fri, 22 Jun 2018 03:31:23 -0600
Subject: lvresize in test mode sends BLKDISCARD to SSD block devices, this will result in the file system corruption
Message-ID: <5B2CC1EB020000F900024F32@prv1-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello List,

I found a bug for lvresize command, this issue can be reproduced by lvm2-2.02.178 code base.
The reproduce steps are as below,
1) create a LV on a SSD based partition, then format this LV with ext4 file system, and mount this LV. 
e.g.
linux-cy2k:/ # lsblk
...
sdc                               8:32   0  37.3G  0 disk
??sdc1                            8:33   0     2G  0 part [SWAP]
??sdc2                            8:34   0  14.7G  0 part
? ??cluster--vg1-test--lv       254:20   0    14G  0 lvm  /mnt/ext4  <<= this LV
??sdc3                            8:35   0  20.6G  0 part

2) enable issue discards to a logical volumes's underlying physical volume via edit "/etc/lvm/lvm.conf" file.
e.g.
linux-cy2k:/ # vi /etc/lvm/lvm.conf 
set "issue_discards = 1"

3) run lvresize command in test mode.
e.g.
inux-cy2k:/ # lvresize -v -n -L -10GB /dev/cluster-vg1/test-lv --test

4) unmount this LV, then mount this LV again.
You will probably encounter the file system on this LV is corrupted.
e.g. 
linux-cy2k:~ # mount /dev/cluster-vg1/test-lv /mnt/ext4/
mount: wrong fs type, bad option, bad superblock on /dev/mapper/cluster--vg1-test--lv,
       missing codepage or helper program, or other error

       In some cases useful info is found in syslog - try
       dmesg | tail or so.

linux-cy2k:~ # dmesg
[3711112.342424] JBD2: no valid journal superblock found
[3711112.342429] EXT4-fs (dm-20): error loading journal

To summarize, I think this behavior is a bug and is very dangerous, 
the command in test mode should not send BLKDISCARD to the underlying block device,
the BLKDISCARD command will make the related sectors on the block device be trimmed (lost data).


Thanks
Gang
 


