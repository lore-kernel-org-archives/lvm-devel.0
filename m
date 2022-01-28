From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 28 Jan 2022 22:06:21 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
	<e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
	<0a55dd1393df2c125f8cb443daaeb7d1b7162bcc.camel@suse.com>
Message-ID: <aba2f6dd-f4cf-6af4-e2b6-965f5de06cd8@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28. 01. 22 v 19:46 Martin Wilck napsal(a):
> On Fri, 2022-01-28 at 18:47 +0100, Zdenek Kabelac wrote:
>> Dne 28. 01. 22 v 17:02 Martin Wilck napsal(a):
>>> On Fri, 2022-01-28 at 16:57 +0100, Martin Wilck wrote:
>>>> It's a race condition. It probably happens while multipathd is
>>>> reloading a map (*), suspending it during the table reload. The
>>>> device
>>>> will be resumed a few fractions of a second later (so yes, it's
>>>> "quick"), but then it's too late
>>> More precisely: The suspend state itself may actually not last
>>> longer
>>> than a few ms. But once the symlink is bent to point to the wrong
>>> device, it will remain so, until the CHANGE event following the
>>> device
>>> resume is successfully processed by udev, which may happen
>>> substantially later. And it's that longer time span which matters
>>> for
>>> systemd's mount attempt (or LVM device activation, for that
>>> matter).
>>>
>>>
>>
>> This looks like you are trying to mask-out different synchronization
>> bug.
> Please explain. What bug would that be, in what subsystem??It takes
> time until a dm-triggered CHANGE event makes its way through the udev
> event queue and completes rules processing. That's perfectly normal.


Well it is at the point we need to know exactly which device in which state 
causes you problem. Then we need to see what is wrong in the whole process.

All I'm saying here is - that the proposed patch is not fixing bug - but 
rather masking/minimizing window for error.

> I say the bug is in this udev rule file. The set of properties and
> symlinks of a systemd-managed device must not change when new uevents
> for this device are processed, unless absolutely necessary. The current


The question is - whether the event is meant to be there if there is no 
change, that should be reflected in the system. It really goes to #1 question 
about detailed state of DM tables and your observed blocked system.? With lvm2 
we are carefull about sending events.

> rule violates this principle: If a device that contains a file system
> is suspended, it continues to contain this file system, and the by-uuid
> symlink for the file system should be preserved.
> You can easily test this. Check the set of symlinks for a partition on
> a multipath device, suspend the device, run "udevadm trigger -c add" on
> the device (simulating coldplug), and check the set of symlinks again.

Whoever reads suspended device has to wait for 'resume' - so the test case 
where you suspend device for long period of time and you observe other 
processed waiting for device to be resumed is wanted behavior - it's not valid 
to have? suspended devices in the system.? You have state 'before' suspend? 
and state after 'resume'. ? There is no state for 'suspended' type of device 
(as the device could be resumed either with exiting table or a new table.

So any simulation relaying on suspended device is basically testing invalid 
state of system.

And I'm assuming your problem is something else - as I'd say you don't leak 
forgotten 'suspended' device in ramdisk ?


> You'll see that by-uuid or by-label links will be lost and will now
> point to one of the map's paths. These symlinks are crucial for
> mounting file systems. With my patch, the symlinks are preserved.


I'm still missing why 'UUID' should be lost ?

Where they missing before suspend ?

Are they lost after resume ?

What is causing your UUID to be lost ?

To connect this with lvm2 logic -? when lvm2 creates or deletes device - it 
always waits for udev confirmation? (ATM via cookie semaphore). So i.e. we 
can't create a situation where we would be triggering? 'udev' disk creation 
event that would be 'racing' with? udev disk removal processing - so there is 
close synchronization to avoid these kind of races where udev would be 
accessing? our LV devices in some? async parallel logic and possibly would 
have 'modifed' its symlink database with some obsolete info.


>> Also it's worth to note - using symlinks is somewhat doomed on its
>> own.
> That's how device identification and activation with udev and systemd
> works. It won't change any time soon. Explain on which grounds you're
> calling it "somewhat doomed".

You could find my discussion with Lennart? - one of major design problem of 
symlinks is it can't handle duplicate devices with same IDs.? So if you have 
multiple disks with same identification - symlinks will be randomly switching 
between them -? so plain simple 'dd? if=diskA of=diskB' ruins symlinks in your 
system.

>> So you only solve a very minor subcase where you manage to 'hit' your
>> race
>> just in a moment where you device is suspend and you actually 'scan'
>> state of
>> device.
> I wouldn't call it "minor" if a system fails to boot. The time window
> when this is possible is indeed small. But it's not zero, and that's
> why this issue occurs.


I'm not saying 'non-booting' system is 'minor' problem - rather I'm saying 
your proposed fix is not the correct fixing for your existing problem.

>> But what happen - if device would happen to be already resumed ?
> Nothing bad happens. The device is mounted or scanned just fine.


How could you get wrong UUID for already mounted (so likely also opened) device??

What is happening with your device that existing udev rule is generating 
incorrect symlink ?

That really needs close log evidence about states of your system.

>> It looks like there is some race in udev rules processing - just
>> somewhere else.
> I've personally had a part in fixing multiple race conditions both
> multipathd and udev.?Ben Marzinski and I recently worked on dropping
> the dependency of multipathd.service on udev-settle.service. That
> accellerates booting and is conceptually cleaner than before, but it
> reveals bugs in other parts of the system, like this one.

And we need to find the fix for the bug - not just mask it out.

As technically udev is just one of many possible 'readers' of your device. So 
while you would mask bug for udev - other device users would still get 
misleading info about your device.


> I would appreciate if you said what's actually wrong my patch. So far
> you haven't. You just speculated about errors in other parts of the


As said the automatic? 'skip'? of read of suspend device can't be the right thing.

Suspend is parallel&invisible operation and as such? any reader of device is 
meant to wait till device is resumed and finish it's reading. That's the core 
idea of whole DM usage -? all users of DM devices use it like normal block 
device.? So if you need to check state of DM device? (and you are not a DM 
maintaining tool? and blkid tool certainly is not such tool)? then there is 
something wrong in design? (aka we do not want to support 'skip' of udev rules 
if user is running? random stream? of 'dmsetup suspend & dmsetup resume' commands)


Regards

Zdenek


