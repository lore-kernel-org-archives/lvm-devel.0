From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 23:17:54 +0100
Subject: [PATCH] Change lvextend to round up for stripped volumes
In-Reply-To: <1246481135-6358-1-git-send-email-iustin@google.com>
References: <1246481135-6358-1-git-send-email-iustin@google.com>
Message-ID: <20090707221754.GN11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 01, 2009 at 10:45:35PM +0200, Iustin Pop wrote:
> Currently lvresize, when growing stripped volumes, rounds down if the
> extents delta doesn't match exactly the full stripe size. This is
> counterintuitive (we're requesting growth by X amount, and instead we
> could get less than X, even though the operation succeded), and also
> doesn't match the current behaviour in lvcreate (rounds up) and lvextend
> for non-stripped volumes (which also rounds up).
 
The code is shared between lvextend and lvreduce, and accepts relative
as well as absolute sizes, so the logic is not simple.

The intent was for it to be cautious (consider a filesystem present
requiring the precise size specified) by rounding up the amount of
change when extending and rounding down the amount of change when
reducing.

Alasdair


