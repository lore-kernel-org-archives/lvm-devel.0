From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Tue, 18 Oct 2022 13:15:38 +0200
Subject: [EXTERNAL] Re: LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <PUZP153MB0751F596ABAFA828502BA50FAC289@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <91261aec-d0fd-7884-1f38-a575b4e540e2@gmail.com>
 <SI2P153MB0444EE48C7C6E92FB448262ED7249@SI2P153MB0444.APCP153.PROD.OUTLOOK.COM>
 <0e032336-8658-5686-3dfb-0e50cdcb7d91@gmail.com>
 <PUZP153MB0751F596ABAFA828502BA50FAC289@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
Message-ID: <2bb9c754-3e8e-5c6a-c4fb-c4212d8de44f@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18. 10. 22 v 5:33 Pawan Sharma napsal(a):
> Hi Zdenek,
> 
> I would like to highlight one point here is that we are creating and then 
> deleting the snapshot immediately without writing anything anywhere. In this 
> case, we are expecting the performance to go back to what it was before taking 
> the thin snapshot. Here we are not getting the original performance after 
> deleting the snapshot. Do you know any reason why that would be happening.

As explained in my previous post - with thin-provisioning - you are getting 
metadata updates for bTrees - thus there is no 'revert' to previous 'metadata 
state' - there is rolling update of bTrees which is by design 'seek 
unfriendly' - so for the performance hunting users the use of SSD/NVMe type 
storage for these metadata volumes is basically a must (and it's been designed 
for that).

The old 'thick' snapshot where you allocate explicit COW LV storage is going 
to give here your expected behavior - however you will (of course) loose all 
the benefits you get with thin-pools.

With thin-pool (as also mentioned in my previous post) - if you can't afford 
dedicated low-latency storage - you need to scale-up chunk size - so the 
amount of metadata updates is reduced together (lowering seeking). I'm afraid 
you can't expect much more in the near future.

FYI there is to be merged in the upcoming kernel this patch set:

https://listman.redhat.com/archives/dm-devel/2022-October/052367.html

which should also help a lot with multithreaded load on thin-pools

There is also some new metadata format being experimented with - but whether 
this will also tackle anything in the seek friendlier logic is hard to tell...

Regards

Zdenek

