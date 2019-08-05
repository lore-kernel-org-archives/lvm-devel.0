From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 5 Aug 2019 12:43:46 +0200
Subject: lvmcache lv destroy with no flush
In-Reply-To: <5d47ec90.1c69fb81.d27e3.c5e4@mx.google.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
	<99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
	<5d443e89.1c69fb81.d73bc.00df@mx.google.com>
	<93895828-a482-7729-bf7e-132afd4bf767@redhat.com>
	<5d444783.1c69fb81.96e35.3a01@mx.google.com>
	<abe351bf-e73a-f7c2-9e52-fc8b542321fb@redhat.com>
	<5d47ec90.1c69fb81.d27e3.c5e4@mx.google.com>
Message-ID: <53c4649a-033c-31cc-3c63-bd925de913af@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 05. 08. 19 v 10:45 Lakshmi Narasimhan Sundararajan napsal(a):
> Thanks Zdenek, for your follow up email clarifying my questions.
> 
> I will have to check further and shall report back.
> 
> But, I also wonder why on a writeback cache even if I do submit blkdiscard to 
> the whole device, the dirty blocks do not fall to zero?
> 
> Does blkdiscard on lvmcache device not work?
> 
>  > myhome$ sudo dmsetup status --target cache
> 
>  > pxtest-pool: 0 20963328 cache 8 40/2048 2048 4096/10220 28 58 0 0 0 0 4096 
> 1 writethrough 2 migration_threshold 2048 cleaner 0 rw -
> 
>  > myhome$
> 
>  > myhome$ sudo blkdev ?getsize64 /dev/pxtest/pool
> 
> <devsize>
> 
>  >myhome$ sudo blkdiscard -o 0 -l ROUND_DISCARD_ALIGN(devsize) /dev/pxtest/pool
> 
> Even after the above discard, the lvmcache device in writeback mode holds 
> dirty blocks. And has to be flushed. Can you please help explain the behavior 
> here?
> 


Are you using latest kernels ?

Original initial release of cache was (if I remeber correctly) not supporting
discard operation on such device.

On the latest kernels all should work...


Regards

Zdenek


