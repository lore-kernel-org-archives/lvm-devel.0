From: Martin Wilck <mwilck@suse.com>
Date: Sat, 29 Jan 2022 00:21:00 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
	<aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
Message-ID: <92de9eff521e2702e364f7aa3cce6927d9d9c03c.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2022-01-28 at 22:06 +0100, Zdenek Kabelac wrote:
> Dne 28. 01. 22 v 19:46 Martin Wilck napsal(a):
> > On Fri, 2022-01-28 at 18:47 +0100, Zdenek Kabelac wrote:
> > > Dne 28. 01. 22 v 17:02 Martin Wilck napsal(a):
> > > > On Fri, 2022-01-28 at 16:57 +0100, Martin Wilck wrote:
> > > > > It's a race condition. It probably happens while multipathd
> > > > > is
> > > > > reloading a map (*), suspending it during the table reload.
> > > > > The
> > > > > device
> > > > > will be resumed a few fractions of a second later (so yes,
> > > > > it's
> > > > > "quick"), but then it's too late
> > > > More precisely: The suspend state itself may actually not last
> > > > longer
> > > > than a few ms. But once the symlink is bent to point to the
> > > > wrong
> > > > device, it will remain so, until the CHANGE event following the
> > > > device
> > > > resume is successfully processed by udev, which may happen
> > > > substantially later. And it's that longer time span which
> > > > matters
> > > > for
> > > > systemd's mount attempt (or LVM device activation, for that
> > > > matter).
> > > > 
> > > > 
> > > 
> > > This looks like you are trying to mask-out different
> > > synchronization
> > > bug.
> > Please explain. What bug would that be, in what subsystem??It takes
> > time until a dm-triggered CHANGE event makes its way through the
> > udev
> > event queue and completes rules processing. That's perfectly
> > normal.
> 
> 
> Well it is at the point we need to know exactly which device in which
> state 
> causes you problem. Then we need to see what is wrong in the whole
> process.

This is how multipathd loads the multipath map before the error occurs:

[  127.352614] localhost multipathd[1059]: 3600a098000aad1e300000b4b5a275d45: reload [0 134217728 multipath 3 pg_init_retries 50 queue_if_no_path 1 alua 2 1 service-time 0 1 1 8:80 1 service-time 0 2 1 8:16 1 8:144 1]


The mapping of the partition device is this (after boot):

# dmsetup table /dev/dm-13
0 133953503 linear 254:10 264192

# dmsetup ls --tree # excerpt
3600a098000aad1e300000b4b5a275d45-part2 (254:13)
 ??3600a098000aad1e300000b4b5a275d45 (254:10)
    ?? (8:144)
    ?? (8:16)
    ?? (8:80)

Here you can see the links that udev creates for the device when it's
set up during initrd processing (note the by-uuid link):

[   40.611989] localhost systemd-udevd[555]: dm-13: Handling device node '/dev/dm-13', devnum=b254:13
[   40.612073] localhost systemd-udevd[555]: dm-13: Creating symlink '/dev/mapper/3600a098000aad1e300000b4b5a275d45-part2' to '../dm-13'
[   40.612374] localhost systemd-udevd[555]: dm-13: Atomically replace '/dev/disk/by-id/wwn-0x600a098000aad1e300000b4b5a275d45-part2'
[   40.612476] localhost systemd-udevd[555]: dm-13: Creating symlink '/dev/disk/by-id/dm-uuid-part2-mpath-3600a098000aad1e300000b4b5a275d45' to '../../dm-13'
[   40.612827] localhost systemd-udevd[555]: dm-13: Atomically replace '/dev/disk/by-partuuid/1c2f70e0-fb91-49f5-8260-38eacaf7992b'
[   40.612980] localhost systemd-udevd[555]: dm-13: Creating symlink '/dev/disk/by-id/dm-name-3600a098000aad1e300000b4b5a275d45-part2' to '../../dm-13'
[   40.613222] localhost systemd-udevd[555]: dm-13: Atomically replace '/dev/disk/by-id/scsi-3600a098000aad1e300000b4b5a275d45-part2'
[   40.613502] localhost systemd-udevd[555]: dm-13: Atomically replace '/dev/disk/by-uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0'
[   40.613531] localhost systemd-udevd[555]: dm-13: Preserve already existing symlink '/dev/block/254:13' to '../dm-13'

The by-uuid link is then removed after switching root as I showed 
in my previous post. The reason is that the respective SYMLINK line in
13-dm-disk.rules is skipped for suspended devices, and my patch fixes
that.

At the time this happens, the same partiton _is already mounted_ as
btrfs root file system. This file system has multiple subvolumes for
/tmp, /var, /usr/local, etc., which need to be mounted after switching
root. The problem occurs when these mounts are attempted. Typically
some succeed, and some don't, depending on the timing.

> All I'm saying here is - that the proposed patch is not fixing bug -
> but 
> rather masking/minimizing window for error.

AFAICS my patch eliminates the window for this error entirely.

> > I say the bug is in this udev rule file. The set of properties and
> > symlinks of a systemd-managed device must not change when new
> > uevents
> > for this device are processed, unless absolutely necessary. The
> > current
> 
> 
> The question is - whether the event is meant to be there if there is
> no 
> change, that should be reflected in the system. It really goes to #1
> question 
> about detailed state of DM tables and your observed blocked system.?
> With lvm2 
> we are carefull about sending events.

The coldplug "add" event always happens. It can't be avoided. It is
necessary to make user-space aware of the device after switching root.
And device-mapper rules go into great detail how they deal with it, as
you are certainly aware.

> 
> > rule violates this principle: If a device that contains a file
> > system
> > is suspended, it continues to contain this file system, and the by-
> > uuid
> > symlink for the file system should be preserved.
> > You can easily test this. Check the set of symlinks for a partition
> > on
> > a multipath device, suspend the device, run "udevadm trigger -c
> > add" on
> > the device (simulating coldplug), and check the set of symlinks
> > again.
> 
> Whoever reads suspended device has to wait for 'resume'

I suppose if mount(8) opened /dev/dm-13 directly, it would just hang
while the device was suspended, and start IO afterwards. But this isn't
how this works. mount(8) opens the /dev/disk/by-uuid symlink which now
points to the underlying device (sdb2 - udev bent the symlink to point
to sdb2 after it was dropped from dm-13). Opening sdb2 doesn't hang, it
fails with -EBUSY because the device is locked by dm. Thus the mount
fails. mount(8) has no way to detect why this is so. systemd might, and
might attempt a retry, but it  lacks the logic for doing that.

> > - so the test case 
> where you suspend device for long period of time and you observe
> other 
> processed waiting for device to be resumed is wanted behavior - it's
> not valid 
> to have? suspended devices in the system.??

Unfortunately dm devices are often suspended for a short period of
time, when their table is reloaded. As I pointed out before, it's
normal for this to happen during multipath startup, when paths are
added or removed, priority groups switched, etc.

> You have state 'before' suspend? 
> and state after 'resume'. ? There is no state for 'suspended' type of
> device 
> (as the device could be resumed either with exiting table or a new
> table.

So: the mapping could be entirely different when the device is resumed,
and if systemd tried to mount it in the time span between the resume
and the finish of the uevent that follows, it might mount a totally
different file system. Is that what you mean? If yes, I suppose you're
right. But isn't that possible today already? Couldn't I reload a
mapping with totally different devices and offsets, while it is
mounted?

At least for multipath, that's extremely unlikely to happen, whereas
quick reloads with a similar mapping that doesn't affect upper layers
are very common.

If you take the above seriously, you need to rewrite your code for
communicating with udev and systemd. I guess systemd itself would need
to change the way it handles dm devices, fundamentally. Basically you
would need to tell systemd to consider a suspended device as unusable,
and not make it available to the system again before it's resumed in a
state that's verified to be compatible with the previous state. And
we'd need deal with the special caveats for multipath, too.


> So any simulation relaying on suspended device is basically testing
> invalid 
> state of system.
> 
> And I'm assuming your problem is something else - as I'd say you
> don't leak 
> forgotten 'suspended' device in ramdisk ?

No, everything is perfectly fine in the initrd. And afterwards, all is
fine, too - except if, by very bad luck, the timing is such that?

 a) the coldplug "add" event happens?while the device is suspended
    (as I said, probably due to a reload operation)
 b) systemd tries to mount the file system during the short time span
in which the symlinks are missing (i.e. between the resume and the
final processing of the CHANGE event).

In my testing, this happens only on one system, roughly once every 50
reboots.

> 
> > You'll see that by-uuid or by-label links will be lost and will now
> > point to one of the map's paths. These symlinks are crucial for
> > mounting file systems. With my patch, the symlinks are preserved.
> 
> 
> I'm still missing why 'UUID' should be lost ?

The link is bound to udev's ID_PART_ENTRY_UUID property. This property
is set by IMPORT{buidltin}="blkid", or using
IMPORT{db}="ID_PART_ENTRY_UUID". The latter is done by 11-dm-
mpath.rules and 11-dm-parts.rules, for example, exactly for the same
reason - we can't risk loosing the symlink because blkid fails. This
works nicely, unless DM_SUSPENDED or DM_NOSCAN is set, because in this
case 13-dm-disk.rules won't call SYMLINK.

> Where they missing before suspend ?

No.

> Are they lost after resume ?

No, after resume udev reinstates them, but then it's too late.

> What is causing your UUID to be lost ?

The UUID is never lost. Only the symlink that reflects it.

> 
> To connect this with lvm2 logic -? when lvm2 creates or deletes
> device - it 
> always waits for udev confirmation? (ATM via cookie semaphore). So
> i.e. we 
> can't create a situation where we would be triggering? 'udev' disk
> creation 
> event that would be 'racing' with? udev disk removal processing - so
> there is 
> close synchronization to avoid these kind of races where udev would
> be 
> accessing? our LV devices in some? async parallel logic and possibly
> would 
> have 'modifed' its symlink database with some obsolete info.

multipathd does that, too. But it doesn't apply here. Because the
device is live (system has mounted it in the initramfs already and it's
actually mounted at the time all this happens, see above). Yet the
coldplug event does arrive, we can't avoid it. 

(Well we could, at least partly, by delaying multipathd startup until
after "udev settle" again, but I'm sure Ben agrees with me that we'd
rather not do that).
> 
> 
> > > Also it's worth to note - using symlinks is somewhat doomed on
> > > its
> > > own.
> > That's how device identification and activation with udev and
> > systemd
> > works. It won't change any time soon. Explain on which grounds
> > you're
> > calling it "somewhat doomed".
> 
> You could find my discussion with Lennart? - one of major design
> problem of 
> symlinks is it can't handle duplicate devices with same IDs.? So if
> you have 
> multiple disks with same identification - symlinks will be randomly
> switching 
> between them -? so plain simple 'dd? if=diskA of=diskB' ruins
> symlinks in your 
> system.

udev has it's link priority concept for this reason. It may not be
perfect but it works quite well, and the symlink handling has improved
a lot lately. I am curious what your alternative concept is. Do you
have a link?

> [...]
> 
> How could you get wrong UUID for already mounted (so likely also
> opened) device??

Why do you say "wrong UUID" ? The UUID was correct all the time.
I explained above what happened. Yes, the device was mounted (to other
btrfs subvolumes) when the error occured.

> What is happening with your device that existing udev rule is
> generating 
> incorrect symlink ?
> 
> That really needs close log evidence about states of your system.

Believe me, I have scrutinized these logs very carefully. I've already
told you the relevant parts of it.?But as you asked for it:
https://www.dropbox.com/sh/ks946a8wjos97ji/AAAVtOK3Z3XpbQ7DFzE1ykaYa?dl=0

> > > It looks like there is some race in udev rules processing - just
> > > somewhere else.
> > I've personally had a part in fixing multiple race conditions both
> > multipathd and udev.?Ben Marzinski and I recently worked on
> > dropping
> > the dependency of multipathd.service on udev-settle.service. That
> > accellerates booting and is conceptually cleaner than before, but
> > it
> > reveals bugs in other parts of the system, like this one.
> 
> And we need to find the fix for the bug - not just mask it out.

> As technically udev is just one of many possible 'readers' of your
> device. So 
> while you would mask bug for udev - other device users would still
> get 
> misleading info about your device.

The only thing that's misleading here is the fact that udev removes the
device symlinks because the rules file don't execute the SYMLINK
directives. All else is  fine. "My device" is in a sane state.

> > I would appreciate if you said what's actually wrong my patch. So
> > far
> > you haven't. You just speculated about errors in other parts of the
> 
> 
> As said the automatic? 'skip'? of read of suspend device can't be the
> right thing.

But that is not what my patch does, as I already explained. The reading
was skipped anyway, and this has been so since the file came into
existence. Please look at the history of the file. All I am changing is
to prevent the symlinks from being deleted prematurely.

All I want to achieve here is fix a nasty multipath boot failure.
I think we agree that the handling of dm devices by udev and systemd is
not optimal. But my goal with this patch is not to save that generic
problem. That's something you need to work out with Lennart and his co-
workers. My estimate is that a proper solution would take a year or
more of intensive work.

> 
> Suspend is parallel&invisible operation and as such? any reader of
> device is 
> meant to wait till device is resumed and finish it's reading. That's
> the core 
> idea of whole DM usage -? all users of DM devices use it like normal
> block 
> device.? So if you need to check state of DM device? (and you are not
> a DM 
> maintaining tool? and blkid tool certainly is not such tool)? then
> there is 
> something wrong in design? (aka we do not want to support 'skip' of
> udev rules 
> if user is running? random stream? of 'dmsetup suspend & dmsetup
> resume' commands)

What's "wrong in design" here is that udev can't afford to wait for a 
device to be resumed. If the device is suspended, blkid can't be
called, period. In this case we are in jeopardy, by definition. We have
to make some assumption. We can assume that the by-uuid link is still
valid, like my patch does, and risk that the assumption is wrong. Or
simply drop the symlink, as the current code does, and break systemd's
assumptions.

Discuss this with Lennart, please. It means that systemd needs to
change it's device handling fundamentally. But really, this goes much
further than what I'm currently interested in. I just want to make sure
these systems boot reliably.

If you can't take this for generic dm, we'll have to find a way to do
it in the multipath rules. This is where where we run IMPORT{db} anyway
to avoid failures. It will be far less elegant because it means code
duplication (13-dm-disk.rules is where this logic belongs), but well,
I guess this is the price we have to pay if we can't agree.

Regards
Martin



