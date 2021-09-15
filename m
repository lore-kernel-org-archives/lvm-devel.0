From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 15 Sep 2021 12:32:12 +0530
Subject: thin vol write performance variance
Message-ID: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team,
A very good day to you.

I have a lvm2 thin pool and thin volumes in my environment.
I see a huge variance in write performance over those thin volumes.
As one can observe from the logs below, the same quantum of write
(~1.5G) to the thin volume (/dev/pwx0/608561273872404373) completes
between 2s to 40s.
The metadata is  defined as 128 sectors (64KB) on the thin pool.
I understand that there is a late mapping of segments to thin volumes
as IO requests come in.
Is there a way to test/quantity that the overhead is because of this
lazy mapping?
Are there any other config/areas that I can tune to control this behavior?
Are there any tunables/ioctl to control mapping regions ahead of time
(ala readahead)?
Any other options available to confirm this behavior is because of the
lazy mapping and ways to improve it?

My intention is to improve this behavior and control the variance to a
more tight bound.
Looking forward to your inputs in helping me understand this better.

#dmsetup table
pwx0-pxpool-tpool: 0 796114944 thin-pool 253:0 253:1 128 0 0
pwx0-pxpool_tdata: 0 796114944 linear 9:127 4200448
pwx0-pxpool_tmeta: 0 4194304 linear 9:127 800315392
pwx0-pxpool: 0 796114944 linear 253:2 0



[root at ip-70-0-84-206 ~]# lvs -a
  LV                 VG   Attr       LSize    Pool   Origin Data%
Meta%  Move Log Cpy%Sync Convert
  608561273872404373 pwx0 Vwi-aotz--  128.00g pxpool        13.26
  886134405495543142 pwx0 Vwi-aotz--  128.00g pxpool        3.91
  892291237217829180 pwx0 Vwi-aotz--  128.00g pxpool        10.29
  [lvol0_pmspare]    pwx0 ewi-------    2.00g
  pxMetaFS           pwx0 Vwi-a-tz--    4.00g pxpool        0.26
  pxpool             pwx0 twi-aotz-- <379.62g               9.26   1.66
  [pxpool_tdata]     pwx0 Twi-ao---- <379.62g
  [pxpool_tmeta]     pwx0 ewi-ao----    2.00g
[root at ip-70-0-84-206 ~]#

[root at ip-70-0-84-206 ~]# lvdisplay /dev/pwx0/608561273872404373
  --- Logical volume ---
  LV Path                /dev/pwx0/608561273872404373
  LV Name                608561273872404373
  VG Name                pwx0
  LV UUID                x8tDT6-vHH9-JkFT-0z3H-aSE2-G7iZ-QqFmEf
  LV Write Access        read/write
  LV Creation host, time ip-70-0-84-206.brbnca.spcsdns.net, 2021-09-15
06:17:16 +0000
  LV Pool name           pxpool
  LV Status              available
  # open                 2
  LV Size                128.00 GiB
  Mapped size            13.26%
  Current LE             32768
  Segments               1
  Allocation             inherit
  Read ahead sectors     0
  Block device           253:8

[root at ip-70-0-84-206 ~]#

// on host filesystem
[root at ip-70-0-84-206 ~]# ls -lh dump
-rw-r--r-- 1 root root 1.5G Sep 15 04:56 dump
[root at ip-70-0-84-206 ~]#

[root at ip-70-0-84-206 ~]# mkdir -p /mnt/tvol2
[root at ip-70-0-84-206 ~]# mount /dev/pwx0/608561273872404373 /mnt/tvol2

[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.3

real    0m2.010s
user    0m0.016s
sys     0m1.786s
[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.4

real    0m40.880s
user    0m0.010s
sys     0m1.762s
[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.5

real    0m38.841s
user    0m0.014s
sys     0m1.979s
[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.6

real    0m29.998s
user    0m0.010s
sys     0m1.772s
[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.6
cp: overwrite ?/mnt/tvol2/dump.6?? y

real    0m16.897s
user    0m0.008s
sys     0m1.804s
[root at ip-70-0-84-206 ~]# time cp dump /mnt/tvol2/dump.6
cp: overwrite ?/mnt/tvol2/dump.6?? y

real    0m31.094s
user    0m0.012s
sys     0m1.855s
[root@ip-70-0-84-206 ~]#

Thanks
LN



