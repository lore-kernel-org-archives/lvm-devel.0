From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 31 May 2010 10:29:47 -0400 (EDT)
Subject: md_component_detection bug
In-Reply-To: <20100529111902.GZ30283@agk-dp.fab.redhat.com>
References: <Pine.LNX.4.64.1005290111560.15553@hs20-bc2-1.build.redhat.com>
	<20100529111902.GZ30283@agk-dp.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.1005311021090.23628@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

On Sat, 29 May 2010, Alasdair G Kergon wrote:

> 1) The basic rule is you should run 'vgscan' after changing devices
> underneath LVM.

vgscan fixes it. But the problem here is potential data corruption, thus 
LVM should avoid it automatically and not wait for the admin to run 
vgscan.

For example, if you have MD-RAID0 and one of the disk cables gets 
unpluggerd (this the RAID0 array doesn't start), LVM starts reading 
metadata from the raw RAID0 leg. One can't assume that the admin will run 
vgscan if the disk cable is unplugged...

> 2) The code tries to detect problems but doesn't find every case.
> It's a trade-off between complete correctness scanning everything all
> the time and speed.

It may slow somehow to scan the end of devices for MD-superblocks in 
addition to scanning the beginning for LVM metadata, but it won't be order 
of magnitude slower and safety is more important than speed here.

> For this new example where it doesn't do what you would expect,
> write up a bugzilla (fedora rawhide) listing the sequence of commands
> someone could run to demonstrate the problem.
> Perhaps also show the contents of '.cache' in between the commands
> that change it.

I submitted it as a bug 598135, with the script that triggers it.

> In particular, is .cache holding *both* /dev/md0 *and* /dev/sdc1 +
> /dev/sdd1 even though md_component_detection is enabled?    If so,
> that's what we should fix I think.

It held /dev/sdc1 + /dev/sdd1 from some earlier experiments. And these 
cache entries weren't erased when these volumes became part of /dev/md1

> The device cache is very old code.
> 
> Alasdair

Mikulas


