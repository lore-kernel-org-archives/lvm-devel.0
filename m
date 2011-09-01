From: Petr Rockai <prockai@redhat.com>
Date: Thu, 01 Sep 2011 17:54:06 +0200
Subject: [PATCH] Clear up the confusing "precommit(ed)" terminology
In-Reply-To: <4E5F9564.4060205@redhat.com> (Zdenek Kabelac's message of "Thu, 
	01 Sep 2011 16:23:32 +0200")
References: <18801.4269028374$1314817116@news.gmane.org>
	<4E5F9564.4060205@redhat.com>
Message-ID: <87vctc2r8h.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> I'm certainly not an English linguist expert here - but "notentative" looks
> even more weird.

Well, notentative is a sed artefact, and can (and should) be cleaned
up. I did not because it's not even clear what it was supposed to mean
even before (because the same thing is apparenty called precommit and
noprecommit in different places?).

> For my understanding precommit made more sense then tentative  - I'm not
> objecting the idea of cleaning it - but this term makes it even more
> confusing.  If we are going to use  2-phase commit - I'd use term
> phase1/phase2 here.

Only that this is not a 2-phase commit. This is a write and a
commit. The "precommit" does not commit anything, and is *not* part of
the commit per se. Think in terms of a transaction:

vg = vg_open(...) // open a transaction, acquire lock

// do stuff

vg_write(...) // write an intermediate state

// do more stuff

vg_write(...) // realize you need to actually write a different version

if (everything_ok)
    vg_commit(vg); // commit the transaction
else
    vg_revert(vg); // abort the transaction

If vg_write was phase1 of a commit, it would make no sense to do
anything between phase1 (vg_write) and phase2 (vg_commit). Even the
existing code (which uses the concept of transaction only very
cautiously) already needs to do things between the write and the commit.

On the other hand, dragging in two-phase commit terminology (which
normally describes a distributed database transaction protocol; we do no
such thing) would add even more confusion...

Yours,
   Petr


-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


