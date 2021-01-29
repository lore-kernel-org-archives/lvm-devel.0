From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Jan 2021 21:36:46 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <e42a9f07af2059c60dc26254ddb2d3f5c0a1ca07.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
	<968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
	<1a60a927-7601-2acf-ac32-44c55a19ebd6@redhat.com>
	<e42a9f07af2059c60dc26254ddb2d3f5c0a1ca07.camel@suse.com>
Message-ID: <ca3a6d20-5bab-5649-f6f6-9ec59dc6982c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29. 01. 21 v 18:58 Martin Wilck napsal(a):

> This is where I disagree. The error scenarios we observed go roughly as
> follows:
> 
>   - SCSI devices are being probed
>   - some SCSI disk is discovered, "add" "block" uevent follows
>   - multipath is run in udev rules, decides it's an mpath leg
>     -> SYSTEMD_READY=0
>   - multipathd sets up a map with the new path
>   - "change block" uevent for the map
>   - the map is now ready for upper layers to process.
>     lvm2-pvscan at .service will be run on it
>   - meanwhile, other SCSI devices have beeen detected but not fully
> processed yet
>   - depending on timing, the pvscan instance running for the the map
>     just created can grab these SCSI devices before multipathd can
>     set them up. This happens because LVM doesn't honor the
>     SYSTEMD_READY property.

Please open BZ with your findings.

We already know that 'pvscan' as parallel service is not a good thing -
but it's not completely trivial to place it back into udev rule.
So far there was no big priority put into this - but I think it's
causing some harm to scan as service -  we should need only
activation as service.


> I suppose you'd reply that such a system was misconfigured because
> the user should have added appropriate lvm filter rules. I agree,
> if that's done, the issue can't happen. But
> "multipath_component_detection" alone doesn't prevent it. That's what I
> wanted to say.
> 
>> So external info is only needed for systems which have mpath
>> stopped/
>> disable and yet the user wants/tries to manipulate with VG? - I'd not
>> say this as a most common use-case.
> 
> If this was our experience, I'd never had considered using
> external_device_info_source="udev" :-)
> 

One of the main problems is 'synchronization' with udev - which is simply not 
there.

So if you run commands by hand in shell - it usually does not matter - there 
is usually big enough latency.
But if commands are executed through scripts - there is big randomness
how the 'script' will work.  Devices are there. Preceding command have created 
them - but udev doesn't know about them yet, or devices are already something 
different.

If there would be a way how we can know the udev has finished
all the work with all 'already' discovered device - but since many tasks are 
now handle with asynchronous services - it's even more complicated.

> Funny you say that :-) I proposed this patch precisely because in our
> experience it *improves* reliability. So, we have the same goals, just
> different experimental evidence.

It needs to first start by check there is exactly one
udev check call for detection of disabled udev.

> I don't know enough about SID to judge. But I think the problem is
> generic. Only the kernel knows which devices are present at any given
> point in time. Any user space tool can only try to be as close as
> possible. SID, being more focused in scope than udev, can probably do a
> better job at that, but it will still lag behind, always.

We hope SID would not be confused with disks with duplicated signatures
and other weirdness common in running systems.

>> But please open BZ and list cases you think are broken - and we will
>> see what's the best way to handle them.
> 
> Hm, opening Red Hat BZs for issues that occur in SUSE Linux Enterprise
> tends to be tricky. We won't usually be able to reproduce our partner

We do have 'lvm2 community bugzilla' for lvm2 bugs. So really everyone can
open them - we just need to get logs attached for analysis and preferably
some test case.

Our experience is, that often bugs have usually quite different roots....
So we would like to first get analysis of root cause of the issue
instead of just hiding bug but some 'hidden' auto switch.

Zdenek


