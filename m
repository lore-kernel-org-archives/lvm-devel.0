From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 06 May 2010 12:22:55 +0200
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <20100506101420.GP27027@agk-dp.fab.redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>	<20100506015528.GN27027@agk-dp.fab.redhat.com>	<4BE27F27.5040209@redhat.com>
	<20100506101420.GP27027@agk-dp.fab.redhat.com>
Message-ID: <4BE2987F.5080305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.5.2010 12:14, Alasdair G Kergon napsal(a):
> On Thu, May 06, 2010 at 10:34:47AM +0200, Zdenek Kabelac wrote:
>> With the Replicator we have the logic, which has the use case for both
>> variants (and no other target so far needed this) - thus we need to
>> distinguish between them somehow.
>>
>>      master replicator node     (replicator0)
>>            replicator-dev node  (lv1)
>>            replicator-dev node  (lv2)
>>
>> We may want to either 'remove/suspend' the whole replicator - or just one leg.
>> Thus cutting the leg without suspending master node is valid and supported
>> operation here. So to differentiate between cutting leg or replicator the
>> parent suspend flag is used. That way we may atomically freeze the whole
>> replicator and avoid damage in the ordering of rlogged data.
>  
> Elsewhere we issue the suspend at the top part of the tree that we wish to 
> suspend.  So distinguish the two cases by suspend(replicator0) vs suspend(lv1).
> 
> So I'm still not seeing the complete picture/problem here.

IMHO that would mean, that every tool which would need to suspend LV1 would
need to know that it must build first the tree for replicator and make this as
a two stage function.

i.e. mirror over replicator  - I'm not saying it's supported feature at this
moment, but from the logic how the dm_tree operates this 'one-pass' solution
seems to be a more complex solution.

Of course it could be probably overwritten to use multiple trees generated for
each leg separately after the main part of replicator is suspend - but it
looks far more complicated compared with this bool suspend_priority flag.

Zdenek


