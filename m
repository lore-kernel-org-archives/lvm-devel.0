From: Eric Ren <zren@suse.com>
Date: Thu, 1 Jun 2017 09:54:16 +0800
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
In-Reply-To: <2be87d73-a516-9daf-b645-89bf962741ec@redhat.com>
References: <20170524084519.12204-1-zren@suse.com>
	<dafc93b4-0f3b-57a5-9055-4c9409d8fcf0@redhat.com>
	<f531f11d-a36c-4c51-6713-bec5d55a7c9c@suse.com>
	<14fb2bba-34b0-716e-7995-8f52626671a3@suse.com>
	<1bf46b88-9b26-4437-446c-25e879b3ac3a@redhat.com>
	<ce16334a-1d86-1f5a-65d5-867f8ee6f1ff@suse.com>
	<2be87d73-a516-9daf-b645-89bf962741ec@redhat.com>
Message-ID: <6bd491f9-8aab-8e2c-cd82-a0b2002bdc07@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

On 05/31/2017 08:15 PM, Zdenek Kabelac wrote:
> [...snip...]
>> Thanks for your information:-P
>>
>> Unfortunately, I still failed to tell the problem clearly. Since this problem can be 
>> reproduced easily, I debugged it step by step using
>> gdb, and read most of code paths relative to this problem. It's indeed a problem that 
>> "device cache" in clvmd is not updated as needed.
>
> And as was already mentioned - this is a documented and the only supported logic in clvmd.
>
> If user  runs  WITHOUT  obtain_device_list_from_udev == 1 (i.e. command does scan and 
> manually discover device and maintains .cache file)  it's admin responsibility to refresh 
> device cache when ANY new device appears.
>
> It's seen counterproductive to NOT use udev and yet want udev to update .cache.
>
> So the only issue we care here is - user has   obtain == 1 and yet clvmd does NOT work 
> correctly  -  doing any code analysis is premature here...

This problem can be reproduced no matter 'obtain_device_list_from_udev == 1' or 'obtain_xx 
== 0'.

The reason why I mention 'obtain...' here is,  several days ago on IRC,  when I tried 
'obtain... == 0' following your
instructions, the problem *disappeared*,  so I thought, yes, udev has something wrong! But, 
as mentioned previously,
I was cheated because do_refresh_cache() will be called if lvm.conf is *changed*.

>
>> 4. What is the problem?
>> clvmd missed a chance to update its device cache when a MD device is assembled, because 
>> 'pvscan' triggered by udev rules exits
>> too early to call lock_vol(..., VG_GLOBAL, ...).
>
> pvscan in UDEV rules is ONLY for  'lvmetad'  nothing else and certainly not for clvmd.

Yeah, this is the problem. So, do_refresh_cache() won't be called when underlying device 
changes.

>
>> Hope I make this issue understood this time. But, I have to admit that this fix in pvscan 
>> tool looks nasty:-/
>>
>
>
> So if you still see reproducible problem feel free to regular community bugzilla at:
>
> https://bugzilla.redhat.com/enter_bug.cgi?product=LVM%20and%20device-mapper

Thanks, will do.

Regards,
Eric

>
>
> Regards
>
> Zdenek
>
> -- 
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


