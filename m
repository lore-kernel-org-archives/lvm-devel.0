From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Jun 2021 11:53:56 +0200
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
	<ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
	<897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
Message-ID: <8b85c1b6-5a8e-02c4-7625-4778e3d9b0b9@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10. 06. 21 v 11:19 Wu Guanghao napsal(a):
> Hi,
>
> If the execution of lvmcache_label_scan() fails, the scan can be performed again, then there is no problem;
> But the execution of lvmcache_label_scan() fails, which will cause the vgid to be unable to obtain normally,
> then the re-reading will not be triggered in vg_read(), causing the execution of this command to fail .
>
>
> 2.03.12 Error log:
> 143682:Jun 10 16:40:38 lvm[708341]: /dev/ram0: Checksum error at offset 203776
> 143683:Jun 10 16:40:38 lvm[708341]: WARNING: invalid metadata text from /dev/ram0 at 203776.
> 143684:Jun 10 16:40:38 lvm[708341]: WARNING: metadata on /dev/ram0 at 203776 has invalid summary for VG.
> 143685:Jun 10 16:40:38 lvm[708341]: WARNING: bad metadata text on /dev/ram0 in mda1
> 143686:Jun 10 16:40:38 lvm[708341]: WARNING: scanning /dev/ram0 mda1 failed to read metadata summary.
> 143687:Jun 10 16:40:38 lvm[708341]: WARNING: repair VG metadata on /dev/ram0 with vgck --updatemetadata.
> 143688:Jun 10 16:40:38 lvm[708341]: WARNING: scan failed to get metadata summary from /dev/ram0 PVID elQQtAsePg5vfZA2DuMV4exqYhvvRdrq
> 143689:Jun 10 16:40:38 lvm[708341]: /dev/ram1: Checksum error at offset 508416
> 143690:Jun 10 16:40:38 lvm[708341]: WARNING: invalid metadata text from /dev/ram1 at 508416.
> 143691:Jun 10 16:40:38 lvm[708341]: WARNING: metadata on /dev/ram1 at 508416 has invalid summary for VG.
> 143692:Jun 10 16:40:38 lvm[708341]: WARNING: bad metadata text on /dev/ram1 in mda1
> 143693:Jun 10 16:40:38 lvm[708341]: WARNING: scanning /dev/ram1 mda1 failed to read metadata summary.
> 143694:Jun 10 16:40:38 lvm[708341]: WARNING: repair VG metadata on /dev/ram1 with vgck --updatemetadata.
> 143695:Jun 10 16:40:38 lvm[708341]: WARNING: scan failed to get metadata summary from /dev/ram1 PVID mLoVSnWPN1IqsHh3eXMh5QCmWyHsBwDi
> 143901:Jun 10 16:41:15 lvm[708341]: Volume group "brd_vg" not found
> 143902:Jun 10 16:41:15 lvm[708341]: Cannot process volume group brd_vg


Hi


Yep this case looks like bug - could you please open? bugzilla for this case 
and don't forget to attache full -vvvv log plus possible reproducer how you 
reach it.

It seems the invalid device during? unlocked scan is not handled correctly and 
needs some examination.

Regards

Zdenek



