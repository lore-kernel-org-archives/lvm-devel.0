From: Kapil Upadhayay <kupadhayay@microsoft.com>
Date: Mon, 17 Oct 2022 05:01:27 +0000
Subject: [linux-lvm] LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <2e6bad30-2ebf-4162-b62d-092c3ad14003@gmail.com>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
 <CAAMCDefYPozC32AdCqw-c1nOZNiEK0j0pG7n+zcu_bRwTfCagg@mail.gmail.com>
 <2e6bad30-2ebf-4162-b62d-092c3ad14003@gmail.com>
Message-ID: <HK0P153MB03244D79ED10AEAC52F60EF6C2299@HK0P153MB0324.APCP153.PROD.OUTLOOK.COM>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The thin volume was created on a block disk provided by Microsoft Azure Managed disk provisioned on premium SSD which is ready to be used in production environment. The disk can provide sustained Max IOPs at 5000.

Thanks,
Kapil Upadhayay.

From: Roberto Fastec <roberto.fastec@gmail.com>
Sent: Saturday, October 15, 2022 1:58 AM
To: LVM general discussion and development <linux-lvm@redhat.com>
Cc: Kapil Upadhayay <kupadhayay@microsoft.com>; Mitta Sai Chaithanya <mittas@microsoft.com>; lvm-devel at redhat.com
Subject: [EXTERNAL] Re: [linux-lvm] LVM2 : performance drop even after deleting the snapshot

Some people who received this message don't often get email from roberto.fastec at gmail.com<mailto:roberto.fastec@gmail.com>. Learn why this is important<https://aka.ms/LearnAboutSenderIdentification>
TIP and HINT
forget SSDs with LVM unless of enterprise level
especially if you are going to use/implement the thin provisioning
How to identify an SSD of enterprise level:
it costs from 1,00 euro per gigabyte up to 1,50 euro per gigabyte
Kind regards
Roberto Gini
Technical Manager @ www.RecuperoDatiRAIDFAsTec.it<https://nam06.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.recuperodatiraidfastec.it%2F&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=9i73rMTiPlvD6jlcxLti7Pvrku7jE%2BLciLP57umpwpA%3D&reserved=0>


Ottieni BlueMail per Android<https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fbluemail.me%2F&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=hGhews%2FSF8d7zCJvRzIOs24CE0xLHH1NqyWjL3IqthI%3D&reserved=0>
Il giorno 14 ott 2022, alle ore 21:50, Roger Heflin <rogerheflin at gmail.com<mailto:rogerheflin@gmail.com>> ha scritto:

What is the underlying disk hardware you are running this on?
virtual, spinning, ssd, nvme?

On Thu, Oct 13, 2022 at 2:01 AM Pawan Sharma <sharmapawan at microsoft.com<mailto:sharmapawan@microsoft.com>> wrote:

 adding this to lvm-devel mailing list also.

 Regards,
 Pawan

________________________________

 From: Pawan Sharma
 Sent: Wednesday, October 12, 2022 10:42 PM
 To: linux-lvm at redhat.com<mailto:linux-lvm@redhat.com> <linux-lvm at redhat.com<mailto:linux-lvm@redhat.com>>
 Cc: Mitta Sai Chaithanya <mittas at microsoft.com<mailto:mittas@microsoft.com>>; Kapil Upadhayay <kupadhayay at microsoft.com<mailto:kupadhayay@microsoft.com>>
 Subject: LVM2 : performance drop even after deleting the snapshot

 Hi Everyone,


 We are evaluating lvm2 snapshots and doing performance testing on it. This is what we are doing :

 dump some data to lvm2 volume (using fio)
 take the snapshot
 delete the snapshot (no IOs anywhere after creating the snapshot)
 run the fio on lvm2 volume

 Here as you can see, we are just creating the snapshot and immediately deleting it. There are no IOs to the main volume or anywhere. When we run the fio after this (step 4) and we see around 50% drop in performance with reference to the number we get in step 1.

 It is expected to see a performance drop if there is a snapshot because of the COW. But here we deleted the snapshot, and it is not referring to any data also. We should not see any performance drop here.

 Could someone please help me understand this behavior. Why are we seeing the performance drop in this case? It seems like we deleted the snapshot but still it is not deleted, and we are paying the COW penalty.

 System Info:

 OS : ubuntu 18.04
 Kernel : 5.4.0

 # lvm version
   LVM version:     2.02.176(2) (2017-11-03)
   Library version: 1.02.145 (2017-11-03)
   Driver version:  4.41.0

 We also tried on latest ubuntu with newer version of LVM. We got the same behavior.

 Any help/pointers would be appreciated. Thanks in advance.

 Regards,
 Pawan

________________________________

 linux-lvm mailing list
 linux-lvm at redhat.com<mailto:linux-lvm@redhat.com>
 https://listman.redhat.com/mailman/listinfo/linux-lvm<https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Flistman.redhat.com%2Fmailman%2Flistinfo%2Flinux-lvm&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=2HZwpc4MH0w7bCVwNuohJ7jG5naZaCNGdAJHwsIzsZg%3D&reserved=0>
 read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO<https://nam06.safelinks.protection.outlook.com/?url=http%3A%2F%2Ftldp.org%2FHOWTO%2FLVM-HOWTO&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=nMH03VV84Qe%2FkZ5g0hoBsZi53QKOYs%2B9CiTnPb6xu4s%3D&reserved=0>/



________________________________

linux-lvm mailing list
linux-lvm at redhat.com<mailto:linux-lvm@redhat.com>
https://listman.redhat.com/mailman/listinfo/linux-lvm<https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Flistman.redhat.com%2Fmailman%2Flistinfo%2Flinux-lvm&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=2HZwpc4MH0w7bCVwNuohJ7jG5naZaCNGdAJHwsIzsZg%3D&reserved=0>
read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO<https://nam06.safelinks.protection.outlook.com/?url=http%3A%2F%2Ftldp.org%2FHOWTO%2FLVM-HOWTO&data=05%7C01%7Ckupadhayay%40microsoft.com%7Ccd9e45aadb0c4dd0a03508daae22aa91%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C638013761207553033%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=nMH03VV84Qe%2FkZ5g0hoBsZi53QKOYs%2B9CiTnPb6xu4s%3D&reserved=0>/
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221017/87b29702/attachment-0001.htm>
