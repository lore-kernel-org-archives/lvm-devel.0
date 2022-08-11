From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2022 11:43:13 +0200
Subject: thin pool zeroing/dump query
In-Reply-To: <CAFe+wq062=a8iFbqD=MjK20UTrvEcoKscWZn1V1nMfxYM3068A@mail.gmail.com>
References: <CAFe+wq062=a8iFbqD=MjK20UTrvEcoKscWZn1V1nMfxYM3068A@mail.gmail.com>
Message-ID: <53e8932e-c9a9-a19e-f1e5-08395485c3f8@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10. 08. 22 v 19:25 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team!
> Good day everyone!
>
> I wanted to check with you on the 2 items below.
>
> 1/ Is it safe to run with thin pool chunks?not zeroed? What's the 
> recommendation?
> not zeroing chunks from within thin pools, allows for some perf benefits, 
> but we see xfs complaining about unclean metadata sometimes.


Hello

Zeroing shouldn't be necessary if all the users are accessing volume via? 
'filesystem'? (aka no? 'dd' raw device access).

Modern filesystem (like XFS, Ext4) do track 'written'? content - so they 
should never ever read anything they did not wrote -? this makes me suspicious 
about your?? 'sometimes unclean metadata' claim - as this case would be rather 
a sign of some horrible bug inside? XFS.?? If you have easy reproducer for 
this claim it should be reported & investigated.

Of course if you would be executing some kind of? 'xfs_repair' operation - 
then yes - in this case the tool may find some 'ancient' data - but it should 
never happen with regular usage of filesystem.

Zeroing is mostly as a 'security' feature - since it make sure the device 
content is always zeroed and never leaks any left data from previous disk 
usage.? But it clear has it's price since the zeroing of sectors does not 
(usually) come for free...

>
> Our reasoning is as below. A discard happened to a range that unmapped the 
> chunk, and then fs wrote only a portion, which now has junk data in 
> unwritten but discard region from fs point of view.
>
Discard is somewhat 'tricky' operation for a thin-pool as various alignment 
demands must be met - so in many cases? 'expected' released? space in 
thin-pool is much smaller.? For successful discard of chunk in a thin-pool 
whole chunk must be discarded, for successful passdown it also has to be 
aligned on disk discard boundary (usually? 512KiB)


> 2/ Is it possible for thin_dump to return len that are smaller than the 
> whole chunk?
> say for ex. chunk mapped at off 'x' with user data only upto 'u' but the 
> thin chunk size is (c) which is greater than user data (u). In which case, 
> is it possible for thin_dump to report an off 'x' with len 'u'? Or can we 
> always expect thin_dump to report lengths that are a multiple of chunk size?


Thin-pool always provision whole chunk for a thin volume.? So if user writes? 
1 sector and? uses? 256KiB chunk size with zeroing - whole? 256KiB is 
allocated and zeroed - and just 1 sector is written there on 'provisioning' 
time - next ongoing writes do not add any more 'overhead'.??? Note - if you 
use small chunk size like 64K and you actually queue full 64K write IOs - 
zeroing is fully skipped - since all data will? be written by user...

thin_dump?? reports? mapping for thin volume in? chunks?? - there is no 
further info about which sectors from a chunk was written.


Small chunks -? lots of metadata and associated overhead with their maintenance.

Large chunks -?? low metadata overhead - but also not so good space 
utilization with snapshots....


Regards


Zdenek



