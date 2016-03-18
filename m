From: Liuhua Wang <lwang@suse.com>
Date: Fri, 18 Mar 2016 17:17:14 +0800
Subject: pvmove supports moving between sector size of 512B and 4096B?
Message-ID: <20160318091714.GA12933@wlh-host.lab.bej.apac.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

Does pvmove support moving from a disk with sector size 512B
to a disk with sector size 4096B?

- SOURCE DEVICE (mdos lvm partiton)

#parted /dev/sdb
Model: ATA SATADOM-SL 3ME (scsi)
Disk /dev/sdb: 32.0GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  630MB   629MB   primary  ext3         boot, type=83
 2      631MB   32.0GB  31.4GB  primary               lvm, type=8e


- TARGET DEVICE (WHOLE DISK)
#parted /dev/sdc
Error: /dev/sdd: unrecognised disk label
Model: ATA HUH728080ALN600 (scsi)                                         
Disk /dev/sdd: 8002GB
Sector size (logical/physical): 4096B/4096B
Partition Table: unknown
Disk Flags: 

There was mounted a xfs file system on the LV.
After `pvmove /dev/sdb2 /dev/sdc`
cannot umount and mount the LV, it said:
 mount: mount /dev/mapper/LV on /mnt failed: Function not implemented

Is that an expected phenomenon?

Thank you very much!

Best regards,
Liuhua 


