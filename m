From: Petr Rockai <prockai@redhat.com>
Date: Thu, 09 Jul 2009 21:54:22 +0200
Subject: [PATCH] unknown segment types, part 1
In-Reply-To: <4A56288F.4080604@redhat.com> (Milan Broz's message of "Thu, 09
	Jul 2009 19:27:43 +0200")
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
	<4A56288F.4080604@redhat.com>
Message-ID: <87k52h8wep.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> - Why activate "unknown" segment by replacing it by error segment?
> I think that ignoring LV including unknown segment (with some error message)
> but not activate is better.
Good question, and I don't really know: this was the first thing that I thought
of and I particularly don't insist that it is a good idea. I left that in
because so far there's no other logic that would flag the LV to prevent
activation. Using error segment should at least limit any possible
damage. Maybe we should recycle the "partial" flag for this purpose as well: in
a sense, the LV "is there" but has parts (the unknown segment) missing. Or
maybe make a new flag to avoid possible confusion. What do you think?

> Or use some configurable option? 
I'd say no, unless it turns out to be really useful (which I doubt).

> - Do we want code to preserve (read: kill unknown options) metadata when
> segment handler is not loaded?
>
> Isn't better just allow only read-only metadata operation
> (so "unknown" segment will appear only in-memory metadata, never on-disk).
(non-issue, as discussed in the other sub-thread)

> Possibly add some option to vgck to "fix" unknown segments.
I'd say lvremove could do, in fact. There won't be much use for such a crippled
LV, presumably.

Yours,
   Petr.


