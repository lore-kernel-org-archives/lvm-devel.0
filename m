From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 16 Apr 2010 14:22:09 -0400
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <20100416160721.GU13021@agk-dp.fab.redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com>
	<20100416160721.GU13021@agk-dp.fab.redhat.com>
Message-ID: <4BC8AAD1.3050400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/16/10 12:07, Alasdair G Kergon wrote:
> Well current policies for -m1 with mirrored log:
> 4 areas required M1 & M2 (data); L1 & L2 (log)
> 
>   contiguous - 4 PVs required
>   cling - same
>   normal  - same
>   anywhere - no restriction - 1 PV may be enough.
> 
> Suggestion is another policy with requirements:
>   1.  L* may share PVs with M*,
>   2.  M1 and M2 not on same PV as each other,
>   3.  L1 and L2 not on same PV as each other.
> 
> And to insert that policy between 'normal' and 'anywhere' in the sequence.
> 
> There is a stronger form of 1: 
>   1s. L* must share PVs with M* 
> but I think we can manage without that for now because people can obtain the same
> result with this policy by listing only the PVs concerned on the command line.
> Or would it be better to implement 1s+2+3 as the first new policy?

I don't think the requirement '1s' is necessary, but  But I rather
think that the policy 'normal' supports the following condition.

  1. The number of PVs must be more than the number of mirror legs,
  2. M1 and M2 not on same PV as each other,
  3. L1 and L2 not on same PV as each other,
  4. L* may share PVs with M* if the number of PVs are less than
     the total number of L* and M*.

I think that some users expect that the number of mirror legs are
devices users should take care of but 'mirror log' is a logical
device LVM2 take care of.

Thanks,
Taka


