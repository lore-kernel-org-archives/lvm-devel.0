From: Petr Rockai <prockai@redhat.com>
Date: Wed, 16 Nov 2011 10:41:16 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <20111116012039.GB3294@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 16 Nov 2011 01:20:39 +0000")
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
Message-ID: <87ehx8xv43.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> Let's not add it then in response to a bug fix.
>
> If the cmd exits OK, there's only really one code we should return for
> shell scripts.  Splitting 'OK' into 'OK - something changed' and
> 'OK - but nothing was changed' doesn't seem worth the effort and
> adding a new code for one special case is the thin end of the wedge.
>
> (If there's nothing to do and use_policies was given, it can just
> return the normal OK?)

That's what used to happen until now.

> Why does it loop every 10 seconds?  Is there another way to stop it?

No, there is not. (See below.)

> 1) Is there some problematic interaction between the configurable
> (or even default) parameters that's causing problems?  Do some
> parameters sometimes need overriding or constraining?
> We should list the parameters and any constraints and make sure the
> code deals with them.
> (This might be going beyond the specific problem that Corey found,
> but suggesting related problems to fix.)

No, this is not a problem and is not related to the fix at hand.

> 2) One auto-extend should always be enough to deal with the notified
> event.
>   - It should pass in the minimum required extension and use_policies
> should take account of that.

See above, and my previous mail as well. This is *not* a problem (and
most definitely not _the_ problem). This is all about multiple
"events". Only that we do not get any actual events from the kernel, so
we poll every ten seconds. And to avoid actually running lvresize every
10 seconds, we cache the outcome of the last check and only re-run
lvresize if things "changed" from the last time.

Petr

PS: If the separate exit code is not acceptable, there are other ways to
fix this, but they involve more substantial changes to the snapshot
DSO. It's your call whether it's worth complicating the logic and
increasing the risks by going that way.

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


