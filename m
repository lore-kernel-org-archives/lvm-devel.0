From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Thu, 10 Jun 2021 17:19:17 +0800
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
	<ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
Message-ID: <897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

If the execution of lvmcache_label_scan() fails, the scan can be performed again, then there is no problem;
But the execution of lvmcache_label_scan() fails, which will cause the vgid to be unable to obtain normally,
then the re-reading will not be triggered in vg_read(), causing the execution of this command to fail .


2.03.12 Error log:
143682:Jun 10 16:40:38 lvm[708341]: /dev/ram0: Checksum error at offset 203776
143683:Jun 10 16:40:38 lvm[708341]: WARNING: invalid metadata text from /dev/ram0 at 203776.
143684:Jun 10 16:40:38 lvm[708341]: WARNING: metadata on /dev/ram0 at 203776 has invalid summary for VG.
143685:Jun 10 16:40:38 lvm[708341]: WARNING: bad metadata text on /dev/ram0 in mda1
143686:Jun 10 16:40:38 lvm[708341]: WARNING: scanning /dev/ram0 mda1 failed to read metadata summary.
143687:Jun 10 16:40:38 lvm[708341]: WARNING: repair VG metadata on /dev/ram0 with vgck --updatemetadata.
143688:Jun 10 16:40:38 lvm[708341]: WARNING: scan failed to get metadata summary from /dev/ram0 PVID elQQtAsePg5vfZA2DuMV4exqYhvvRdrq
143689:Jun 10 16:40:38 lvm[708341]: /dev/ram1: Checksum error at offset 508416
143690:Jun 10 16:40:38 lvm[708341]: WARNING: invalid metadata text from /dev/ram1 at 508416.
143691:Jun 10 16:40:38 lvm[708341]: WARNING: metadata on /dev/ram1 at 508416 has invalid summary for VG.
143692:Jun 10 16:40:38 lvm[708341]: WARNING: bad metadata text on /dev/ram1 in mda1
143693:Jun 10 16:40:38 lvm[708341]: WARNING: scanning /dev/ram1 mda1 failed to read metadata summary.
143694:Jun 10 16:40:38 lvm[708341]: WARNING: repair VG metadata on /dev/ram1 with vgck --updatemetadata.
143695:Jun 10 16:40:38 lvm[708341]: WARNING: scan failed to get metadata summary from /dev/ram1 PVID mLoVSnWPN1IqsHh3eXMh5QCmWyHsBwDi
143901:Jun 10 16:41:15 lvm[708341]: Volume group "brd_vg" not found
143902:Jun 10 16:41:15 lvm[708341]: Cannot process volume group brd_vg


2.03.09 Error log: (The version we use)
106626:Jun 10 15:09:02 localhost.localdomain lvm[639523]: ppid=593053, cmdline:lvremove -f brd_vg/lv47
106627:Jun 10 15:09:02 localhost.localdomain lvm[639523]: Call udev_device_get_devnode use 1417334 usec, device:/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/0000:02:03.0/virtio1/host0/target0:0:0/0:0:0:0/block/sda/sda3
107044:Jun 10 15:09:05 localhost.localdomain lvm[639523]: Call udev_device_get_devnode use 1388769 usec, device:/sys/devices/virtual/block/dm-202
107256:Jun 10 15:09:07 localhost.localdomain lvm[639523]: Call udev_device_get_devlinks_list_entry use 1472467 usec, dev:/sys/devices/virtual/block/dm-213
107879:Jun 10 15:09:11 localhost.localdomain lvm[639523]: Call udev_device_get_devlinks_list_entry use 1386394 usec, dev:/sys/devices/virtual/block/dm-389
109417:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: Metadata location on /dev/ram0 at 464384 begins with invalid VG name.
109418:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: bad metadata text on /dev/ram0 in mda1
109419:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: scanning /dev/ram0 mda1 failed to read metadata summary.
109420:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: repair VG metadata on /dev/ram0 with vgck --updatemetadata.
109421:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: scan failed to get metadata summary from /dev/ram0 PVID elQQtAsePg5vfZA2DuMV4exqYhvvRdrq
109423:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: Metadata location on /dev/ram1 at 959488 begins with invalid VG name.
109424:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: bad metadata text on /dev/ram1 in mda1
109425:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: scanning /dev/ram1 mda1 failed to read metadata summary.
109426:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: repair VG metadata on /dev/ram1 with vgck --updatemetadata.
109427:Jun 10 15:09:44 localhost.localdomain lvm[639523]: WARNING: scan failed to get metadata summary from /dev/ram1 PVID mLoVSnWPN1IqsHh3eXMh5QCmWyHsBwDi
111273:Jun 10 15:10:46 localhost.localdomain lvm[639523]: Reading VG brd_vg <no vgid>  	               (Output after adjusting the printing level)
111274:Jun 10 15:10:46 localhost.localdomain lvm[639523]: Rescanning devices for brd_vg rw             (Output after adjusting the printing level)
111275:Jun 10 15:10:46 localhost.localdomain lvm[639523]: Cache did not find VG vgid from name brd_vg  (Output after adjusting the printing level)
111276:Jun 10 15:10:46 localhost.localdomain lvm[639523]: Volume group "brd_vg" not found.
111277:Jun 10 15:10:46 localhost.localdomain lvm[639523]: Cannot process volume group brd_vg

Wu Guanghao

? 2021/6/9 19:09, Zdenek Kabelac ??:
> Dne 09. 06. 21 v 11:32 Wu Guanghao napsal(a):
>> Hi,
>>
>> lvcreate and lvremove execute lvmcache_label_scan() to read the metadata on the lvm device,
>> but no lock is added for protection. if other processes are currently executing vg_commit() to submit metadata,
>> then it will go wrong.
> 
> 
> 
> Hi
> 
> The initial scan is going 'lockless' to avoid holding VG locks for too long when it's not strictly necessary.
> 
> The purpose of this scan is to quickly collect & cache all the info which is needed to know. The we take the lock and essentially do another 'rescan' however in this case we only need to 'check' if the cache data corresponds to the current disk state by checking only PV small header information.
> 
> Another 'side' efffect? (probably not very used) is that user may specify VG via? VG UUID, but for the VG lock we need to use VG name - so we need to be able to 'translate' UUID to vgname - and for this we need to know lvm2 metadata with this info.
> 
> Now when the parallel processe manages to change some data (while holding its lock), such internal disk cache will be thrown away (PV header will mismatch) and this particular PV is rereaded while the command now holds the correct lock. But this is really very occasional situation and the benefit of lockless asynchronous scanning outweighs this.
> 
> 
> Regards
> 
> 
> Zdenek
> 
> 
> .



