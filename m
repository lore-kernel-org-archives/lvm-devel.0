From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 May 2010 13:15:02 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <4BF41557.3040708@redhat.com>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>	<87y6fxos3x.fsf@twilight.int.mornfall.net.>	<4BEDD432.4010800@redhat.com>	<4BF1CAD9.1050005@redhat.com>	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
	<4BF41557.3040708@redhat.com>
Message-ID: <4BF41C96.4090702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Peter,

>>> +	if (failed_mirrors) {
>>> +		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
>>> +				       _is_partial_lv, NULL, 0))

+        if (failed_mirrors || failed_log) {
+                if (!lv_remove_mirrors(cmd, lv, failed_mirrors, failed_log,
+                                       _is_partial_lv, NULL, 0)) {

My test cases passed with this modification.

Thanks,
Taka



On 05/19/10 12:44, Takahiro Yasui wrote:
> Hi Petr,
> 
> On 05/19/10 08:06, Petr Rockai wrote:
>> Takahiro Yasui <tyasui@redhat.com> writes:
>>> On 05/14/10 18:52, Takahiro Yasui wrote:
>>>> I also tested this patch for a lvm mirror with core/disk log. When
>>>> a mirror log failed, the mirror log was removed from a mirror volume,
>>>> but a log voluem is not removed from its volume group. This always
>>>> happens both on a transient and persistent error.
>>>
>>> This issue seems related to this part of your patch.
>>>
>>> @@ -1139,6 +1163,8 @@ static int _lvconvert_mirrors_repair(str
>>> ...
>>> -	/*
>>> -	 * Remove all failed_pvs
>>> -	 */
>>> -	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
>>> -				    lp->mirrors, new_log_count))
>>> -		return 0;
>>> +	if (failed_mirrors) {
>>> +		if (!lv_remove_mirrors(cmd, lv, failed_mirrors, new_log_count,
>>> +				       _is_partial_lv, NULL, 0))
>>> +			return 0;
>>> +
>>> +		if (!_reload_lv(cmd, lv))
>>> +			return 0;
>>> +	}
>>>
>>> When I removed this modification, a log volume was removed as expected.
>>> And also other my test cases also passed.
>>
>> The catch is that this won't work correctly in other cases, especially
>> with transient errors. I suspect the real problem is in not calling
>> _lv_update_log_type in the new code path -- but see below: I cannot
>> reliably fix this without having a reproducer. Also, I would very much
>> like to have the tests you had failing on our regression suite, to avoid
>> similar problem in the future.
> 
> I checked this code, but the value of failed_mirrors is '0' when
> no mirror leg has error. So this code path was not executed in
> my test. This is the reason why log was not removed with
> mirror_log_fault_policy = "remove".
> 
> mirror_log_fault_policy = "allocate," on the other hand, the log
> was removed in the following path.
> 
>         while (replace_mirrors || replace_log) {
>                 ...
>                 if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
>                                            lp->mirrors, log_count))
>                         break;
> 
> We need to change the condition so that lv_remove_mirrors() is
> executed.
> 
>>> -	 * Remove all failed_pvs
>>> -	 */
>>> -	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
>>> -				    lp->mirrors, new_log_count))
>>> -		return 0;
>>> +	if (failed_mirrors) {
> 
> Thanks,
> Taka
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


