From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Wed, 14 Oct 2009 10:16:09 -0700
Subject: Re: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <0FBED8C9-24F0-48D7-81E5-A041AA11F03D@redhat.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
	<20091013014820.GA27349@us.ibm.com>
	<0FBED8C9-24F0-48D7-81E5-A041AA11F03D@redhat.com>
Message-ID: <20091014171609.GA9054@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
>
> On Oct 12, 2009, at 8:48 PM, malahal at us.ibm.com wrote:
>
>> Jonathan Brassow [jbrassow at redhat.com] wrote:
>>> Patch name: lvm-make-log_area-a-list.patch
>>>
>>> The 'alloc_handle' structure only has space for one log_area.
>>> We change that to a list to allow an arbitrary number of
>>> log areas.
>>>
>>> RFC: Jonathan Brassow <jbrassow@redhat.com>
>>>
>>> @@ -1061,10 +1065,14 @@ static int _find_parallel_space(struct a
>>> 				continue;	/* Next PV */
>>>
>>> 			if (alloc != ALLOC_ANYWHERE) {
>>> -				/* Don't allocate onto the log pv */
>>> -				if (ah->log_count &&
>>> -				    pvm->pv == ah->log_area.pv)
>>> -					continue;	/* Next PV */
>>> +				/* Don't allocate onto the log pvs */
>>> +				dm_list_iterate_items(aa, &ah->log_areas)
>>> +					if (pvm->pv == aa->pv)
>>> +						skip = 1;
>>
>>                                       You can 'break' soon after setting 
>> skip.
>
> If I use 'break' won't that break out of the 'dm_list_iterate_items' and 
> not the enclosing loop - giving an incorrect result?

IIRC, there are two dm_list_iterate_items loops. You can 'break' from the
inner loop after setting 'skip=1' and the next statement will check that
skip is set and execute 'continue' for the outer loop.

My understanding is that the current code executes the inner loop to
completion every time.

Thanks, Malahal.


