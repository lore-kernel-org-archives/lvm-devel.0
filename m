From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 28 Jul 2017 21:43:50 +0200
Subject: Batch/queue LVM operations
In-Reply-To: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
Message-ID: <32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
> Hello,
> 
> Is there an option to batch LVM operations?
> 
> For example, I would like to delete 100 thin snapshots without updating
> the vgmeta 100 times.

You could possibly use --select feature to handle all removals with
just one lvremove command.

> 
> Same thing with lvcreate, lvresize, etc.
> 
> If would be neat if `lvm`'s readline prompt could take multiple commands
> via stdin and commit them once, even at the expense of longer lock times.
> 
> Is there already support for this in some form?

At this moment we do not have optimization to do more then 1 removal at a time 
- however if  LVs  are 'inactive' before lvremove  it should be relatively quick.

However 'lvm2' was not designed for some ultra-fast manipulation - i.e. you
are typically not creating/removing LV so quickly.

Removal of individual thin LVs also takes its time since kernel metadata needs 
to be updated.  So I'd not expect some miliseconds timing.


Regards

Zdenek


