From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 09 Mar 2011 09:51:47 +0100
Subject: [PATCH 3/4] Use allog_vg for _free_vg in _pvsegs_sub_single
In-Reply-To: <20110309030150.GQ10767@agk-dp.fab.redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>	<5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>	<20110308170931.GH10767@agk-dp.fab.redhat.com>	<4D76ADF8.1090901@redhat.com>
	<20110309030150.GQ10767@agk-dp.fab.redhat.com>
Message-ID: <4D773FA3.3060200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.3.2011 04:01, Alasdair G Kergon napsal(a):
> On Tue, Mar 08, 2011 at 11:30:16PM +0100, Zdenek Kabelac wrote:
>> The major purpose if the patch is to keep also reference count setting in one
>> place (needed in my vg sharing patch) - also whenever someone adds any new
>> member to VG structure - only one place needs to be updated for proper
>> initialization.  So I'd still prefer to have this code running through
>> standard allocation procedure.
>  
> But the new function is not (yet?) initialising the whole structure.

Idea here was - to keep all dm_list initialization in one place - so whenever
some new list or some similar structure which required to have some non-null
value to be usable - it will be set in one place - so one doesn't need to
track all such places in the code and add dm_list_init in more then one place.
(object encapsulation).

> 
> The 'reporter' use is only as a read-only dummy structure to allow us
> to share some code paths.  It should not need a vgmem (or reference
> counting), I'd have thought.


I've been not checking all related code paths which may be executed from this
place - so it's been rather pure code refactoring.

It seems like the code below now should actually never allocate anything from
this pool (seem like after my recent fix for allocation from vg mem and using
reporter's mempool possibly fixed it?) and if it does some allocation
somewhere it's bug which should crash the appliction, but currently IMHO there
was no such restriction put or documented in the code.

Zdenek


