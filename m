From: NeilBrown <neilb@suse.de>
Date: Wed, 23 Feb 2022 09:49:27 +1100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <4b61ca1eafb35e3fdfbc9bb260dc89d56d181499.camel@suse.com>
References: <20220216205914.7575-1-mwilck@suse.com>,
	<164504936873.10228.7361167610237544463@noble.neil.brown.name>,
	<e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>,
	<20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>,
	<164548656531.8827.3365536065813085321@noble.neil.brown.name>,
	<4b61ca1eafb35e3fdfbc9bb260dc89d56d181499.camel@suse.com>
Message-ID: <164557016782.28944.17731814770525408828@noble.neil.brown.name>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 23 Feb 2022, Martin Wilck wrote:
> Neil,
> 
> On Tue, 2022-02-22 at 10:36 +1100, NeilBrown wrote:
> > 
> > > The flags that DM use for udev were introduced before systemd
> > > project
> > > even existed. We needed to introduce the
> > > DM_UDEV_DISABLE_OTHER_RULES_FLAG
> > > to have a possibility for all the "other" (non-dm) udev rules to
> > > check
> > > for if there's another subsystem stacking its own devices on top of
> > > DM
> > > ones.
> > 
> > If this is an established API that DM uses, then presumably it is
> > documented somewhere.? If a link to that documentation were provided,
> > it
> > would look a a whole lot less like a hack.
> 
> Peter has provided a link to libdevmapper.h in his previous post in
> this thread. Is this a request for me to include that link in the patch
> description?

If libdevmapper.h is the best documentation there is for this variable,
then hopefully you can see why it feels to an outsider like a hack.

It isn't even immediately clear that the text there is talking about
environment variables visible in udev.
If there is an expectation that tools outside of lvm2 will use these,
then they really should be documented properly.  SYSTEMD_READY is
documented in "man systemd.device".  How hard would it be to write a
"dm-udev" man page which explains all this.

But if libdevmapper.h is the best you have, then maybe it'll have to do.
It is up to Jes what he accepts of course.

Thanks,
NeilBrown


