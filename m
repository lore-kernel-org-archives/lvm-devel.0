From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 May 2010 11:06:04 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87ljbg3xkt.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>	<4BEDD432.4010800@redhat.com>
	<4BF1CAD9.1050005@redhat.com>
	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
Message-ID: <4BF3FE5C.8070906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

On 05/19/10 08:06, Petr Rockai wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
> The catch is that this won't work correctly in other cases, especially
> with transient errors. I suspect the real problem is in not calling
> _lv_update_log_type in the new code path -- but see below: I cannot
> reliably fix this without having a reproducer. Also, I would very much
> like to have the tests you had failing on our regression suite, to avoid
> similar problem in the future.
> ...
> Unfortunately, I still cannot reproduce the problem -- I have written a
> few testcases that only fail the log, or fail a log and some other
> things and I can't seem to trigger the bug. I have tried with both
> normal and cluster locking.
> 
> It would be very useful if you could provide more specific instructions
> on how to trigger this.

Here is the instruction. I used 2.02.65 but I also reproduced it using
2.02.66, too.

0. environment

# lvm version
  LVM version:     2.02.66(2)-cvs (2010-05-17)
  Library version: 1.02.49-cvs (2010-05-17)
  Driver version:  4.16.0

# grep mirror_log_fault_policy /etc/lvm/lvm.conf
    # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
    mirror_log_fault_policy = "remove"

1. create vg and lv

# vgcreate vg00 /dev/sd[c-e]; lvcreate --ig -m1 -L12m -nlv00 vg00
  Volume group "vg00" successfully created
  Logical volume "lv00" created

2. disable log device (/dev/sde in my environment)

# echo offline > /sys/block/sde/device/state

3. run 'lvconvert --repair'

# lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies vg00/lv00
  Mirrored transient status: "2 253:1 253:2 24/24 1 AA 3 disk 253:0 D"
  Mirror log status: 1 of 1 images failed - switching to core
  WARNING: Failed to replace 1 of 1 logs in volume lv00

4. check logical volumes

# lvs
  LV        VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  lv00      vg00 mwi-a- 12.00M                        100.00
  lv00_mlog vg00 -wi---  4.00M

> aux prepare_vg 5
> lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
> disable_dev $dev3
> echo n | lvconvert --repair $vg/2way
> check mirror $vg 2way core
> lvs -a -o +devices | not grep unknown
> lvs -a -o +devices | not grep mlog
> vgreduce --removemissing $vg
> enable_dev $dev3

This issue didn't occurred with your test case in my environment, either.
So, the differences in our test cases seems 'policy.' I used the same
options for lvconvert as ones in dmeventd.

Thanks,
Taka


> During a call to lv_remove_mirrors above, we call through to
> _remove_mirror_images, with remove_log = 1. We have this:
> 
> 	... if (remove_log)
> 		detached_log_lv = detach_mirror_log(mirrored_seg);
> 
>         ...
> 
> 	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
> 		return_0;
> 
> So the log *should* be gone after this is finished. Since you see the
> log hanging around, I suspect that this code has some bugs (this part of
> the code is known to be problematic, unfortunately). Apart from actual
> steps to reproduce the problem, the output from lvconvert doing the
> repair would be helpful. It should be printing things like "Mirror
> status" and "Mirror log status", please paste these.

Yes, see step 4.

Thanks,
Taka


