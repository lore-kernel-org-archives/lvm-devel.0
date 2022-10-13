From: Pawan Sharma <sharmapawan@microsoft.com>
Date: Thu, 13 Oct 2022 06:53:40 +0000
Subject: LVM2 : performance drop even after deleting the snapshot
In-Reply-To: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
References: <PUZP153MB075126926388815B6F9E1258AC229@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
Message-ID: <PUZP153MB07512B1B646868F0F8F1D205AC259@PUZP153MB0751.APCP153.PROD.OUTLOOK.COM>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

adding this to lvm-devel mailing list also.

Regards,
Pawan
________________________________
From: Pawan Sharma
Sent: Wednesday, October 12, 2022 10:42 PM
To: linux-lvm@redhat.com <linux-lvm@redhat.com>
Cc: Mitta Sai Chaithanya <mittas@microsoft.com>; Kapil Upadhayay <kupadhayay@microsoft.com>
Subject: LVM2 : performance drop even after deleting the snapshot

Hi Everyone,


We are evaluating lvm2 snapshots and doing performance testing on it. This is what we are doing :

  1.  dump some data to lvm2 volume (using fio)
  2.  take the snapshot
  3.  delete the snapshot (no IOs anywhere after creating the snapshot)
  4.  run the fio on lvm2 volume

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
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221013/3a0c62f5/attachment.htm>
