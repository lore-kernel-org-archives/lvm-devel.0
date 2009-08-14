From: Petr Rockai <prockai@redhat.com>
Date: Fri, 14 Aug 2009 14:52:05 +0200
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <874osbu5c8.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Thu, 13 Aug 2009 17:00:07 +0200")
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
	<20090812225043.GR7033@agk-dp.fab.redhat.com>
	<874osbu5c8.fsf@twilight.int.mornfall.net.>
Message-ID: <87fxbusglm.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ok, this is the version of the patch with a suffix instead of prefix. (I just
usually trade robustness for fanciness -- relying on special characters strikes
me as unnecessarily brittle, but I concede.)

I also fixed the docs typo Dave pointed out yesterday. I didn't make any
further changes to the patch.

As for orphan/global locks, even if we don't strictly *need* the new behaviour,
it wouldn't hurt -- and it buys us consistency to have all file locks go this
route.

Ok to apply?

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: locking3.diff
Type: text/x-diff
Size: 4125 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090814/ead709be/attachment.bin>
