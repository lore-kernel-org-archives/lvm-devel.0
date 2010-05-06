From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 06 May 2010 10:34:47 +0200
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <20100506015528.GN27027@agk-dp.fab.redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
	<20100506015528.GN27027@agk-dp.fab.redhat.com>
Message-ID: <4BE27F27.5040209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.5.2010 03:55, Alasdair G Kergon napsal(a):
> On Wed, Apr 28, 2010 at 02:27:24PM +0200, Zdenek Kabelac wrote:
>> Introducing dm_tree_set_suspend_priority() for suspending replicator
>> control target before deactivation of replicator-dev target.
>  
> Not keen on this one - need a bit more information as to why we need this, and
> then why the existing function dm_tree_suspend_children() - perhaps extended with an
> 'inverted' parameter - is insufficient.
> 

With the Replicator we have the logic, which has the use case for both
variants (and no other target so far needed this) - thus we need to
distinguish between them somehow.

     master replicator node     (replicator0)
           replicator-dev node  (lv1)
           replicator-dev node  (lv2)

We may want to either 'remove/suspend' the whole replicator - or just one leg.
Thus cutting the leg without suspending master node is valid and supported
operation here. So to differentiate between cutting leg or replicator the
parent suspend flag is used. That way we may atomically freeze the whole
replicator and avoid damage in the ordering of rlogged data.


>> +static int _suspend_parent(struct dm_tree_node *dnode, const char *uuid_prefix,
> 
>> +		if (!dlink->node->suspend_priority)
>> +			continue;
> 
> Why is this hard-coded only to cope with one value of suspend_priority?
> 

As mentioned in previous response - it's rather true/false value - so maybe we
could use different name here to avoid confusion with activation_priority
which takes numbers ?

Zdenek


