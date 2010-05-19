From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 May 2010 14:06:26 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BF1CAD9.1050005@redhat.com> (Takahiro Yasui's message of "Mon, 
	17 May 2010 19:01:45 -0400")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com> <4BF1CAD9.1050005@redhat.com>
Message-ID: <87ljbg3xkt.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Taka,

Takahiro Yasui <tyasui@redhat.com> writes:
> On 05/14/10 18:52, Takahiro Yasui wrote:
>> I also tested this patch for a lvm mirror with core/disk log. When
>> a mirror log failed, the mirror log was removed from a mirror volume,
>> but a log voluem is not removed from its volume group. This always
>> happens both on a transient and persistent error.
>
> This issue seems related to this part of your patch.
>
> @@ -1139,6 +1163,8 @@ static int _lvconvert_mirrors_repair(str
> ...
> -	/*
> -	 * Remove all failed_pvs
> -	 */
> -	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
> -				    lp->mirrors, new_log_count))
> -		return 0;
> +	if (failed_mirrors) {
> +		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
> +				       _is_partial_lv, NULL, 0))
> +			return 0;
> +
> +		if (!_reload_lv(cmd, lv))
> +			return 0;
> +	}
>
> When I removed this modification, a log volume was removed as expected.
> And also other my test cases also passed.

The catch is that this won't work correctly in other cases, especially
with transient errors. I suspect the real problem is in not calling
_lv_update_log_type in the new code path -- but see below: I cannot
reliably fix this without having a reproducer. Also, I would very much
like to have the tests you had failing on our regression suite, to avoid
similar problem in the future.

> I hope this information would be helpful.

Yes, it is indeed quite helpful.

Unfortunately, I still cannot reproduce the problem -- I have written a
few testcases that only fail the log, or fail a log and some other
things and I can't seem to trigger the bug. I have tried with both
normal and cluster locking.

It would be very useful if you could provide more specific instructions
on how to trigger this.

I have tried these, all of them remove the log as expected, both with
and without my patch (at least for me):

aux prepare_vg 5
lvcreate -m 2 --ig -L 1 -n 3way $vg
disable_dev $dev1 $dev2
echo n | lvconvert --repair $vg/3way
check linear $vg 3way
lvs -a -o +devices | not grep unknown
lvs -a -o +devices | not grep mlog
dmsetup ls | not grep mlog
vgreduce --removemissing $vg
enable_dev $dev1 $dev2
check linear $vg 3way

aux prepare_vg 5
lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
disable_dev $dev4
echo n | lvconvert --repair $vg/3way
check mirror $vg 3way core
lvs -a -o +devices | not grep unknown
lvs -a -o +devices | not grep mlog
dmsetup ls | not grep mlog
vgreduce --removemissing $vg
enable_dev $dev4

aux prepare_vg 5
lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
disable_dev $dev3
echo n | lvconvert --repair $vg/2way
check mirror $vg 2way core
lvs -a -o +devices | not grep unknown
lvs -a -o +devices | not grep mlog
vgreduce --removemissing $vg
enable_dev $dev3

Some further analysis:

During a call to lv_remove_mirrors above, we call through to
_remove_mirror_images, with remove_log = 1. We have this:

	... if (remove_log)
		detached_log_lv = detach_mirror_log(mirrored_seg);

        ...

	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
		return_0;

So the log *should* be gone after this is finished. Since you see the
log hanging around, I suspect that this code has some bugs (this part of
the code is known to be problematic, unfortunately). Apart from actual
steps to reproduce the problem, the output from lvconvert doing the
repair would be helpful. It should be printing things like "Mirror
status" and "Mirror log status", please paste these.

Thanks!

Yours,
   Petr.


