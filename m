From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 May 2010 22:19:41 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BF43FFD.30504@redhat.com> (Takahiro Yasui's message of "Wed, 19
	May 2010 15:46:05 -0400")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com> <4BF1CAD9.1050005@redhat.com>
	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
	<4BF3FE5C.8070906@redhat.com>
	<874oi34ubd.fsf@twilight.int.mornfall.net.>
	<4BF43FFD.30504@redhat.com>
Message-ID: <87zkzv3aqq.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui <tyasui@redhat.com> writes:

>>+++ cvs-upstream/tools/lvconvert.c	2010-05-19 20:18:40.000000000 +0200
>>@@ -1225,11 +1225,11 @@
>> 		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
>> 				       _is_partial_lv, NULL, 0))
>> 			return 0;
>
> As I posted in the previous mail, the argument, new_log_count, is
> correct here? The argument is used to check if a log should be removed.
> I think that failed_log comes here instead of new_log_count.

Oh *jeez*.

int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
		      struct logical_volume *lv,
		      uint32_t mirrors, uint32_t log_count,
		      int (*is_removable)(struct logical_volume *, void *),
		      void *removable_baton,
		      uint64_t status_mask)

Notice how the parameter is named "log_count" -- I have assumed, given
that elsewhere it is called "remove_log" that this has a reverse
meaning. Wrong, it actually means the same thing as remove_log.

Thanks for noticing this. So yes, it should spell

		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, failed_log,
				       _is_partial_lv, NULL, 0))

... now this was probably not being noticed, since in most cases, the
mistakenly removed log would be re-created right away by later
code. I'll fix this in my local patch.

> Or the value such as nlc in _lvconvert_mirrors_aux() comes.
>
>                 uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
> 		...
> 		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
>                                               is_mirror_image_removable, operable_pvs, 0))

Ugh, nlc sounds like short for new_log_count to me, which is *extremely
confusing*, since it's actually quite opposite: nlc = 1 means remove
log, nlc = 0 means retain the log. Is that right?

Yours,
   Petr.


