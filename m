From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Fri, 28 Jul 2017 21:55:49 +0000 (UTC)
Subject: Batch/queue LVM operations
In-Reply-To: <32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
Message-ID: <alpine.LRH.2.11.1707282151050.9683@mail.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 28 Jul 2017, Zdenek Kabelac wrote:

> Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
> > Hello,
> > 
> > Is there an option to batch LVM operations?
> > 
> > For example, I would like to delete 100 thin snapshots without updating
> > the vgmeta 100 times.
> 
> You could possibly use --select feature to handle all removals with
> just one lvremove command.

Interesting.  Does it do a single vgmeta operation?

> > Same thing with lvcreate, lvresize, etc.
> > 
> > If would be neat if `lvm`'s readline prompt could take multiple commands
> > via stdin and commit them once, even at the expense of longer lock times.
> > 
> > Is there already support for this in some form?
> 
> At this moment we do not have optimization to do more then 1 removal at a time
> - however if  LVs  are 'inactive' before lvremove  it should be relatively
> quick.
> 
> However 'lvm2' was not designed for some ultra-fast manipulation - i.e. you
> are typically not creating/removing LV so quickly.
> 
> Removal of individual thin LVs also takes its time since kernel metadata needs
> to be updated.  So I'd not expect some miliseconds timing.

In this example, you can see the difference between LVM vs using dm-thin 
directly:

## These are the devid's from vgcfgbackup:

/dev/data/2017-07-28_13-53-57_manual_foobar_1		11276 
/dev/data/2017-07-28_13-54-14_manual_foobar_1		11277

## Both volumes are first deactivated:

]# lvchange -an /dev/data/2017-07-28_13-54-14_manual_foobar_1 /dev/data/2017-07-28_13-53-57_manual_foobar_1

## Direct removal via dmsetup:

]# time dmsetup message data-pool0-tpool 0 delete 11276
real	0m0.009s
user	0m0.001s
sys	0m0.001s

## Removal by lvremove:
]# time lvremove /dev/data/2017-07-28_13-54-14_manual_foobar_1
  Logical volume "2017-07-28_13-54-14_manual_foobar_1" successfully removed

real	0m1.606s
user	0m1.120s
sys	0m0.120s


## Quite a few volumes on this VG, so metadata manipulation is the 
## bottleneck, I think:

]# lvs -o lv_name --noheading data | wc -l
4953

--
Eric Wheeler



> 
> 
> Regards
> 
> Zdenek
> 
> 


