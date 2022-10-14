From: Mitta Sai Chaithanya <mittas@microsoft.com>
Date: Fri, 14 Oct 2022 19:31:04 +0000
Subject: [EXTERNAL] Re: LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <91261aec-d0fd-7884-1f38-a575b4e540e2@gmail.com>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <91261aec-d0fd-7884-1f38-a575b4e540e2@gmail.com>
Message-ID: <SI2P153MB0444EE48C7C6E92FB448262ED7249@SI2P153MB0444.APCP153.PROD.OUTLOOK.COM>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek Kabelac,
          Thanks for your quick reply and suggestions.

We conducted couple of tests on Ubuntu 22.04 and observed similar performance behavior post thin snapshot deletion without writing any data anywhere.

Commands used to create Thin LVM volume:
- lvcreate  -L 480G --poolmetadataspare n --poolmetadatasize 16G --chunksize=64K --thinpool  ThinDataLV ThinVolGrp
- lvcreate -n ext4.ThinLV -V 100G --thinpool ThinDataLV ThinVolGrp

ThinLV display:
 --- Logical volume ---
  LV Path                /dev/ThinVolGrp/ext4.ThinLV
  LV Name                ext4.ThinLV
  VG Name                ThinVolGrp
  LV UUID                sRcj9L-Ili4-dR3I-MeJI-3KLv-xPUP-VMd1LC
  LV Write Access        read/write
  LV Creation host, time kapil-upstream, 2022-10-14 18:05:22 +0000
  LV Pool name           ThinDataLV
  LV Status              available
  # open                 1
  LV Size                100.00 GiB
  Mapped size            21.51%
  Current LE             25600
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:4

dmsetup table output after creation of thin lvm volume:
ThinVolGrp-ThinDataLV: 0 1006632960 linear 253:2 0
ThinVolGrp-ThinDataLV-tpool: 0 1006632960 thin-pool 253:0 253:1 128 0 0
ThinVolGrp-ThinDataLV_tdata: 0 1006632960 linear 8:32 2048
ThinVolGrp-ThinDataLV_tmeta: 0 33161216 linear 8:32 1006635008
ThinVolGrp-ext4.ThinLV: 0 209715200 thin 253:2 1

dmsetup status after creation of thin lvm volume:
     ThinVolGrp-ThinDataLV: 0 1006632960 linear
ThinVolGrp-ThinDataLV-tpool: 0 1006632960 thin-pool 1 4878/4145152 8325/7864320 - rw discard_passdown queue_if_no_space - 1024
ThinVolGrp-ThinDataLV_tdata: 0 1006632960 linear
ThinVolGrp-ThinDataLV_tmeta: 0 33161216 linear
ThinVolGrp-ext4.ThinLV: 0 209715200 thin 1065600 209715199

FIO Command to dump some data:
fio --filename=/dev/ThinVolGrp/ext4.ThinLV --name=<name> --time_based --group_reporting --ioengine=libaio --direct=1 --size=20G  --runtime=120 --rw=randrw --rwmixread=50 --bs=16K --iodepth=8 --numjobs=3 --randrepeat=0  --randseed=$(date +%s)

For detailed information of fio and dmsetup results click here<https://gist.github.com/mittachaitu/17006a1e3f08ad0c17add7ea007e63b6#file-lvm_snapshot_performance>.
Note: All the tests are conducted using thin lvm volume and thin snapshot

Environment details:

        Kernel Version: 5.15.0-1021-azure

        LVM Version:    LVM version:     2.03.11(2) (2021-01-08)
                                 Library version: 1.02.175 (2021-01-08)
                                 Driver version:  4.45.0

        FIO Version:      3.28

Please let us know if you required more information and tests that needs to be run.

Thanks & Regards
mittachaitu (Sai)

From: Zdenek Kabelac<mailto:zdenek.kabelac@gmail.com>
Sent: Thursday, October 13, 2022 4:20 PM
To: LVM2 development<mailto:lvm-devel@redhat.com>; Pawan Sharma<mailto:sharmapawan@microsoft.com>; linux-lvm at redhat.com<mailto:linux-lvm@redhat.com>
Cc: Kapil Upadhayay<mailto:kupadhayay@microsoft.com>; Mitta Sai Chaithanya<mailto:mittas@microsoft.com>
Subject: [EXTERNAL] Re: LVM2 : performance drop even after deleting the snapshot

[Some people who received this message don't often get email from zdenek.kabelac at gmail.com. Learn why this is important at https://aka.ms/LearnAboutSenderIdentification ]

Dne 13. 10. 22 v 8:53 Pawan Sharma napsal(a):
> adding this to lvm-devel mailing list also.
>
> Regards,
> Pawan
> ------------------------------------------------------------------------------
> *From:* Pawan Sharma
> *Sent:* Wednesday, October 12, 2022 10:42 PM
> *To:* linux-lvm at redhat.com <linux-lvm@redhat.com>
> *Cc:* Mitta Sai Chaithanya <mittas@microsoft.com>; Kapil Upadhayay
> <kupadhayay@microsoft.com>
> *Subject:* LVM2 : performance drop even after deleting the snapshot
> Hi Everyone,
>
>
> We are evaluating lvm2 snapshots and doing performance testing on it. This is
> what we are doing :
>
>  1. dump some data to lvm2 volume (using fio)
>  2. take the snapshot
>  3. delete the snapshot (no IOs anywhere after creating the snapshot)
>  4. run the fio on lvm2 volume
>
> Here as you can see, we are just creating the snapshot and immediately
> deleting it. There are no IOs to the main volume or anywhere. When we run the
> fio after this (step 4) and we see around 50% drop in performance with
> reference to the number we get in step 1.
>
> It is expected to see a performance drop if there is a snapshot because of the
> COW. But here we deleted the snapshot, and it is not referring to any data
> also. We should not see any performance drop here.
>
> Could someone please help me understand this behavior. Why are we seeing the
> performance drop in this case? It seems like we deleted the snapshot but still
> it is not deleted, and we are paying the COW penalty.
>
> System Info:
>
> OS : ubuntu 18.04
> Kernel : 5.4.0
>
> # lvm version
> LVM version:2.02.176(2) (2017-11-03)
> Library version: 1.02.145 (2017-11-03)
> Driver version:4.41.0
>
> We also tried on latest ubuntu with newer version of LVM. We got the same
> behavior.
>
>

Hi

Debugging  5 year old software is likely not going to get lot of attention
from upstream.

So please:

a) reproduce the issue with some recent  kernel & lvm2
b) take   'dmsetup table && dmsetup status'  before you run every 'fio' test
and present here your result in some form - otherwise we can hardly see what
is the problem.


What should be expected - if you use old/thick snapshots - when you 'drop'
snapshot - you have your original intact LV - so results should mostly match
results before you take the snapshot - but you clearly have to take into
account if you use some 'SSD/NVMe' discarding and other things - so always run
series of tests and average your results.

If you use  thin snapshot - that you can get various results depending on your
settings of thin chunks, discard usage.

Also maybe try your benchmark with different filesystems...

Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221014/11cbf81b/attachment-0001.htm>
