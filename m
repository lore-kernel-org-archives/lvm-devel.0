From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Jan 2021 17:38:04 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
	<968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
Message-ID: <1a60a927-7601-2acf-ac32-44c55a19ebd6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29. 01. 21 v 14:02 Martin Wilck napsal(a):
> On Fri, 2021-01-29 at 12:11 +0100, Zdenek Kabelac wrote:
>>
>> The reason why "udev" is not default is simply because ATM it's
>> unreliable
>> source of info. It works well only for couple device types - but for
>> lot of
>> others it is not actual (i.e. network storage) (there are even no
>> events
>> generated for updating udev)
> 
> What kind of network storage?
> 
>> If we would have thought for a minute that 'udev' is good generic
>> default - it would be already done....
> 
> The udev source (DEV_EXT_UDEV) is only used in 5 places, all in the
> filtering code path:
> 
>   a) dev_is_md_component()
>   b) _dev_is_mpath()
>   c) dev_is_partitioned()
>   d) _dev_is_fwraid()
>   e) check_pv_min_size()
> 
> I think we agree that "udev" is more reliable than "none" in case a)
> and b). For which of the above is "udev" unreliable, why, and why can't
> it be fixed?

Unfortunately I can't agree.

Udev ONLY works well on systems without any problems. As soon as your
devices start to be temporarily missing or you have 'duplicate' device,
the whole udevDB becomes invalid.

While with lvm2 you can filter out particular device set - with udev the
system cannot be trusted at all.

> 
>>> How do you handle that in Fedora?
>> Generic advice is - configure proper filters.
> 
> IMHO filters aren't the solution. LVM offers

With good and IMHO not so hard to configure allowance filters,
user easily solve any problems - as lvm2 will ONLY see
valid PVs and all other devices will be ignored.

IMHO every user should set 'minimal' set of visible devices to speedup all 
lvm2 commands and avoid unnecessary access to all other devices.

> "multipath_component_detection", which suggests that
> no additional filtering is necessary. Unfortunately
> "multipath_component_detection" is broken without
> 'external_device_info_source="udev"'.

It is not broken, it just only works with 'active' mpath devices.
User typically doesn't want to run lvm2 command while mpath is
not running, so problem usually happens on misconfigured system.
With running mpath - detection works.
Also note - lvm2 will usually report errors when it spots multiple legs with 
duplicate info.

So external info is only needed for systems which have mpath stopped/
disable and yet the user wants/tries to manipulate with VG  - I'd not
say this as a most common use-case.

> LVM filters are hard to get right, even for experienced admins. Not
> because of the regexes, but because of the many different names under
> which devices appear under /dev. Telling admins that they need to

Hint - only real device nodes should be used - anything based on udev created 
symlinks is by its design broken anyway (due to missing 'duplication' handling 
- aka last arrival with the pathname wins all).

> fiddle with filter rules just to make multipath work sounds like
> something I'd have said 10 years ago, but not in 2021.

Not really a fault of lvm2 here - we would like to use some
reliable source of info - but udev in our testings can't deliver
correct info even on loaded system.
There is not even existing mechanism to synchronize with udev.
So there would need to be ton of sleeps and retries everywhere...

>> 1st. we should define what kind of problem you try to solve
>> and eventually open BZ (since list is not best for tracking
>> progress).
>>
>> Is is detection of 'mpath leg' while mpath is offline
>> and user is not able to set his filters properly ?
> 
> See above. Our aspiration is to make multipath+md+LVM setups work out-
> of-the-box, reliably.

I hope you do not think we have different goals - but the acceptable
solution must be reliable - not something that works only on
shiny day with few disks and as soon as something becomes invalid, the 
returned info can be very misleading.
We just hope SID can finally move this udev to a more usable state.

But please open BZ and list cases you think are broken - and we will
see what's the best way to handle them.

But from our experience and testing - enabling udev source give us so many 
problems, we simply could not keep it as default.

Regards

Zdenek


