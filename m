From: ben <benscott@nwlink.com>
Date: Mon, 2 Aug 2010 19:18:15 -0700
Subject: Bug? in allocation of pvs in a striped mirror using lvcreate
In-Reply-To: <20100802210742.27320.qmail@sourceware.org>
References: <20100802210742.27320.qmail@sourceware.org>
Message-ID: <201008021918.15547.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I was experimenting with lvs and ran the following lvcreate command. The issue is 
that at least two physical volumes are spread between mirrors. Devices /dev/sdb5 
and /dev/sdb6 are part of both lvol0_mimage_0 and lvol0_mimage_1. I tried diffent
"-alloc" values but nothing changed. In my testing I had all the pvs on one drive
but of course I wouldn't do that on a real server.


lvs --version
  LVM version:     2.02.73(2)-cvs (2010-07-28)
  Library version: 1.02.54-cvs (2010-07-28)
  Driver version:  4.15.0

lvcreate --stripes 2  --mirrors 1 --mirrorlog disk --alloc normal vg01 --extents 14848

lvs --segments --all -o +devices
  LV               VG   Attr   #Str Type    SSize   Devices
  lvol0            vg01 mwn-a-    2 mirror  928.00m lvol0_mimage_0(0),lvol0_mimage_1(0)
  [lvol0_mimage_0] vg01 Iwi-ao    2 striped 824.00m /dev/sdb9(0),/dev/sdb14(0)
  [lvol0_mimage_0] vg01 Iwi-ao    2 striped 104.00m /dev/sdb5(0),/dev/sdb6(0)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped 464.00m /dev/sdb17(0),/dev/sdb13(0)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped 176.00m /dev/sdb11(0),/dev/sdb17(3712)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped 112.00m /dev/sdb15(0),/dev/sdb6(832)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped  80.00m /dev/sdb12(0),/dev/sdb5(832)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped  72.00m /dev/sdb10(0),/dev/sdb11(1408)
  [lvol0_mimage_1] vg01 Iwi-ao    2 striped  24.00m /dev/sdb7(0),/dev/sdb8(0)
  [lvol0_mlog]     vg01 lwn-ao    1 linear   64.00k /dev/sdb16(0)

pvs -o +lv_name
  PV         VG   Fmt  Attr PSize   PFree  LV
  /dev/sdb10 vg01 lvm2 a-    36.00m     0  [lvol0_mimage_1]
  /dev/sdb11 vg01 lvm2 a-   124.00m     0  [lvol0_mimage_1]
  /dev/sdb11 vg01 lvm2 a-   124.00m     0  [lvol0_mimage_1]
  /dev/sdb12 vg01 lvm2 a-    44.00m  4.00m [lvol0_mimage_1]
  /dev/sdb12 vg01 lvm2 a-    44.00m  4.00m
  /dev/sdb13 vg01 lvm2 a-   232.00m     0  [lvol0_mimage_1]
  /dev/sdb14 vg01 lvm2 a-   412.00m     0  [lvol0_mimage_0]
  /dev/sdb15 vg01 lvm2 a-    76.00m 20.00m [lvol0_mimage_1]
  /dev/sdb15 vg01 lvm2 a-    76.00m 20.00m
  /dev/sdb16 vg01 lvm2 a-     4.00m  3.94m [lvol0_mlog]
  /dev/sdb16 vg01 lvm2 a-     4.00m  3.94m
  /dev/sdb17 vg01 lvm2 a-   320.00m     0  [lvol0_mimage_1]
  /dev/sdb17 vg01 lvm2 a-   320.00m     0  [lvol0_mimage_1]
  /dev/sdb5  vg01 lvm2 a-    92.00m     0  [lvol0_mimage_0]
  /dev/sdb5  vg01 lvm2 a-    92.00m     0  [lvol0_mimage_1]
  /dev/sdb6  vg01 lvm2 a-   108.00m     0  [lvol0_mimage_0]
  /dev/sdb6  vg01 lvm2 a-   108.00m     0  [lvol0_mimage_1]
  /dev/sdb7  vg01 lvm2 a-    12.00m     0  [lvol0_mimage_1]
  /dev/sdb8  vg01 lvm2 a-    28.00m 16.00m [lvol0_mimage_1]
  /dev/sdb8  vg01 lvm2 a-    28.00m 16.00m
  /dev/sdb9  vg01 lvm2 a-   420.00m  8.00m [lvol0_mimage_0]
  /dev/sdb9  vg01 lvm2 a-   420.00m  8.00m


