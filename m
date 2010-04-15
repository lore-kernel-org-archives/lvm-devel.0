From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 Apr 2010 23:03:09 +0100
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <4BC7817E.7080407@redhat.com>
References: <4BC7817E.7080407@redhat.com>
Message-ID: <20100415220308.GO13021@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 15, 2010 at 05:13:34PM -0400, Takahiro Yasui wrote:
> I tested the latest lvm2 and found that mirror legs were allocated
> in the same PV when "--alloc anywhere" was specified. 

That is correct - it is what 'anywhere' means - it is OK for the tools
to take the space from 'anywhere'.
(We still have some problems because the code gets the space
in two allocation requests instead of getting it all in one go, so
the first of those requests has incomplete information.)

Are there any likely situations where a non-optimal layout is selected
with --alloc normal?  If so, can we identify them and find some strategy
to handle it e.g. do we need to add another allocation policy 
to allow logs on the same PVs as mimages?

Alasdair


