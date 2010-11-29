From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 22:40:15 +0000
Subject: [PATCH] Disable automatic MISSING_PV recovery when handles_missing_pvs is set (BZ 653643)
In-Reply-To: <87d3ptm965.fsf@twilight.int.mornfall.net.>
References: <87d3ptm965.fsf@twilight.int.mornfall.net.>
Message-ID: <20101129224015.GS29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 09:37:38PM +0100, Peter Rockai wrote:
> it seems I did everything but actually posted the proposed patch for BZ
> 653643. The explanation of what goes wrong where and how the patch fixes
> that is in BZ comments.
 
So what does the new output in the test case in that bz look like?

Do we still get the last WARNING message?   (Where does it come from?
Maybe it's too hard to fix that without removing it from other code
paths where we do still want it?)

Ack.

Alasdair


