From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 11 Oct 2007 19:03:25 -0400
Subject: [RFC LVM2] (6/6) Allow allocation from LV
In-Reply-To: <470EA422.6000003@ce.jp.nec.com>
References: <470EA422.6000003@ce.jp.nec.com>
Message-ID: <470EABBD.2080808@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows allocation from LV.

Example 1: striped LV on mirrored LV

# lvcreate -l4 -m1 --corelog testvg
  Logical volume "lvol0" created
# lvcreate -l4 -m1 --corelog testvg
  Logical volume "lvol1" created
# lvchange --addtag m testvg/lvol0 testvg/lvol1
  Logical volume "lvol0" changed
  Logical volume "lvol1" changed
# lvcreate -i2 -l2 testvg @m
  Using default stripesize 64.00 KB
  Logical volume "lvol2" created
# lvextend -l+2 testvg/lvol2 @m
  Using stripesize of last segment 64.00 KB
  Extending logical volume lvol2 to 16.00 MB
  Logical volume lvol2 successfully resized
# lvs -a -o name,attr,devices
  LV               Attr   Devices                            
  [lvol0]          mwi-ao lvol0_mimage_0(0),lvol0_mimage_1(0)
  [lvol0_mimage_0] iwi-ao /dev/mapper/d1(0)                  
  [lvol0_mimage_1] iwi-ao /dev/mapper/d2(0)                  
  [lvol1]          mwi-ao lvol1_mimage_0(0),lvol1_mimage_1(0)
  [lvol1_mimage_0] iwi-ao /dev/mapper/d3(0)                  
  [lvol1_mimage_1] iwi-ao /dev/mapper/d4(0)                  
  lvol2            -wi-a- lvol0(0),lvol1(0)        
# dmsetup ls --tree
testvg-lvol2 (253:15)
 |-testvg-lvol1 (253:14)
 |  |-testvg-lvol1_mimage_1 (253:13)
 |  |  `-d4 (253:4)
 |  |     `- (7:0)
 |  `-testvg-lvol1_mimage_0 (253:12)
 |     `-d3 (253:3)
 |        `- (7:0)
 `-testvg-lvol0 (253:11)
    |-testvg-lvol0_mimage_1 (253:10)
    |  `-d2 (253:2)
    |     `- (7:0)
    `-testvg-lvol0_mimage_0 (253:9)
       `-d1 (253:1)
          `- (7:0)

Example 2: mirrored mirror log

# lvcreate -m1 --corelog -l1 --addtag m testvg
  Logical volume "lvol0" created
# lvcreate -m1 -l1 --corelog testvg
  Logical volume "lvol1" created
# lvconvert --mirrorlog disk testvg/lvol1 @m
  Logical volume lvol1 converted.
# lvs -a -o name,attr,devices
  LV               Attr   Devices                            
  [lvol0]          mwi-ao lvol0_mimage_0(0),lvol0_mimage_1(0)
  [lvol0_mimage_0] iwi-ao /dev/mapper/d1(0)                  
  [lvol0_mimage_1] iwi-ao /dev/mapper/d2(0)                  
  lvol1            mwi-a- lvol1_mimage_0(0),lvol1_mimage_1(0)
  [lvol1_mimage_0] iwi-ao /dev/mapper/d3(0)                  
  [lvol1_mimage_1] iwi-ao /dev/mapper/d4(0)                  
  [lvol1_mlog]     lwi-ao lvol0(0)                      
# dmsetup ls --tree
testvg-lvol1 (253:14)
 |-testvg-lvol1_mimage_1 (253:13)
 |  `-d4 (253:4)
 |     `- (7:0)
 |-testvg-lvol1_mimage_0 (253:12)
 |  `-d3 (253:3)
 |     `- (7:0)
 `-testvg-lvol1_mlog (253:15)
    `-testvg-lvol0 (253:11)
       |-testvg-lvol0_mimage_1 (253:10)
       |  `-d2 (253:2)
       |     `- (7:0)
       `-testvg-lvol0_mimage_0 (253:9)
          `-d1 (253:1)
             `- (7:0)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-allocate-from-lv.patch
Type: text/x-patch
Size: 11167 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071011/2b71ee7f/attachment.bin>
