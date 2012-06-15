From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 15 Jun 2012 12:11:27 +0200
Subject: pvmove + loop device eats data
In-Reply-To: <4FD9B704.7010906@megasoft.be>
References: <4FD9B704.7010906@megasoft.be>
Message-ID: <4FDB0A4F.7070809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.6.2012 12:03, Killian De Volder napsal(a):
> Hello,
>
> Today I needed some space, so I wiped up a disk, threw a file on it, and
> pmoved it.
> Done my resizes, and moved the data back, only to see my data disappear.
> (lv was filled with zero's).
>
> The steps required to reproduce the problem are below?
> Did I do something wrong, or did I stumble upon a bug ?
>
> Kind regards,
> Killian
>
> # lvm version
> LVM version:     2.02.88(2) (2011-08-19)
> Library version: 1.02.67 (2011-08-19)
> Driver version:  4.22.0
>
> # dmsetup version
> Library version:   1.02.67 (2011-08-19)
> Driver version:    4.22.0
>
> Kernel version: 3.2.1-gentoo-r2
>
> #dd of=test_pv1 if=/dev/zero bs=1M seek=512 count=0
> 0+0 records in
> 0+0 records out
> 0 bytes (0 B) copied, 1,0151e-05 s, 0,0 kB/s
> #dd of=test_pv2 if=/dev/zero bs=1M seek=512 count=0
> 0+0 records in
> 0+0 records out
> 0 bytes (0 B) copied, 1,0369e-05 s, 0,0 kB/s
> #losetup /dev/loop0 test_pv1
> #losetup /dev/loop1 test_pv2
> #pvcreate /dev/loop0
> File descriptor 6 (pipe:[839]) leaked on pvcreate invocation. Parent PID
> 14507: bash
> File descriptor 8 (pipe:[841]) leaked on pvcreate invocation. Parent PID
> 14507: bash
>    Writing physical volume data to disk "/dev/loop0"
> #pvcreate /dev/loop1
> File descriptor 6 (pipe:[839]) leaked on pvcreate invocation. Parent PID
> 14507: bash
> File descriptor 8 (pipe:[841]) leaked on pvcreate invocation. Parent PID
> 14507: bash
>    Writing physical volume data to disk "/dev/loop1"
> #vgcreate test /dev/loop0 /dev/loop1
> File descriptor 6 (pipe:[839]) leaked on vgcreate invocation. Parent PID
> 14507: bash
> File descriptor 8 (pipe:[841]) leaked on vgcreate invocation. Parent PID
> 14507: bash
> pvs
>    Volume group "test" successfully created
> #lvcreate -L 1M test
> File descriptor 6 (pipe:[839]) leaked on lvcreate invocation. Parent PID
> 14507: bash
> File descriptor 8 (pipe:[841]) leaked on lvcreate invocation. Parent PID
> 14507: bash
>   Rounding up size to full physical extent 4,00 MiB
>   Logical volume "lvol0" created
> #echo a > /dev/test/lvol0
> # cat /dev/test/lvol0
> a
> # pvmove /dev/loop0 /dev/loop1
> File descriptor 6 (pipe:[839]) leaked on pvmove invocation. Parent PID 14507:
> bash
> File descriptor 8 (pipe:[841]) leaked on pvmove invocation. Parent PID 14507:
> bash
>    /dev/loop0: Moved: 100,0%
> # cat /dev/test/lvol0
> #


There is bug in pvmove code - which runs discard on the block prior its  being 
moved - so if you happen to have  issue_discard=1 and the PV supports discard, 
the bad things will happen.

As a workaround - set issue_discard=0

Zdenek


