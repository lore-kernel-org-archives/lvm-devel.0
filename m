From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 8 Feb 2010 15:49:15 -0500 (EST)
Subject: false error messages when merging
Message-ID: <Pine.LNX.4.64.1002081542190.13894@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

LVM2.2.02.60 writes false error messages about tree node not found when 
activating delayed merging. But it starts merging anyway.

Mikulas

---

[slunicko:~]# lvs
  LV   VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  m    vg1  -wi-a- 16.00m
[slunicko:~]# lvcreate -s -n s -c 4k -L 24M vg1/m
  Logical volume "s" created
[slunicko:~]# mount -t ext2 /dev/vg1/s /mnt/test
[slunicko:~]# lvconvert --merge /dev/vg1/s
  Can't merge when snapshot is open
  Merging of snapshot s will start next activation.
[slunicko:~]# umount /mnt/test
[slunicko:~]# lvchange -an vg1/m
[slunicko:~]# lvchange -ay vg1/m
  failed to find tree node for m
  failed to find tree node for s
[slunicko:~]#
... the merging starts on backgound fine


