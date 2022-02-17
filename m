From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 17 Feb 2022 11:23:22 +0100
Subject: Reg auto metadata drive growth
In-Reply-To: <CAFe+wq32gErNeFgy0YAm3DQ-0dcTbYDtKGfv=pY5VXwU-Yi_nA@mail.gmail.com>
References: <CAFe+wq32gErNeFgy0YAm3DQ-0dcTbYDtKGfv=pY5VXwU-Yi_nA@mail.gmail.com>
Message-ID: <fd3598a4-57aa-39f0-0354-e9187b75484f@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16. 02. 22 v 17:52 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team!
> A very good?day to you.
>
> I am currently using a dm thin pool/volume in my setup.
> I initially created a metadata device that is about 2G with a chunk size 64K.
>
> I refer to the link below for some follow up queries.
> https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/assembly_thinly-provisioned-logical-volumes_configuring-and-managing-logical-volumes
>
> <snip begin>
>
> By default, |lvm2|?starts with a 64KiB chunk size and increases its value 
> when the resulting size of the thin pool metadata device grows above 128MiB, 
> this keeps <snip end>
>

This is some form of 'selecting' reasonable 'default' - but it needs to be 
seen this precalculated? default will not likely fit everyone's use.

I'd say we target something that will not give a user 'terrible' results - but 
user should always learn himself about the thin-provisioning technology ahead 
of actual usage. Once the user gets familiar with configurable knobs he can 
for 100% pick better settings for his planed workflow/hw...


> a) I read that for each TiB of supported thin volume, ~15.8GiB of metadata 
> volume gets used. I believe this condition is computed based on the default 
> chunk size at 64K. So if the chunk size doubles, then I would assume that 
> only ~8GiB for each TiB.
>
> b) What is the max supported thin volume size?

You can easily create EiB thin volumes - but sooner or later you will face a 
problem of having backend support for this size.

It's always about what you can address by metadata size.? Lvm prints 
addressable size for any set of your passed args - so i.e. in you example - 
that's the amount? thin volume can physically map in your thin-pool. However 
virtual size of thin volume could be much bigger - but once you run past the 
supported physical mapping size - you will get errors on block provisioning time.

The slight complexity comes with combination of? VG extent size -? since all 
LV sizes are expressed (ATM) in #extent_size - so default extent_size? (4MiB)? 
limits max LV size to 16PiB. And while extent size has no other impact on 
virtual thin volume size, this could be seen as slight limiting factor? - so 
if you do want to play? in Exa world,? just create your VG with? 4GiB extent 
size, but it will limit granularity of your LV sizes (min LV size is 4G, next 
8G.....)

> c) What is the max supported metadata volume size?
>
~15.8GiB - that's real physical limitation size lvm2 informs you in that message.

> Also, under some scenarios over a period?of time I observe that the thin 
> metadata volume gets full. Under those condition:
>
> 1/ Is it possible to manually resize?the metadata volume alone?

Yes, although after many? user failure cases - we decided to tight the resize 
of thin-pool data volume to also enforce metadata resize.? You could opt-out 
from this - but you then need to be a good expert on whole usage.

> 2/ Is it possible to automatically resize the metadata volume as it reaches 
> a critical limit?

Of course - you can? set lvm.conf 'thin_pool_autoextend_threshold' bellow 
100%? - and use monitoring via dmeventd to automatically extend data & 
metadata size.

But note - once the size gets biggers - we do not support thin-pool reduction 
- so even if you remove/discard your thin volumes later - it will not shrink 
thin-pool data nor metadata later. And clearly if there is no free space in 
your VG, resize will no longer work....

> Can I please have some clarification on the above?

'man lvmthin' ? should be the good resource for most of your questions.


Regards

Zdenek
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220217/ab435258/attachment.htm>
