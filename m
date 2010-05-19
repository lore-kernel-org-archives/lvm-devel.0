From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 May 2010 20:31:34 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BF3FE5C.8070906@redhat.com> (Takahiro Yasui's message of "Wed, 
	19 May 2010 11:06:04 -0400")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com> <4BF1CAD9.1050005@redhat.com>
	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
	<4BF3FE5C.8070906@redhat.com>
Message-ID: <874oi34ubd.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

Takahiro Yasui <tyasui@redhat.com> writes:
> 3. run 'lvconvert --repair'
>
> # lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies vg00/lv00
>   Mirrored transient status: "2 253:1 253:2 24/24 1 AA 3 disk 253:0 D"
>   Mirror log status: 1 of 1 images failed - switching to core
>   WARNING: Failed to replace 1 of 1 logs in volume lv00
>
> 4. check logical volumes
>
> # lvs
>   LV        VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
>   lv00      vg00 mwi-a- 12.00M                        100.00
>   lv00_mlog vg00 -wi---  4.00M

I have tracked the problem down to a silly branching bug in
lvconvert.c. The LV was only being written to disk if mirrors changed,
or log re-allocation was attempted. I have fixed that, and also added
both mine and your testcases to the suite.

The attached patch is on top of the previous one -- it should apply
cleanly on top of current CVS + the lvconvert-repair-transient.diff I
have sent previously. It also fixes a bug in messages, where it would
claim that it failed to replace things even if it never tried to in the
first place.

Please test and let me know if you run into any other issues.

Thanks,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-transient-inter.diff
Type: text/x-diff
Size: 5799 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100519/e6a38379/attachment.bin>
