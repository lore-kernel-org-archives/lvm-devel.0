From: David Teigland <teigland@redhat.com>
Date: Wed, 24 Feb 2021 12:21:01 -0600
Subject: Question: the failure handling for sanlock
In-Reply-To: <20210224031630.GB25715@leoy-ThinkPad-X240s>
References: <20210214101303.GA399193@leoy-ThinkPad-X240s>
	<20210215163127.GA25608@redhat.com>
	<20210224031630.GB25715@leoy-ThinkPad-X240s>
Message-ID: <20210224182101.GD4136@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 24, 2021 at 11:16:30AM +0800, Leo Yan wrote:
> I verified the two patches you mentioned, and applied your suggestion
> to use the command:
> 
>   "$DMSETUP" info -c -S "uuid=~LVM && vgname=$VG_NAME && lv_layer=\"\"" \
>   	-o name --noheadings | xargs "$DMSETUP" wipe_table
> 
> At the end, I can see the device is changed to use DM "error" backend
> driver:
> 
>   Broadcast message from systemd-journald at localhost.localdomain (Tue 2021-02-23 21:55:16 EST):
>   lvmlockctl[2032]: Deactivated LVs in VG TESTVG1 successfully.
> 
>   Broadcast message from systemd-journald at localhost.localdomain (Tue 2021-02-23 21:55:16 EST):
>   lvmlockctl[2032]: Runing lvmlockctl --drop TESTVG1.
> 
>   # dmsetup table
>   TESTPV1: 0 163840 linear 8:146 0
>   TESTVG1-TESTVG1LV1: 0 155648 error
> 
> Please be aware, to avoid misleading, I tested this with another
> in-house locking scheme rather than sanlock, but the working flow for
> failure handling is exactly same.
> 
> I have updated a bit for the two patches [1]; but want to check with you
> how to proceed to merge these patches?  Would you directly merge patches
> at your side or you want me to resend these two patches so you could
> take a review before merging?  For the later case, I am glad to send the
> patches to lvm-devel mailing list and follow up comments/suggestions as
> needed.
> 
> Thanks,
> Leo
> 
> [1] https://people.linaro.org/~leo.yan/lvm/

Thanks for verifying that, please send the patches to the list and I'll
take them from there.  Another part I now remember we need to address is
making this configurable (blkdeactivate isn't an established command.)
I'll need to come up with a solution to that before pushing them out.  The
possible solutions I'm seeing are somewhat ugly, and this is one of the
reasons we didn't finish the integration last time.

Dave


