From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 19 Sep 2013 10:15:42 +0200
Subject: [PATCH] libdm: fix races with udev
In-Reply-To: <alpine.LRH.2.02.1309161523010.9077@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1309161523010.9077@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <523AB2AE.3020103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/16/2013 09:23 PM, Mikulas Patocka wrote:
> libdm: fix races with udev
> 
> On newer systems (Debian 6 and newer), udev manages nodes in /dev/mapper
> directory. It creates, deletes and renames the nodes according to the
> state of the kernel driver.
> 
> dmsetup tries to manage nodes in /dev/mapper too, so it can race with
> udev. dmsetup checks if the node was created/deleted/renamed with the stat
> syscall, and skips the operation if it was. However, if udev
> creates/deletes/renames the node after the stat syscall and before the
> mknod/unlink/rename syscall, dmsetup reports an error.
> 

These checks are performed after udev is synchronized (the dm_udev_wait call)
and after the udev processing is complete, so we normally shouldn't get into this
problem unless there is some bug in certain version of lvm2/udev rules.

Is this reproducible with upstream code as well or was that with some older version only
that is currently in Debian?

Peter


