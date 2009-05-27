From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 27 May 2009 07:22:06 -0400 (EDT)
Subject: Re: [PATCH] Fix handling of snapshots with virtual origin.
In-Reply-To: <4A1C2FFF.8050604@redhat.com>
References: <4A1C2FFF.8050604@redhat.com>
Message-ID: <Pine.LNX.4.64.0905270711490.29054@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It fixes the problem, but here is another one:

[gerlinda:~]# rmmod dm_zero
[gerlinda:~]# lvcreate -n vo -s --virtualoriginsize 64M -L 24M vg1
  Can't expand LV vo_vorigin: zero target support missing from kernel?
  Couldn't create virtual origin for LV vo
[gerlinda:~]# lvs
  LV      VG   Attr   LSize  Origin Snap%  Move Log         Copy%  Convert
  bla     vg1  -wi--- 24.00M
  er      vg1  vwi-a- 16.00M
  hid     vg1  owi--- 20.00M
  hid_sn  vg1  swi--- 20.00M hid
  hid_sn2 vg1  swi--- 24.00M hid
  mirror  vg1  mwi--- 30.00M                    mirror_mlog
[gerlinda:~]# lvcreate -n vo -s --virtualoriginsize 64M -L 24M vg1
  Internal error: Duplicate LV name vo_vorigin detected in vg1.
  Couldn't create virtual origin for LV vo
  Internal error: Duplicate LV name vo_vorigin detected in vg1.
  Manual intervention may be required to remove abandoned LV(s) before 
retrying.
[gerlinda:~]# lvs
  LV      VG   Attr   LSize  Origin Snap%  Move Log         Copy%  Convert
  bla     vg1  -wi--- 24.00M
  er      vg1  vwi-a- 16.00M
  hid     vg1  owi--- 20.00M
  hid_sn  vg1  swi--- 20.00M hid
  hid_sn2 vg1  swi--- 24.00M hid
  mirror  vg1  mwi--- 30.00M                    mirror_mlog
  vo      vg1  -wi--- 24.00M
[gerlinda:~]# lvremove vg1/vo
  Logical volume "vo" successfully removed

... after this, the vg contains junk invisible lv vo_vorigin in its 
metadata. It can be removed, but it can't be seen. (in fact, the junk lv 
is created on the first activation command if the module dm_zero is not 
loaded in the kernel)

Mikulas


