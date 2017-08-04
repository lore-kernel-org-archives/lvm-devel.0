From: Eric Ren <zren@suse.com>
Date: Fri, 4 Aug 2017 15:13:26 +0800
Subject: [PATCH 0/1] adding Btrfs resizing capability to lvresize/fsadm.sh
In-Reply-To: <3d78f6d7-dd89-71cb-e754-88a290287404@hostalia.de>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<3d78f6d7-dd89-71cb-e754-88a290287404@hostalia.de>
Message-ID: <bf152578-cca9-b5a1-98a2-4d7a97a21759@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

openSUSE has a similar patch [1] for a while. The original author sent 
it upstream I think,
but for whatever reason, it was not accepted.

fsadm-add-support-for-btrfs.patch
[1] 
https://build.opensuse.org/package/view_file/Base:System/lvm2/fsadm-add-support-for-btrfs.patch?expand=1

@Upstream experts, please let me know if you are open to merge this patch.
If so, I can give a close review and testing on it. I'd like see your 
patch to be accepted.
Then, I can drop our own patch ;-P

Regards,
Eric

On 08/03/2017 04:44 PM, Marcus M?ller wrote:
> So,
>
> I'll admit that me spontaneously handing in above feature patch
> yesterday was an act of "let's get this out of my head before I go
> home". For private purposes, I wanted lvresize -r to deal with BTRFS, too.
> Am I right here to post feature branches at all? Any copyright
> assignments I need to take care of?
>
> Regarding the patch:
>
> BTRFS is a bit special in that one filesystem can spread across multiple
> physical volumes. In the case of multi-volume BTRFS, we need to specify
> which specific one needs resizing; hence the whole devid dance.
> Also: BTRFS needs to be mounted to be resized; mount detection sometimes
> fails. That is not an issue, since it's safe to multi-mount a filesystem
> and resize it. So in fact, I was considering skipping the checking for
> mountedness completely, but then decided against it to keep the resize_*
> functions as uniform and recognizable as possible.
>
> Best regards,
> Marcus M?ller
>
> On 08/02/2017 07:42 PM, Marcus M?ller wrote:
>> Btrfs support was missing from LVM's volume resize tools.
>> Fixed that.
>>
>> Marcus M?ller (1):
>>    added resizing for btrfs
>>
>>   scripts/fsadm.sh | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>>   1 file changed, 68 insertions(+), 1 deletion(-)
>>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


