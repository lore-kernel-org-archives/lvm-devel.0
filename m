From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Apr 2010 20:06:12 +0100
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <20100416185033.GA13043@us.ibm.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com>
	<20100416160721.GU13021@agk-dp.fab.redhat.com>
	<4BC8AAD1.3050400@redhat.com> <20100416185033.GA13043@us.ibm.com>
Message-ID: <20100416190612.GZ13021@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 16, 2010 at 11:50:33AM -0700, malahal at us.ibm.com wrote:
> Requirement: Number of allocatable PV's should be at least the number of
>              mirror legs
> Allocation: Allocate images on different PVs. Allocate logs on remaining
>             PVs in a round robin fashion. If there are more PV's, we
> 	    will not have to share L* and M* at all.

Actually the current code allocates the logs during the first pass, not the
last, (otherwise it risks missing a 'maximal spread' layout).  Only later might
it discover there isn't enough space to complete the allocation under the
current constraints.  Then it needs to abandon the attempt, and try again with
the next, less-strict policy that allows sharing of Logs and Mimages.

Anyway, these are implementation details.  I think we agree on the goals.

Alasdair


