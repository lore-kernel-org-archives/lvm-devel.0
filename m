From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 11 Feb 2010 20:14:11 -0500
Subject: [PATCH] Ignore _mlog name restriction for lvconvert repair
In-Reply-To: <20100211203827.GA27416@us.ibm.com>
References: <471e224a57131c07b705.1265821968@localhost>	<4B746099.7010709@redhat.com>
	<20100211203827.GA27416@us.ibm.com>
Message-ID: <4B74AB63.9090706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

malahal at us.ibm.com wrote:
> Takahiro Yasui [tyasui at redhat.com] wrote:
>> Malahal Naineni wrote:
>>> lvconvert --repair is done on _mlog mirrored log logical volumes from
>>> dmeventd if something fails.
>>>
>>> diff -r 86200db56a7c -r 471e224a5713 tools/lvconvert.c
>>> --- a/tools/lvconvert.c	Tue Feb 09 17:49:50 2010 -0800
>>> +++ b/tools/lvconvert.c	Wed Feb 10 09:12:11 2010 -0800
>>> @@ -105,8 +105,12 @@ static int _lvconvert_name_params(struct
>>>  	if ((ptr = strrchr(lp->lv_name_full, '/')))
>>>  		lp->lv_name = ptr + 1;
>>>  
>>> -	if (!apply_lvname_restrictions(lp->lv_name))
>>> -		return_0;
>>> +	/* _mlog is an internal name, but it could be mirrored, so
>>> +	 * allow repairing it.
>>> +	 */
>>> +	if (!arg_count(cmd, repair_ARG) || !strstr(lp->lv_name, "_mlog"))
>>> +		if (!apply_lvname_restrictions(lp->lv_name))
>>> +			return_0;
>>>  
>>>  	if (*pargc && lp->snapshot) {
>>>  		log_error("Too many arguments provided for snapshots");
>> lvname is better to be checked if a logical volume is not mirrored log
>> but simple logical volume. How about using (lv->status & MIRRORED) for
>> the check?
> 
> I thought about it but such details are not available at that point. All
> the information available at that point is derived from the command line
> arguments!

Thank you for the explanation. I see we need to move this name check
at the place where lv->status check can be used.

Thanks,
Taka



