From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Sep 2012 10:12:57 +0200
Subject: [systemd-devel] cannot start swap unit on lvm
In-Reply-To: <CAPXgP125g3ix3NxvY7HNiOv__kwZM3mZd2_NBJjNS_rWV_sZkQ@mail.gmail.com>
References: <CAEdvWkQTe1rZ=+ARtOm3HFr6rc8Qgvbf2MGqfX44k+erjHpFkg@mail.gmail.com>
	<20120913061152.GD16397@tango.0pointer.de>
	<CAEdvWkSnOwpCy-WS5PzStQ3k5jFFGFYc9HQyxEz2mt=sZLU8sg@mail.gmail.com>
	<20120913122320.GA31422@tango.0pointer.de>
	<CAPXgP125g3ix3NxvY7HNiOv__kwZM3mZd2_NBJjNS_rWV_sZkQ@mail.gmail.com>
Message-ID: <5052E709.4080206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/13/2012 02:28 PM, Kay Sievers wrote:
> On Thu, Sep 13, 2012 at 2:23 PM, Lennart Poettering
> <lennart@poettering.net> wrote:
>> On Thu, 13.09.12 15:47, Alexey Shabalin (a.shabalin at gmail.com) wrote:
>>
>>>> Please check with "udevadm info
>>>> /dev/disk/by-uuid/a8ce6981-1afd-4af6-8783-784b3c7a7d64" if the device is
>>>> properly initialized and the systemd tag appears in TAGS=. Only then
>>>> systemd will pick it up.
>>>>
>>> I see TAGS:
>>>
>>> P: /devices/virtual/block/dm-1
>>> N: dm-1
>>> E: DEVNAME=/dev/dm-1
>>> E: DEVPATH=/devices/virtual/block/dm-1
>>> E: DEVTYPE=disk
>>> E: DM_UDEV_DISABLE_DISK_RULES_FLAG=1
>>> E: DM_UDEV_DISABLE_OTHER_RULES_FLAG=1
>>> E: DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG=1
>>> E: MAJOR=253
>>> E: MINOR=1
>>> E: SUBSYSTEM=block
>>> E: SYSTEMD_READY=0
>>> E: TAGS=:systemd:
>>> E: USEC_INITIALIZED=41372
>>
>> TAGS is there but the symlink to
>> /dev/disk/by-uuid/a8ce6981-1afd-4af6-8783-784b3c7a7d64 is not known by
>> udev. This usually indicates that your lvm installation is broken and
>> doesn't properly integrate into udev (are you sure you enabled udev when
>> building lvm?).
>>
>> But please bring this up with the LVM as this is hardly a systemd
>> issue...
> 
> Existing symlinks, but missing symlink entries in the database often
> indicates an initrd assembly, where the udev database did not survive
> the transition to the real rootfs.
> 

That is in 99% exactly the case (looking at the "DISABLE" flags set).

Also, there's no "E:DM_UDEV_PRIMARY_SOURCE_FLAG=1" record that would inform
us that this device has been properly initialized by LVM tools (this flag
is used to avoid premature symlink creation on the *first* ADD event as
device-mapper devices are usable only after the CHANGE event after the
table specification is properly loaded for the device-mapper mapping
that represents an LV). Missing DM_UDEV_PRIMARY_SOURCE_FLAG also points
to the fact that udev records haven't been preserved from initrd.

So yes, as Kay says, this really seems to be the problem that the udev
database was not properly handed over from initrd (where the swap LV
is activated).

Which distro is this - Fedora? Which initrd - dracut?

(btw, swap on LVM is perfectly ok, I wouldn't say it's a bad idea at all
as commented in the first email - it's one of the use case where it's
really practical - you need more swap, so you just resize your LV based
on your needs...)

Peter


