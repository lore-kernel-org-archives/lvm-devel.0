From: Iustin Pop <iustin@google.com>
Date: Wed, 8 Jul 2009 10:50:03 +0200
Subject: [PATCH] Change lvextend to round up for stripped volumes
In-Reply-To: <20090707221754.GN11082@agk-dp.fab.redhat.com>
References: <1246481135-6358-1-git-send-email-iustin@google.com>
	<20090707221754.GN11082@agk-dp.fab.redhat.com>
Message-ID: <20090708085003.GB6490@google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 07, 2009 at 11:17:54PM +0100, Alasdair G Kergon wrote:
> On Wed, Jul 01, 2009 at 10:45:35PM +0200, Iustin Pop wrote:
> > Currently lvresize, when growing stripped volumes, rounds down if the
> > extents delta doesn't match exactly the full stripe size. This is
> > counterintuitive (we're requesting growth by X amount, and instead we
> > could get less than X, even though the operation succeded), and also
> > doesn't match the current behaviour in lvcreate (rounds up) and lvextend
> > for non-stripped volumes (which also rounds up).
>  
> The code is shared between lvextend and lvreduce, and accepts relative
> as well as absolute sizes, so the logic is not simple.

Ack. Thanks for pointing it out.

> The intent was for it to be cautious (consider a filesystem present
> requiring the precise size specified) by rounding up the amount of
> change when extending and rounding down the amount of change when
> reducing.

But the code doesn't do this. It always rounds down for grows of stripped
volumes, because the code that does adjust this doesn't care about which
direction (+ or -) we change the size).

For example, the initial rounding code (for non-stripped) does take into
account whether lp-> == SIGN_MINUS or not. But the strip rounding code doesn't
and always choses one direction of rounding.

I'll look again at the code and send another patch. I was under the wrong
impression that lp->extents is the final volume size, and not the delta, so
rounding lp->extents up is always safe.

thanks!
iustin


