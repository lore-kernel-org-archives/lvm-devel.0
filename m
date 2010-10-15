From: Petr Rockai <prockai@redhat.com>
Date: Fri, 15 Oct 2010 13:57:29 +0200
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
In-Reply-To: <4CB6D2BC.9060404@redhat.com> (Zdenek Kabelac's message of "Thu, 
	14 Oct 2010 11:51:56 +0200")
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<4CB6D2BC.9060404@redhat.com>
Message-ID: <87aamffz2u.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> I don't like these hard coded numbers - maybe it should be connected to
> PATH_MAX * xyz + abc, or maybe just use dm_asprintf ?

Unlimited allocations are not allowed in dmeventd anyway, so you have to
cap it somehow. PATH_MAX is probably too big. As long as the number is
in just one place, I don't see the problem (the rest is referring to
sizeof of the array instead).

>> --- old-snapshot-monitoring/tools/lvresize.c	2010-10-05 19:42:32.000000000 +0200
>> +++ new-snapshot-monitoring/tools/lvresize.c	2010-10-05 19:42:32.000000000 +0200
>> @@ -196,34 +197,41 @@ static int _lvresize_params(struct cmd_c
> ...
>> +
>> +		if (arg_count(cmd, extents_ARG)) {
>> +			lp->extents = arg_uint_value(cmd, extents_ARG, 0);
>> +			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
>> +			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
>> +		}
>> +
>> +		/* Size returned in kilobyte units; held in sectors */
>> +		if (arg_count(cmd, size_ARG)) {
>> +			lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
>
> I know it's just code move - but we could strip this unneeded UINT64_C.
Ok. (The attached patch fixes this.)

>> +static int _adjust_policy_params(struct cmd_context *cmd,
>> +				 struct logical_volume *lv, struct lvresize_params *lp)
>> +{
>> +	float percent;
>> +	percent_range_t range;
>> +	int policy_threshold, policy_amount;
>> +
>> +	policy_threshold =
>> +		find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
>> +				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD);
>> +	policy_amount =
>> +		find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
>> +				     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
>> +
>> +	if (policy_threshold >= 100)
>> +		return 1; /* nothing to do */
>
> For some really large sizes - even 1% could be a huge amount of disk space -
> so maybe some users would like to see floating number support here?

I'd open a separate bug for that, if you really think so. I tend to
disagree. (Btw. there's no single float config option in LVM today --
even though there is theoretical support for that, it's probably not
tested at all.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-extend.diff
Type: text/x-diff
Size: 15258 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101015/0bde6fa3/attachment.bin>
