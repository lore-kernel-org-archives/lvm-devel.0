From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 Aug 2009 18:16:55 +0100
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <87fxbusglm.fsf@twilight.int.mornfall.net.>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
	<20090812225043.GR7033@agk-dp.fab.redhat.com>
	<874osbu5c8.fsf@twilight.int.mornfall.net.>
	<87fxbusglm.fsf@twilight.int.mornfall.net.>
Message-ID: <20090814171655.GB7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Aug 14, 2009 at 02:52:05PM +0200, Peter Rockai wrote:
> As for orphan/global locks, even if we don't strictly *need* the new behaviour,
> it wouldn't hurt -- and it buys us consistency to have all file locks go this
> route.
 
Milan and I discussed it yesterday and concluded we *did* actually desire the
new behaviour for those locks:-)

> Ok to apply?
 
Ack.

Alasdair


