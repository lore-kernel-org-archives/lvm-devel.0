From: John Drescher <drescherjm@gmail.com>
Date: Tue, 22 Feb 2011 09:57:37 -0500
Subject: pvcreate problem with 2 metadata areas.
Message-ID: <AANLkTikj8hnsTYne61TXzFyubmLLNvo1QD4kgBudxubt@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I was attempting to demonstrate a bug in the latest git that I still
can not expand a pv that has 2 pvmetadata copies however I hit a
second bug in the process. Here are the steps I have taken (on a
virtual machine):

localhost ~ # uname -a
Linux localhost 2.6.37-gentoo #3 SMP Sun Feb 13 00:17:53 Local time
zone must be set--see zic  x86_64 Intel(R) Core(TM) i7 CPU 920 @
2.67GHz GenuineIntel GNU/Linux

localhost ~ # mdadm -C /dev/md0 -l 5 -n 3 /dev/sd[cde]1
mdadm: /dev/sdc1 appears to be part of a raid array:
    level=raid5 devices=4 ctime=Sat Feb 12 21:24:39 2011
mdadm: /dev/sdd1 appears to be part of a raid array:
    level=raid5 devices=4 ctime=Sat Feb 12 21:24:39 2011
mdadm: /dev/sde1 appears to be part of a raid array:
    level=raid5 devices=4 ctime=Sat Feb 12 21:24:39 2011
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
localhost ~ # cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md0 : active raid5 sde1[3] sdd1[1] sdc1[0]
      3140608 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [UU_]
      [=>...................]  recovery =  6.7% (105472/1570304)
finish=1.1min speed=21094K/sec

unused devices: <none>

localhost ~ # lvm version
  LVM version:     2.02.85(2)-cvs (2011-02-09)
  Library version: 1.02.64-cvs (2011-02-09)
  Driver version:  4.18.0

localhost ~ # pvcreate /dev/md0 --pvmetadatacopies 2
  Physical volume "/dev/md0" successfully created
localhost ~ # pvck -v /dev/md0
    Scanning /dev/md0
  Found label on /dev/md0, sector 1, type=LVM2 001
  Found text metadata area: offset=4096, size=1044480
  Found text metadata area: offset=3215852032, size=1048576
  /dev/md0: lseek 3216900096 failed: Invalid argument
  Read from /dev/md0 failed

It looks like the second metadata copy is 4096 bytes too large.

-- 
John M. Drescher


