From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Fri, 16 Apr 2010 11:50:33 -0700
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <4BC8AAD1.3050400@redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com>
	<20100416160721.GU13021@agk-dp.fab.redhat.com>
	<4BC8AAD1.3050400@redhat.com>
Message-ID: <20100416185033.GA13043@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> > Or would it be better to implement 1s+2+3 as the first new policy?
> 
> I don't think the requirement '1s' is necessary, but  But I rather
> think that the policy 'normal' supports the following condition.
> 
>   1. The number of PVs must be more than the number of mirror legs,
>   2. M1 and M2 not on same PV as each other,
>   3. L1 and L2 not on same PV as each other,
>   4. L* may share PVs with M* if the number of PVs are less than
>      the total number of L* and M*.
> 
> I think that some users expect that the number of mirror legs are
> devices users should take care of but 'mirror log' is a logical
> device LVM2 take care of.

I am with Taka here. The normal policy should be the default and it
should do the following for the mirroredlog without introducing a new
policy.

Requirement: Number of allocatable PV's should be at least the number of
             mirror legs
Allocation: Allocate images on different PVs. Allocate logs on remaining
            PVs in a round robin fashion. If there are more PV's, we
	    will not have to share L* and M* at all.

It would be different for disklog though:
Requirement: Number of allocatable PV's should be at least one more than
             the number of mirror legs.
Allocation: Just use round-robin sequence


Thanks, Malahal.


