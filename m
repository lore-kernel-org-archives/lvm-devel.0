From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Oct 2009 21:02:58 +0000
Subject: [PATCH 0 of 2] LVM: Split mirror capability
In-Reply-To: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
References: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
Message-ID: <20091026210258.GH25303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Second proposal.

On Tue, Oct 13, 2009 at 04:20:42PM -0500, Jon Brassow wrote:
> # New '--splitmirror <n>' argument
> # Replaces '-m <n> --split', and rather than specifying the number
> # of legs you want remaining in the mirror when finished, you specify
> # the number of legs you want split off.

Actually, that's really a general argument alternative to -m.
Either say -m for what is needed in the final state, or some new argument for
what to change to reach the desired final state, applicable to other lvconvert
functionality too.

So we could have both option 1 and option 2...

Alasdair


