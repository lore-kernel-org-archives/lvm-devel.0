From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 31 Jan 2022 14:33:54 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <712b54a06fa1b13f9ac92a00d7b121979c43d31c.camel@suse.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
	<aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
	<92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
	<1b20e88f-2714-3c61-73a6-2f34f6a34edc@gmail.com>
	<712b54a06fa1b13f9ac92a00d7b121979c43d31c.camel@suse.com>
Message-ID: <20220131133354.vfomn5gdlgrhue4g@alatyr-rpi.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat 29 Jan 2022 21:46, Martin Wilck wrote:
> On Sat, 2022-01-29 at 21:05 +0100, Zdenek Kabelac wrote:
> > Dne 29. 01. 22 v 0:21 Martin Wilck napsal(a):
> > 
> > > 
> > > AFAICS my patch eliminates the window for this error entirely.
> > 
> > 
> > Ok now I see that there is already skip for DM_SUSPENDED
> > and you patch likely only tries to preserve some existing state of
> > links.
> > 
> > I'll need to get in touch with Peter here.
> > 
> > I guess the idea behind was to avoid read of device that will be
> > resumed and 
> > will automatically get a new event - and suspened device itself
> > cannot change 
> 
> Thank you!
> 
> > - but that fact it's been loosing existing state was missed - I'm
> > wondering 
> > why this was not seen as problem before.
> 
> One reason is that we're now starting multipathd earlier. This has a
> lot of advantages, but it reveals problems that were hidden behind the
> "After=systemd-udev-settle.service" dependency of mulltipathd before.

Hi!

(just discussed this with Zdenek too)

The patch makes sense to me!

We added all the DM_UDEV_PRIMARY_SOURCE_FLAG and related for exactly
such cases where we need to take the existing values already scanned
in previous event, main use-case being the trigger at boot. We just
didn't cover the 13-dm-disk.rules with the same logic regarding the
suspended state to keep the symlinks - I didn't think it would cause
issues (because, usually, after suspend, we anticipate incoming
resume where the device is scanned again).

But yes, if temporarily losing the symlink causes issues, your patch
solves that (Zdenek will push that upstream).

(There's one more situation with checking the suspended state for the
pvscan we have in 69-dm-lvm...rules, but that's lvm-specific, we'll
patch that one...)

Thanks!

-- 
Peter


