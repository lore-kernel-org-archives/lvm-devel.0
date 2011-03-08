From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 08 Mar 2011 23:30:16 +0100
Subject: [PATCH 3/4] Use allog_vg for _free_vg in _pvsegs_sub_single
In-Reply-To: <20110308170931.GH10767@agk-dp.fab.redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
	<5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>
	<20110308170931.GH10767@agk-dp.fab.redhat.com>
Message-ID: <4D76ADF8.1090901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.3.2011 18:09, Alasdair G Kergon napsal(a):
> On Wed, Mar 02, 2011 at 07:20:25PM +0100, Zdenek Kabelac wrote:
>> Switch to use alloc_vg function for allocation of VG struct.
>  
> This code looks wrong.  Maybe it suffered from some previous global change.
> 
>> -	struct volume_group _free_vg = {
>> -		.cmd = cmd,
>> -		.name = "",
>> -	};
> 
> I think that should stay as it is.

Peter already spend quite some time debuging bug in missing initialization (he
was not using this patchset in his code) of some VG list structure - because
there were 5 copies of VG alloc code and some of them were not all properly
setting all values to some defined state.

> 
>> -        if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
>> -		return ECMD_FAILED;
> 
> Why is vgmem being allocated?  If something really is using it, why?

I've in my tree already slightly better patch which allocates and free
_free_vg only if '!vg'.


The major purpose if the patch is to keep also reference count setting in one
place (needed in my vg sharing patch) - also whenever someone adds any new
member to VG structure - only one place needs to be updated for proper
initialization.  So I'd still prefer to have this code running through
standard allocation procedure.

Zdenek


