From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 6 May 2010 11:14:20 +0100
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <4BE27F27.5040209@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
	<20100506015528.GN27027@agk-dp.fab.redhat.com>
	<4BE27F27.5040209@redhat.com>
Message-ID: <20100506101420.GP27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 06, 2010 at 10:34:47AM +0200, Zdenek Kabelac wrote:
> With the Replicator we have the logic, which has the use case for both
> variants (and no other target so far needed this) - thus we need to
> distinguish between them somehow.
> 
>      master replicator node     (replicator0)
>            replicator-dev node  (lv1)
>            replicator-dev node  (lv2)
> 
> We may want to either 'remove/suspend' the whole replicator - or just one leg.
> Thus cutting the leg without suspending master node is valid and supported
> operation here. So to differentiate between cutting leg or replicator the
> parent suspend flag is used. That way we may atomically freeze the whole
> replicator and avoid damage in the ordering of rlogged data.
 
Elsewhere we issue the suspend at the top part of the tree that we wish to 
suspend.  So distinguish the two cases by suspend(replicator0) vs suspend(lv1).

So I'm still not seeing the complete picture/problem here.

Alasdair


