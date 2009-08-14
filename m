From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 Aug 2009 18:12:34 +0100
Subject: Re: [PATCH] Re: [linux-lvm] Clarifications wanted about locking process
In-Reply-To: <87my62sjie.fsf_-_@twilight.int.mornfall.net.>
References: <7fcd249b0908131713x6aeddd5bm8975df94d3c3a39a@mail.gmail.com>
	<20090814082407.GY7033@agk-dp.fab.redhat.com>
	<87my62sjie.fsf_-_@twilight.int.mornfall.net.>
Message-ID: <20090814171234.GA7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Aug 14, 2009 at 01:49:13PM +0200, Peter Rockai wrote:
> The attached patch should fix the issue. I believe that taking a global write
> lock while scanning is a mistake (I consulted with Milan, he says it only
> serves to enable metadata caching).
 
Well only one instance of pvscan and/or vgscan is allowed to run at once,
and IIRC VG_GLOBAL with LCK_VG_WRITE is what enforces that.

IOW The write lock is correct.  

See the comment in toollib:

/*
 * If the lock_type is LCK_VG_READ (used only in reporting commands),
 * we lock VG_GLOBAL to enable use of metadata cache.
 * This can pause alongide pvscan or vgscan process for a while.
 */

I don't want to touch the VG_GLOBAL logic here at this stage.

Are there any problems with just excluding an already-held VG_GLOBAL from the
test that generates this error message?

Alasdair


