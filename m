From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 28 Jan 2022 18:47:15 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
	<a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
	<d0d0d8f39257bcddf480524f01faae1f15ac2c42.camel@suse.com>
Message-ID: <e85bd660-0c50-df5d-35de-2fd5b16cc47f@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28. 01. 22 v 17:02 Martin Wilck napsal(a):
> On Fri, 2022-01-28 at 16:57 +0100, Martin Wilck wrote:
>>
>> It's a race condition. It probably happens while multipathd is
>> reloading a map (*), suspending it during the table reload. The
>> device
>> will be resumed a few fractions of a second later (so yes, it's
>> "quick"), but then it's too late
> 
> More precisely: The suspend state itself may actually not last longer
> than a few ms. But once the symlink is bent to point to the wrong
> device, it will remain so, until the CHANGE event following the device
> resume is successfully processed by udev, which may happen
> substantially later. And it's that longer time span which matters for
> systemd's mount attempt (or LVM device activation, for that matter).
> 
>


This looks like you are trying to mask-out different synchronization bug.

Also it's worth to note - using symlinks is somewhat doomed on its own.

So you only solve a very minor subcase where you manage to 'hit' your race
just in a moment where you device is suspend and you actually 'scan' state of 
device.

But what happen - if device would happen to be already resumed ?
It looks like there is some race in udev rules processing - just somewhere else.

I think Peter could more enlighten the lvm2 logic - but it seems there is 
possibly missing similar logic on multipath side in the moment when devices 
are created ?

There should be no race when switching from ramdisk to rootfs.

Regards

Zdenek


