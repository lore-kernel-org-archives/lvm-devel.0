From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Thu, 28 Jan 2021 23:56:52 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
Message-ID: <7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28. 01. 21 v 11:27 Martin Wilck napsal(a):
> On Thu, 2021-01-28 at 11:10 +0100, Zdenek Kabelac wrote:
>> Dne 27. 01. 21 v 18:28 mwilck at suse.com?napsal(a):
>>> From: Martin Wilck <mwilck@suse.com>
>>>
>>> LVM2 has several configuration options related to device detection
>>> and udev. In particular, we have obtain_device_list_from_udev=(0|1)
>>> and external_device_info_source=("none"|"udev"). The two options
>>> are
>>> obviously semantically related, but it's rather unclear if and how
>>> they interact.
>>>
>>> If udev is unavailable, e.g. in containers,
>>> obtain_device_list_from_udev
>>> (which defaults to 1) will be automatically reset to 0. However,
>>> if external_device_info_source="udev" is set, this setting is not
>>> reset to "none", leading to error messages like
>>>
>>>  ?? Udev database has incomplete information about device /dev/vda.
>>>  ?? /dev/vda: Failed to get external handle [udev].
>>>
>>> This patch changes that, treating external_device_info_source the
>>> same way as obtain_device_list_from_udev, thereby making LVM2's
>>> device detection more consistent.
>>>
>>> The default for external_device_info_source is "none", but I
>>> believe
>>> there are very good reasons to change this setting to "udev",
>>> because
>>> LVM will get detection of multipath and md devices wrong most of
>>> the
>>> time otherwise. LVM should follow the same logic as systemd and
>>> other
>>
>>
>> Hi
>>
>> I'm afraid there is no such simple fix for this as you might think.
>>
>> 
> But does that mean my patch is wrong? Don't you agree that the
> different handling of obtain_device_list_from_udev and
> external_device_info_source in the current code is inconsistent?
>

Hi

One of the main point probably is  -

if udev is not working on your main system - and should - you should
get it working first.

Side case can be - you run lvm2 command - and someone 'restarts' udev
(i.e. via upgrade...)

So in general - this fallback should be only like new configurable
option - since normally you do not want lvm2 to ever touch /dev
dir which is under udev control.

Adding your 'fallback' adds some level of randomness and diggers
possibly bigger hole of troubles in system.

> The background of this patch is not that I want to enable use of LVM in
> containers. It is that we (openSUSE/SUSE) have recently made

Yep - everyone thinks running lvm2 in Container is 'smart' :)

> Still, I think the patch is not a hack, but generally correct, and has
> the pleasant side effect to fix our issue.

It would need some 'new' mode - but IMHO that's then equivalent
to setting correct mode directly.

What can likely work better is to add some 'detection' of being executed
in container -  scream at user and do maybe that 'udev' hack fallback ;)

Regards

Zdenek


