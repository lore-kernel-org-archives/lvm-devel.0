From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 21 Jul 2010 11:57:29 -0400
Subject: [PATCH] Handle a failure of all mirror devices but one mirror leg
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A5922886542@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A5922886542@USINDEVS02.corp.hds.com>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A5922886560@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/19/10 18:09, Takahiro Yasui wrote:
> - With Jon's second patch, we think that we don't have to call
>   remove_mirror_log() in _lv_update_mirrored_log() because will be
>   handled remove_mirror_images() in _lvconvert_mirrors_repaire().

Additional comment on remove_mirror_log().

Calling remove_mirror_log() in _lv_update_mirrored_log() is not good.
The reason is that remove_mirror_log() calls suspend_lv() and resume_lv()
for an original mirror volume which contains the broken mirrored log when
VG metadata is updated in _remove_mirror_images(), but there is a problem
when there is a broken mirror leg.

suspend_lv() and resume_lv() will suspend and resume an original LV with
broken legs. When the original mirror volume is resumed, recovery process
is executed in kernel according to the state of log. This time, mirror volume
is fixed in termes of *log* but not in terms of mirror legs. So I'm afraid the
recovery process will fail. We need to resume an original mirror volume only
after its mirror legs are completely fixed.

When I introduced _lv_update_mirrored_log(), it called remove_mirror_images()
for a mirrored log. This means that suspend and resume are executed only
for a mirrored log but not for original volume.

With this information, I appreciate your review of this patch.
https://www.redhat.com/archives/lvm-devel/2010-July/msg00131.html

Thanks,
Taka


