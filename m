From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 9 Feb 2010 23:01:26 -0500
Subject: a bug in snapshots
In-Reply-To: <Pine.LNX.4.64.1002092053560.3180@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002091904560.14493@hs20-bc2-1.build.redhat.com>
	<20100210003902.GA7441@redhat.com>
	<Pine.LNX.4.64.1002092053560.3180@hs20-bc2-1.build.redhat.com>
Message-ID: <20100210040125.GA24479@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 09 2010 at  8:57pm -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Tue, 9 Feb 2010, Mike Snitzer wrote:
> 
> > On Tue, Feb 09 2010 at  7:07pm -0500,
> > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > > Hi
> > > 
> > > Try to make a snapshot that is so big that it spans more than one physical 
> > > volume. Then, type "lvs" command. You get these errors:
> > > 
> > > [slunicko:/usr/src/LVM2.2.02.60]# lvs
> > >   Number of segments in active LV lvol1 does not match metadata
> > >   Number of segments in active LV lvol1 does not match metadata
> > >   Number of segments in active LV lvol1 does not match metadata
> > >   Number of segments in active LV lvol1 does not match metadata
> > >   LV    VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
> > >   lvol0 vg1  owi-a- 16.00m
> > >   lvol1 vg1  Swi-I- 60.00m lvol0  100.00
> > >   m     vg1  -wi-a- 64.00m
> > > 
> > > This bug was introduced in LVM2.2.02.59 with this change:
> > > 
> > > --- ./LVM2.2.02.58/lib/activate/dev_manager.c   2010-01-13 
> > > 02:55:44.000000000 +0100
> > > +++ ./LVM2.2.02.59/lib/activate/dev_manager.c   2010-01-15 
> > > 23:58:25.000000000 +0100
> > > @@ -584,7 +593,7 @@ int dev_manager_snapshot_percent(struct
> > >          * Try and get some info on this device.
> > >          */
> > >         log_debug("Getting device status percentage for %s", name);
> > > -       if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
> > > +       if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
> > >                        percent_range, NULL)))
> > >                 return_0;
> > > 
> > 
> > That change was part of this commit:
> > http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=13713bc147
> > 
> > I'm not seeing how this commit has any functional change for anything
> > other than snapshot-merge related snapshots.
> > 
> > All I did was pass lv into _percent() (and then _percent_run()) so that
> > I could inspect it to know if lv_is_merging_origin().
> > 
> > The vg1/lvol1's flags indicate the snapshot is set to merge and it is
> > also invalid.  Can you detail your testcase a bit more please?
> > 
> > Are you certain there isn't some other reason your test case is failing?
> > 
> > Mike
> 
> The problem is that when you pass non-NULL lv to _percent_run(), it tries 
> to verify that the number of segments in that lv is equal to the number of 
> targets. And it isn't --- the lv can have more than one segment but there 
> is just one "snapshot" target. That's why it fails.

I see.  I was too focused on the commit; didn't look at the rest of
_percent_run(), etc.

> What to do with it? Drop this verification? Or pass NULL as lv there, like 
> before?

Well the reality is we really shouldn't be passing a snapshot-origin
into _percent_run() to begin with.  I made it so that we filter it out
very late, in _percent_run, in cases where snapshot-merge completion
polling gets started even though the snapshot was not allowed to start
merging (as is possible if a snapshot or snapshot-origin is still open
when a 'lvchange --refresh origin' occurs).

So one thing we could do is move the lv_is_merging_origin() much earlier
and revert to passing a NULL lv to _percent().

Another option is to audit that segment count check in _percent_run()
and possibly only make that check for cases where it really matters.

Mike


