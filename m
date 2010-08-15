From: Jeff Chua <jeff.chua.linux@gmail.com>
Date: Sun, 15 Aug 2010 05:24:01 -0000
Subject: [dm-devel] linux-2.6.35+ causes LVM to fail with " device-mapper: version ioctl failed: Inappropriate ioctl for device"
In-Reply-To: <20100814155401.GJ26032@agk-dp.fab.redhat.com>
References: <AANLkTime9NS3Bk-8ZpovRNy9iEGJxwYw=-aZ38JoRa_3@mail.gmail.com>
	<20100814155401.GJ26032@agk-dp.fab.redhat.com>
Message-ID: <AANLkTi=aJ7f5X9sMeA85KJxi+rzWhiZCZ2ZwriNEVFCT@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Aug 14, 2010 at 11:54 PM, Alasdair G Kergon <agk@redhat.com> wrote:
> On Sat, Aug 14, 2010 at 02:01:47AM +0800, Jeff Chua wrote:
>> It seems one of these commits in
>> 8357422d4bf33bc2c35884d4016c3fc9efbbc1d2 is causing LVM2
>> (LVM2.2.02.72) to fail.
>
> Did you (partially) bisect that or are you just guessing?
> The only one there possibly relevant is 7e507eb6432afdd798d4c6dccf949b8c43ef151c.

Guessing only. Not bisecting yet. Prior to the git pull, everything
was working fine. And double confirmed by going to prior to the pull,
everything still worked.


>> Previously good logical volumes cannot be mounted anymore, and new one
>> cannot be created. All failed with the error ...
>> "device-mapper: version ioctl failed: Inappropriate ioctl for device"
>
> What distribution? ?What version of udev package?

Just a vanilla linux. No udev.


> 'lvm version' output?

  LVM version:     2.02.72(2) (2010-07-28)
  Library version: 1.02.53 (2010-07-28)
  Driver version:  4.17.0


> Provide long listing of /dev/mapper and any dm/lvm devices in /dev.
> Add -vvvv to your lvm command for better clues.

Attached. good.vg01 is from prior to the patch. bad.vg01 is the bad one.

>> Is there a new LVM2 for this new dm ioctl or the dm is not right?
> There's no new dm ioctl.

> I'm guessing you could have a configuration not covered by the latest userspace
> libdevmapper - not handling some combination of kernel+userspace+initrd
> packages correctly.  We already dealt with one udev+initrd combination that
> failed last week.

Could be. Please help.

Thanks,
Jeff
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg01.good
Type: application/octet-stream
Size: 12486 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100815/1fd79fb4/attachment.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg01.bad
Type: application/octet-stream
Size: 14373 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100815/1fd79fb4/attachment-0001.obj>
