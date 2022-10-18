From: Pawan Sharma <sharmapawan@microsoft.com>
Date: Tue, 18 Oct 2022 03:33:07 +0000
Subject: [EXTERNAL] Re: LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <0e032336-8658-5686-3dfb-0e50cdcb7d91@gmail.com>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <91261aec-d0fd-7884-1f38-a575b4e540e2@gmail.com>
 <SI2P153MB0444EE48C7C6E92FB448262ED7249@SI2P153MB0444.APCP153.PROD.OUTLOOK.COM>
 <0e032336-8658-5686-3dfb-0e50cdcb7d91@gmail.com>
Message-ID: <PUZP153MB0751F596ABAFA828502BA50FAC289@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

I would like to highlight one point here is that we are creating and then deleting the snapshot immediately without writing anything anywhere. In this case, we are expecting the performance to go back to what it was before taking the thin snapshot. Here we are not getting the original performance after deleting the snapshot. Do you know any reason why that would be happening.

Regards,
Pawan
________________________________
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Sent: Monday, October 17, 2022 6:40 PM
To: Mitta Sai Chaithanya <mittas@microsoft.com>; LVM2 development <lvm-devel@redhat.com>; Pawan Sharma <sharmapawan@microsoft.com>; linux-lvm at redhat.com <linux-lvm@redhat.com>
Cc: Kapil Upadhayay <kupadhayay@microsoft.com>
Subject: Re: [EXTERNAL] Re: LVM2 : performance drop even after deleting the snapshot

[Some people who received this message don't often get email from zdenek.kabelac at gmail.com. Learn why this is important at https://aka.ms/LearnAboutSenderIdentification ]

Dne 14. 10. 22 v 21:31 Mitta Sai Chaithanya napsal(a):
> Hi Zdenek Kabelac,
>            Thanks for your quick reply and suggestions.
>
> We conducted couple of tests on Ubuntu 22.04 and observed similar performance
> behavior post thin snapshot deletion without writing any data anywhere.
>
> *Commands used to create Thin LVM volume*:
> - lvcreate  -L 480G --poolmetadataspare n --poolmetadatasize 16G
> --chunksize=64K --thinpool  ThinDataLV ThinVolGrp
> - lvcreate -n ext4.ThinLV -V 100G --thinpool ThinDataLV ThinVolGrp


Hi

So now it's clear you are talking about thin snapshots - this is a very
different story going on here (as we normally use term "COW" volumes for thick
old snapshots)

I'll consult more with thinp author - however it does look to me you are using
same device to store  data & metadata.

This is always a highly sub-optimal solution - the metadata device is likely
best to be stored on fast (low latency) devices.

So my wild guess - you are possibly using rotational device backend to store
your  thin-pools metadata volume and then your setups gets very sensitive on
the metadata fragmentation.

Thin-pool was designed to be used with SSD/NVMe for metadata which is way less
sensitive on seeking.

So when you 'create' snapshot - metadata gets updated - when you remove thin
snapshot - metadata gets again a lots of changes (especially when your origin
volume is already populated) - and fragmentation is inevitable and you are
getting high penalty of holding metadata device on the same drive as your data
device.

So while there are some plans to improve some metadata logistic - I'd not
expect miracles on you particular setup - I'd highly recommend to plug-in some
  SSD/NVMe storage for storing your thinpool metadata - this is the way to go
to get better 'benchmarking' numbers here.

For an improvement on your setup - try to seek larger chunk size values where
your data 'sharing' is still reasonably valuable - this depends on data-type
usage - but chunk size 256K might be possibly a good compromise (with disabled
zeroing - if you hunt for the best performance).


Regards

Zdenek

PS: later mails suggest you are using some 'MS Azure' devices?? - so please
redo your testing with your local hardware/storage - where you have precise
guarantees of storage drive performance - testing in the Cloud is random by
design....

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221018/c9f6da66/attachment.htm>
