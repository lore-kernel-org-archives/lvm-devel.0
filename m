From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 21 Oct 2009 15:25:40 -0500
Subject: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <20091015231808.GD16950@agk-dp.fab.redhat.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
	<20091015231808.GD16950@agk-dp.fab.redhat.com>
Message-ID: <6675944B-1ED6-4A7B-BDE0-C48F72825E1A@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

agk,

I've been thinking about this... What I'd really like to see done is a  
two phase allocation for mirrors.  The first phase would be for the  
legs and the second phase would be for the log(s).  If we cleaned  
things up in this way, there would be no need for the log_area(s) at  
all.  This would involve changing the code around a bit more, but  
would give us an easier path to adhering to various allocation  
policies.  Also, it would make function behave more like their  
original intent, rather than having these extra bolt-on items that  
seem to bloat functions every time we add a new feature.  If you are  
keen on this approach, would you settle for the posted patch for now?

In (weak) defense of the patch as it's written, please note that the  
'areas' field is an /array/ of 'dm_list' type.  Each element in the  
array is for a specific leg.  The elements are lists presumably to  
handle multiple segments per leg.  Logs, on the other hand, are never  
more than one segment, so I don't need something as complicated as an  
array of lists.  Either an array or a list would be fine. I thought it  
would be easier to use the list vs. the array.  Note also that  
_find_parallel_areas cycles through the log PVs to avoid them if  
possible... which complicates putting them together with the 'areas'  
array of lists.

If you still want me to attempt doing it as you describe, then I  
will.  Otherwise, I'd rather avoid doing this intermediate step and  
move straight to a two phase allocation.

Your thoughts?

  brassow


On Oct 15, 2009, at 6:18 PM, Alasdair G Kergon wrote:

> On Thu, Oct 08, 2009 at 04:18:36PM -0500, Jon Brassow wrote:
>> -	struct alloced_area log_area;	/* Extent used for log */
>> +	struct dm_list log_areas;	/* Extents used for logs */
>> 	struct dm_list alloced_areas[0];	/* Lists of areas in each stripe */
>
> Rather than storing the log areas differently (in a list) from the  
> other areas
> (in an array), I'd prefer them all to be stored the same way.
>
> I.e. In a simple contiguous 2-leg mirror plus mirrored log, you'd get
>  leg1 as first item on alloced_areas[0] list,
>  leg2 as first item on alloced_areas[1] list,
>  log leg1 as first item on log_areas list,
>  log leg2 as second item on log_areas list.
>
> I'd prefer to see:
>  leg1 as first item on alloced_areas[0] list,
>  leg2 as first item on alloced_areas[1] list,
>  log leg1 as first item on log_areas[0] list,
>  log leg2 as first item on log_areas[1] list.
> and of course log_areas[0] can be the same as alloced_areas[2].
>
> This should be both simpler (logs are less of a special case and
> like any other area may include more than 1 segment) and more general
> (we're asking to allocate several parallel areas, with different  
> lengths
> but sorted largest first and with different allocation constraints
> applying to some of them).
>
> Alasdair
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


