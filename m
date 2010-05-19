From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 May 2010 16:35:21 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87zkzv3aqq.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>	<4BEDD432.4010800@redhat.com>
	<4BF1CAD9.1050005@redhat.com>	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>	<4BF3FE5C.8070906@redhat.com>	<874oi34ubd.fsf@twilight.int.mornfall.net.>	<4BF43FFD.30504@redhat.com>
	<87zkzv3aqq.fsf@twilight.int.mornfall.net.>
Message-ID: <4BF44B89.2070309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/19/10 16:19, Petr Rockai wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
> 
>>> +++ cvs-upstream/tools/lvconvert.c	2010-05-19 20:18:40.000000000 +0200
>>> @@ -1225,11 +1225,11 @@
>>> 		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
>>> 				       _is_partial_lv, NULL, 0))
>>> 			return 0;
>>
>> As I posted in the previous mail, the argument, new_log_count, is
>> correct here? The argument is used to check if a log should be removed.
>> I think that failed_log comes here instead of new_log_count.
...
> ... now this was probably not being noticed, since in most cases, the
> mistakenly removed log would be re-created right away by later
> code. I'll fix this in my local patch.

Yeah, that valuable name is very confusing. :-<
Anyway thanks to fixing this.

>> Or the value such as nlc in _lvconvert_mirrors_aux() comes.
>>
>>                 uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
>> 		...
>> 		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
>>                                               is_mirror_image_removable, operable_pvs, 0))
> 
> Ugh, nlc sounds like short for new_log_count to me, which is *extremely
> confusing*, since it's actually quite opposite: nlc = 1 means remove
> log, nlc = 0 means retain the log. Is that right?

Yes, it is. It is similarly used as the previous parameter, nmc.
nmc tells the number of mirrors which will be removed. So as for
nlc, it is easier to think nlc the log number which should be removed.
(0: not removed, 1: removed)

Thanks,
Taka


