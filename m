From: Eric Ren <renzhengeek@gmail.com>
Date: Fri, 12 Apr 2019 22:40:48 +0800
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
Message-ID: <CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

> When udev kills its worker due to timeout - so udev rules was not finished
> within predefined timeout (which unfortunately changes according to mind
> change of udev developer - so it ranges from 90seconds to 300seconds depending
> on date of release) - you need to look out for reason why the timeout happens -
>
> - is it because disk read was dead ?
>
> - is it because it's overloaded system ?
>
> - is it because of slow read operation (i.e. some raid arrays are known to
> wake-up slowly)
>
> - was udev rule accessing something it shouldn't even read ?

Thanks for these hints. Next time, I will collect the udev events
while trying to reproduce.

Again, I reproduced this on centos 7.6 with lvm2-1.02.180, full log
file will be attached.

>
> Once you know this - you can decide what's the best solution - you can
> extended default timeout to larger value  (i.e. 300 used to be usually good
> for this case)  you can fix/replace your failing drive.

When lvcreate hangs, the /dev/dm-26 has been visible, but the
/dev/vg0/22 symbol link is not ready.

Abstracted from the log, it waits for the udev cookie count to become zero:
"""
libdm-common.c:2433  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464) created
libdm-common.c:2453  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
incremented to 1
libdm-common.c:2325  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
incremented to 2
libdm-common.c:2575  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
assigned to RESUME task(5) with flags DISABLE_LIBRARY_FALLBACK
(0x20)
...
libdm-deptree.c:1302  lvcreate  Resuming vg0-22 (252:26).
...
libdm-common.c:2325  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
incremented to 3
libdm-common.c:2575  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
assigned to RESUME task(5) with flags DISABLE_LIBRARY_FALLBACK
(0x20)
...
activate/fs.c:491   lvcreate  Syncing device names
libdm-common.c:2360  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
decremented to 2
libdm-common.c:2646  lvcreate  Udev cookie 0xd4d0b57 (semid 225214464)
waiting for zero
"""

Since the /dev/dm-x has been created, I don't understand what it waits
udev to do?
Just waits udev rules to create device symbol links?


> lvm2 can be unblocked with 'dmsetup udevcomplete_all'  I guess until udev API
> will propagate its runtime timeout we can't do much more ATM...

Thanks! I remembered there is such a command, but cannot think it up....

>
> You can enable full udev debugging to obtain the reasoning which rule was
> executed and got frozen.

OK.

Regards,
Eric


