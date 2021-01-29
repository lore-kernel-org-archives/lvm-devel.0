From: Martin Wilck <mwilck@suse.com>
Date: Fri, 29 Jan 2021 18:58:04 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <1a60a927-7601-2acf-ac32-44c55a19ebd6@redhat.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
	<968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
	<1a60a927-7601-2acf-ac32-44c55a19ebd6@redhat.com>
Message-ID: <e42a9f07af2059c60dc26254ddb2d3f5c0a1ca07.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2021-01-29 at 17:38 +0100, Zdenek Kabelac wrote:
> Dne 29. 01. 21 v 14:02 Martin Wilck napsal(a):
> > On Fri, 2021-01-29 at 12:11 +0100, Zdenek Kabelac wrote:
> > > 
> > > The reason why "udev" is not default is simply because ATM it's
> > > unreliable
> > > source of info. It works well only for couple device types - but
> > > for
> > > lot of
> > > others it is not actual (i.e. network storage) (there are even no
> > > events
> > > generated for updating udev)
> > 
> > What kind of network storage?
> > 
> > > If we would have thought for a minute that 'udev' is good generic
> > > default - it would be already done....
> > 
> > The udev source (DEV_EXT_UDEV) is only used in 5 places, all in the
> > filtering code path:
> > 
> > ? a) dev_is_md_component()
> > ? b) _dev_is_mpath()
> > ? c) dev_is_partitioned()
> > ? d) _dev_is_fwraid()
> > ? e) check_pv_min_size()
> > 
> > I think we agree that "udev" is more reliable than "none" in case
> > a)
> > and b). For which of the above is "udev" unreliable, why, and why
> > can't
> > it be fixed?
> 
> Unfortunately I can't agree.

That's how I interpreted your prior remark:

> > But you are right that mpath knowledge is the one well maintained...

Misunderstanding, ok.

> Udev ONLY works well on systems without any problems. As soon as your
> devices start to be temporarily missing or you have 'duplicate'
> device,
> the whole udevDB becomes invalid.

Being an active multipath developer, I know that problem quite well.
In multipath-tools, we've found ways to deal with (almost)
all this weirdness though, I'd say. Corner cases remain.

> While with lvm2 you can filter out particular device set - with udev
> the
> system cannot be trusted at all.

> > "multipath_component_detection", which suggests that
> > no additional filtering is necessary. Unfortunately
> > "multipath_component_detection" is broken without
> > 'external_device_info_source="udev"'.
> 
> It is not broken, it just only works with 'active' mpath devices.
> User typically doesn't want to run lvm2 command while mpath is
> not running, so problem usually happens on misconfigured system.
> With running mpath - detection works.

This is where I disagree. The error scenarios we observed go roughly as
follows:

 - SCSI devices are being probed
 - some SCSI disk is discovered, "add" "block" uevent follows
 - multipath is run in udev rules, decides it's an mpath leg
   -> SYSTEMD_READY=0
 - multipathd sets up a map with the new path
 - "change block" uevent for the map
 - the map is now ready for upper layers to process.?
   lvm2-pvscan at .service will be run on it
 - meanwhile, other SCSI devices have beeen detected but not fully
processed yet
 - depending on timing, the pvscan instance running for the the map
   just created can grab these SCSI devices before multipathd can
   set them up. This happens because LVM doesn't honor the
   SYSTEMD_READY property.
   
I suppose you'd reply that such a system was misconfigured because
the user should have added appropriate lvm filter rules. I agree,
if that's done, the issue can't happen. But
"multipath_component_detection" alone doesn't prevent it. That's what I
wanted to say.

> So external info is only needed for systems which have mpath
> stopped/
> disable and yet the user wants/tries to manipulate with VG? - I'd not
> say this as a most common use-case.

If this was our experience, I'd never had considered using
external_device_info_source="udev" :-)


> Not really a fault of lvm2 here - we would like to use some
> reliable source of info - but udev in our testings can't deliver
> correct info even on loaded system.
> There is not even existing mechanism to synchronize with udev.
> So there would need to be ton of sleeps and retries everywhere...

What kind of test scenario were you using?

> > > 1st. we should define what kind of problem you try to solve
> > > and eventually open BZ (since list is not best for tracking
> > > progress).
> > > 
> > > Is is detection of 'mpath leg' while mpath is offline
> > > and user is not able to set his filters properly ?
> > 
> > See above. Our aspiration is to make multipath+md+LVM setups work
> > out-
> > of-the-box, reliably.
> 
> I hope you do not think we have different goals - but the acceptable
> solution must be reliable - not something that works only on
> shiny day with few disks and as soon as something becomes invalid,
> the 
> returned info can be very misleading.

Funny you say that :-) I proposed this patch precisely because in our
experience it *improves* reliability. So, we have the same goals, just
different experimental evidence.

I start to realize that our switching to
external_device_info_source="udev" was premature.?
You certainly have more test experience with it than we do.

> We just hope SID can finally move this udev to a more usable state.

I don't know enough about SID to judge. But I think the problem is
generic. Only the kernel knows which devices are present at any given
point in time. Any user space tool can only try to be as close as
possible. SID, being more focused in scope than udev, can probably do a
better job at that, but it will still lag behind, always.

> But please open BZ and list cases you think are broken - and we will
> see what's the best way to handle them.

Hm, opening Red Hat BZs for issues that occur in SUSE Linux Enterprise
tends to be tricky. We won't usually be able to reproduce our partner
or customer issues in environments that you support. More often than
not, we can't reproduce them on our own premises. Yet they exist.

> But from our experience and testing - enabling udev source give us so
> many 
> problems, we simply could not keep it as default.

Ok, got it. I still don't quite understand why it makes my patch wrong,
but never mind.

Thanks for your time.

Martin




