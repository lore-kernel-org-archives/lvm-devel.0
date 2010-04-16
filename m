From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Apr 2010 19:42:35 +0100
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <4BC8AAD1.3050400@redhat.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com>
	<20100416160721.GU13021@agk-dp.fab.redhat.com>
	<4BC8AAD1.3050400@redhat.com>
Message-ID: <20100416184235.GX13021@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 16, 2010 at 02:22:09PM -0400, Takahiro Yasui wrote:
> I don't think the requirement '1s' is necessary, but  But I rather
> think that the policy 'normal' supports the following condition.
> 
>   1. The number of PVs must be more than the number of mirror legs,
>   2. M1 and M2 not on same PV as each other,
>   3. L1 and L2 not on same PV as each other,
>   4. L* may share PVs with M* if the number of PVs are less than
>      the total number of L* and M*.

I was thinking of changing it to default to the new policy, and renaming that to 'normal'.
(So the old normal is the one that gets a new name.)

I'm not sure that it would be easy to implement 4 within the existing normal policy.
In general, it's hard for a single policy to work towards (and choose between)
conflicting goals.  And 'number of PVs' is not easily defined.  (We're covering
cases like -m+3 as well, plus restrictions from available PVs supplied on the
command line, plus restrictions from which PVs are already in use at different
parts of the existing mirror legs.)

Alasdair


