From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 8 Aug 2007 15:02:51 +0100
Subject: stack smash?
In-Reply-To: <87wsw78149.fsf@rho.meyering.net>
References: <871wegcw1q.fsf@rho.meyering.net>
	<20070807134704.GS2064@agk.fab.redhat.com>
	<87wsw78149.fsf@rho.meyering.net>
Message-ID: <20070808140251.GJ2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 07, 2007 at 11:51:18PM +0200, Jim Meyering wrote:
> isn't it overkill to limit all names to a
> length of < PATH_MAX - NAME_LEN - suffix_len, just to avoid the
> length check when renaming?
 
If you specify a configuration option that adds restrictions to some
standard operations, you need to find out immediately - at the time you
make the change - not months later when you're attempting an urgent
rename and you don't want to lose time changing your metadata
configuration too.

And as far as they can, the tools need to warn you your operation isn't
going to work *before* they start making any changes because we've
hardly any recovery logic in there: you'd be expected to clean up
manually after a failure like that one.

> I find the contrary (scope as tightly as possible) makes code more
> readable and more robust.
> [BTW, what's the motivation for it? ]
 
Readability:  While you can get away with it in tiny blocks for
variables only used in one place, as soon as people extend the code,
adding nesting or making blocks larger it takes more effort for someone
to read the code.  You see a variable and want to glance at its
declaration.  With nested blocks your eye has several places to search;
with C99 declaration-after-statement you've to search backwards through
the whole function.

Alasdair
-- 
agk at redhat.com


