From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Jan 2021 12:11:12 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
Message-ID: <fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29. 01. 21 v 11:07 Martin Wilck napsal(a):
> Hello Zdenek,
> 
> On Thu, 2021-01-28 at 23:56 +0100, Zdenek Kabelac wrote:
>> Dne 28. 01. 21 v 11:27 Martin Wilck napsal(a):
>>> On Thu, 2021-01-28 at 11:10 +0100, Zdenek Kabelac wrote:
>>>> Dne 27. 01. 21 v 18:28 mwilck at suse.com?napsal(a):
>>>>> From: Martin Wilck <mwilck@suse.com>

> 
> Of course *udev* works "in my main system". But *LVM2* does not: with
> the default setting "external_device_info_source=none", it ignores udev
> properties of devices. This is the source of lots of subtle errors and
> race conditions during device setup. Therefore we changed the setting
> to "udev".

The reason why "udev" is not default is simply because ATM it's unreliable 
source of info. It works well only for couple device types - but for lot of 
others it is not actual (i.e. network storage) (there are even no events 
generated for updating udev)

So it's purely on admins choice to select the best working path.

Internal scan in lvm2 has been 'accelerated' with usage of asynchronous
reading so in most cases it should be giving good enough performance.

So for most user selecting 'right' filter rules gives the most 'stable' results.

If we would have thought for a minute that 'udev' is good generic
default - it would be already done....

> 
> How do you handle that in Fedora? I took the liberty to look at the
> Fedora 33 package, and it doesn't change default from "none" to
> "udev".?So by common sense, Fedora is going to suffer from the same
> general problem that (open)SUSE sees: With "none", lvm can detect

Generic advice is - configure proper filters.

There will be also a new 'filtering' introduced in a form a basic acceptance 
list of devices - that may be seen in some cases as more simple to use.

(i.e. once you make 'pvcreate' - device will listed in a file of accepted
devices and lvm2 - instead of writing manual filter rules - but it's
its own set of problems...) - so skilled admins may still prefer regex filters.

> multipath or MD components only "after the fact", i.e. after multipathd
> or mdadm have grabbed them already. If pvscan and multipathd start up
> simultaneously, it's anyones guess who "wins" (*). With "udev", that
> can't happen, and that's why "udev" should be made the default.

There are many other types where udev is not capable to keep proper updated
info and there is no maintainer for those device types.

Also there is major generic trouble about complete lack of any kind of
synchronization - so as said - the info in udev DB is unfortunately
very fragile.

But you are right that mpath knowledge is the one well maintained...

There is also project SID - that might hopefully improve this and
lvm2 might be able to use this as more reliable source of info about devices.

>> So in general - this fallback should be only like new configurable
>> option - since normally you do not want lvm2 to ever touch /dev
>> dir which is under udev control.

With some hidden fallback (as well as with timeouts) there is also the problem
with 'randomness'.

So as said - if there would be a new mode with a fallback rule in its 
description - it'd be fine.

but from users POV - we can't randomly change the 'game' without giving
users chance to keep their 'old' logic which could have been more correct for 
them.

> But that would also mean that you would have to change the default to
> "udev", and *remove* both options "external_device_info_source" and
> "obtain_device_list_from_udev". The former should be hard coded to
> "udev" and the latter to 1, end of story. If you don't remove these
> options, how would the new option interact with the existing two? Which
> would take precedence?

Each - has different meaning:

obtain_device_list_from_udev:  should give us devices for scanning - this
is pretty much ok - but not much different for list of /sys/block anyway.

external_device_info_source:   delegate 'trust' to udev knowledge about device 
- which is unfortunately in many cases wrong so we cannot switch to this as 
default - as there would be too many error reports
(even our own 'pvscan' service is currently executed as asynchronous
task - so even info about lvm2 devices in udevdb can be invalid...)


> Explain that, please. The fallback does nothing in the current default
> case (external_device_info_source="none"). And in the "udev" case, it
> avoids an error condition in special situations, simply by falling back
> to the current default. What's wrong about that?

It seems to base here everything on the better udev info for offline mpath,
but there are far more case where udev is simply wrong.

If your only problem is mpath leg detection - one solution could be - to 
improve lvm2 internal mpath leg detection - there is even some initial patch 
set in some Dave's branch - which would need just some polishing to become 
probably more usable then 'udev info source'.

> Again, this is not only about containers, but any environment where
> the udev data base is not available.

For systems without 'working/usable' udev - users should reconfigure
lvm2 to not work with udev.

But there need to be seen a big difference between systems, where
udev i.e. temporarily crashed - so it may look-like a system
without udevd - and real non-udev based distro.

ATM lvm2 has no knowledge how to recognizes those 2 for all cases...

> If you can provide a better solution than my patch, we'll happily
> take it. But we need *something* to fix the current breakage.

1st. we should define what kind of problem you try to solve
and eventually open BZ (since list is not best for tracking progress).

Is is detection of 'mpath leg' while mpath is offline
and user is not able to set his filters properly ?

Zdenek


--
And I'll just repeat myself - users are NOT supposed to be using lvm2 in their 
containers and if they do so - it's generically unsupportable from lvm2 with 
current infrastructure.


