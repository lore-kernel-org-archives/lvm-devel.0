From: Neil Brown <neilb@suse.de>
Date: Thu, 13 May 2010 09:19:20 +1000
Subject: dmeventd doesn't handle failures during mirror resync.
In-Reply-To: <874oim3h5i.fsf@twilight.int.mornfall.net.>
References: <20100429170140.777db964@notabene.brown>
	<874oim3h5i.fsf@twilight.int.mornfall.net.>
Message-ID: <20100513091920.251e4731@notabene.brown>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for the reply,

On Wed, 05 May 2010 10:08:09 +0200
Petr Rockai <prockai@redhat.com> wrote:

> Neil Brown <neilb@suse.de> writes:
> 
> > I was surprised to discover that while a normal write error is
> > handled properly - dmeventd runs 'lvconvert' to fix the array up,
> > this does not happen in response to a write error while syncing
> > the array.
> >
> > If I arrange for the new device to die, then 
> >           lvconvert --repair --use-policies
> >
> > will fix it up as I would expect, but dmeventd never asks it to do
> > this.
> >
> > This seems to be a deliberate decision:  in _process_status_code 
> > in dmeventd_mirror.c, a status of 'F' will cause lvconvert to be
> > run while 'S' and 'R' (sync and read errors) will not.
> >
> > Is there a reason for this?
> I think the rationale is that:
> 
> For read errors, we should *not* strip the mirror leg, since we want to
> keep as much redundancy as possible in this scenario. The failure should
> be logged, but I think that's it.

In general I would agree, though there are cases where you would want to
strip a leg based only on read errors.  If a drive is failing in a way that
all read attempts cause multiple retries and timeouts, then having that
device remain in the array can kill performance.

It seems therefore that this should be a policy based decision, possibly
involving extra testing, and the place for this would seem to be in lvconvert.

Hence the thrust of my argument, which is that dmeventd should always run
lvconvert on any event that is at all suspect, and lvconvert should make the
correct decision, which may be to leave the array alone.

Maybe lvconvert doesn't currently always make the 'correct' decision so
changing dmeventd might be premature, but I would like to know if you agree
that this is the best long-term strategy.

> 
> For sync, I am not sure. It may be that the reason for this is that sync
> is usually related to manual action and dmeventd intervention may be
> unexpected and unwanted in this case. But that case could be argued.
> 

If you are using dmeventd, then a write failure could easily cause lvconvert
to kick off a sync on a new device, so it could easily not be a manual action.


The main problem I see with the current arrangement is that if a device goes
missing during a sync and we don't 'lvconvert repair', then the next restart
will not succeed with "--partial" and that would cause problems rebooting.

Thanks,
NeilBrown


(please Cc: me, I'm not subscribed).

> > Can we change dmeventd to response to sync (and read) errors in the same
> > way that it responds to write errors?
> I think it's a bad idea for read errors, unless maybe we could have a
> new feature for that -- one that'd upconvert the mirror first (if
> there's a hotspare) and only if that finishes OK, kill the bad leg. Just
> log the error if there are no hotspares.
> 
> For sync errors, I am ambivalent. Any further opinions?
> 
> Yours,
>    Petr.


