From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 28 Apr 2011 11:01:13 +0200
Subject: [PATCH] Refactor lib/ code to allow deferred PV labelling
In-Reply-To: <20110427182420.GD32370@agk-dp.fab.redhat.com>
References: <87oc3rhp66.fsf@aldalome.int.mornfall.net.>
	<20110427182420.GD32370@agk-dp.fab.redhat.com>
Message-ID: <4DB92CD9.1060508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/27/2011 08:24 PM +0100, Alasdair G Kergon wrote:
>> @@ -51,6 +51,9 @@ struct physical_volume {
> 
>> +	/* NB. Only useful/used when status & UNLABELLED_PV! */
>> +	int64_t label_sector;
> 
>> @@ -59,6 +65,13 @@ struct volume_group {
>> +	struct dm_list pvs_to_create;
> 
> These are really just temporary places to store things - not used as an intrinsic
> part of the structs themselves.  How difficult is it to handle them
> separately outside the structs?

Well, normally, we store that in PV-based format instance context
(the 'struct text_fid_pv_context' that is stored in 'private' field in
'struct format_instance). But if that PV is part of the VG, we use a
common VG-based format instance - so we can't store that PV info there
separately for each PV...

So how about using 'struct pvcreate_params' we attach to 'struct pv_to_create'
in add_pv_to_vg fn:

  if (pv->status & UNLABELLED_PV) {
                if (!(pvc = dm_pool_zalloc(mem, sizeof(*pvc)))) {
                        log_error("pv_to_create allocation for '%s' failed", pv_name);
                        return 0;
                }    
                pvc->pv = pv;
                pvc->pp = pp;
                ...
  ...


Can we use that to store that label sector info? Would that work?

If we don't find a place for that label sector other than the struct PV
itself as proposed in this patch, we can also remove the 'struct text_fid_pv_context'.
The text_fid_pv_context is here to store the label_sector info only. At least for now.
I wanted to use the PV struct for that as well the other day, like you do here... ;)
It's useless to store that in two places at the same time.

Peter

