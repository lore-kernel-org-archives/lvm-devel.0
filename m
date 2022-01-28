From: Martin Wilck <mwilck@suse.com>
Date: Fri, 28 Jan 2022 19:46:48 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
Message-ID: <0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2022-01-28 at 18:47 +0100, Zdenek Kabelac wrote:
> Dne 28. 01. 22 v 17:02 Martin Wilck napsal(a):
> > On Fri, 2022-01-28 at 16:57 +0100, Martin Wilck wrote:
> > > 
> > > It's a race condition. It probably happens while multipathd is
> > > reloading a map (*), suspending it during the table reload. The
> > > device
> > > will be resumed a few fractions of a second later (so yes, it's
> > > "quick"), but then it's too late
> > 
> > More precisely: The suspend state itself may actually not last
> > longer
> > than a few ms. But once the symlink is bent to point to the wrong
> > device, it will remain so, until the CHANGE event following the
> > device
> > resume is successfully processed by udev, which may happen
> > substantially later. And it's that longer time span which matters
> > for
> > systemd's mount attempt (or LVM device activation, for that
> > matter).
> > 
> > 
> 
> 
> This looks like you are trying to mask-out different synchronization
> bug.

Please explain. What bug would that be, in what subsystem??It takes 
time until a dm-triggered CHANGE event makes its way through the udev
event queue and completes rules processing. That's perfectly normal.

I say the bug is in this udev rule file. The set of properties and
symlinks of a systemd-managed device must not change when new uevents
for this device are processed, unless absolutely necessary. The current
rule violates this principle: If a device that contains a file system
is suspended, it continues to contain this file system, and the by-uuid
symlink for the file system should be preserved.

You can easily test this. Check the set of symlinks for a partition on
a multipath device, suspend the device, run "udevadm trigger -c add" on
the device (simulating coldplug), and check the set of symlinks again.
You'll see that by-uuid or by-label links will be lost and will now
point to one of the map's paths. These symlinks are crucial for
mounting file systems. With my patch, the symlinks are preserved.

> Also it's worth to note - using symlinks is somewhat doomed on its
> own.

That's how device identification and activation with udev and systemd
works. It won't change any time soon. Explain on which grounds you're
calling it "somewhat doomed".

> So you only solve a very minor subcase where you manage to 'hit' your
> race
> just in a moment where you device is suspend and you actually 'scan'
> state of 
> device.

I wouldn't call it "minor" if a system fails to boot. The time window
when this is possible is indeed small. But it's not zero, and that's
why this issue occurs.

> But what happen - if device would happen to be already resumed ?

Nothing bad happens. The device is mounted or scanned just fine.

> It looks like there is some race in udev rules processing - just
> somewhere else.

I've personally had a part in fixing multiple race conditions both
multipathd and udev.?Ben Marzinski and I recently worked on dropping
the dependency of multipathd.service on udev-settle.service. That
accellerates booting and is conceptually cleaner than before, but it
reveals bugs in other parts of the system, like this one.

> I think Peter could more enlighten the lvm2 logic - but it seems
> there is 
> possibly missing similar logic on multipath side in the moment when
> devices 
> are created ?

As long as you don't explain what logic you mean, this is a hard
question to answer.

> There should be no race when switching from ramdisk to rootfs.

I agree that there *should* not be any. But there is one, and this
patch fixes it.

I would appreciate if you said what's actually wrong my patch. So far
you haven't. You just speculated about errors in other parts of the
system. Are you saying my patch would cause regressions or errors? If
yes, how would that come to pass, for which devices, and under which
conditions?

Regards,
Martin



