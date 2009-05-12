From: Milan Broz <mbroz@redhat.com>
Date: Tue, 12 May 2009 15:37:23 +0200
Subject: [PATCH 4/7] Introduce vg_add_lc and vg_remove_lv functions.
In-Reply-To: <87eiuwu69u.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>	<cover.1241620083.git.mbroz@redhat.com>	<bf14f3b5346d9d6ddf3ecfe7c064caf2b1bb9bcd.1241620083.git.mbroz@redhat.com>
	<87eiuwu69u.fsf@eriador.mornfall.net>
Message-ID: <4A097B93.10809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> Btw., would vg_link_lv and vg_unlink_lv describe better what these two
> functions do? It seems a little easy to confuse _add_lv and vg_add_lv, while
> the two do quite a different thing.
yes, renamed

>> @@ -331,7 +330,7 @@ int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lv
>>  		lv->alloc = ALLOC_NORMAL;
>>  
>>  	if (!lvd->lv_read_ahead)
>> -		lv->read_ahead = lv->vg->cmd->default_settings.read_ahead;
>> +		lv->read_ahead = cmd->default_settings.read_ahead;
>>  	else
>>  		lv->read_ahead = lvd->lv_read_ahead;
>>  
> I'm not sure why is this change needed? (Adding cmd_context parameter to
> import_lv.)

just code shuffle, because lv->vg is initialized later in vg_add_lv and we
need cmd for default settings.
(probably explains some code shuffle later too)

> Does not change what the code does, just shuffles the lines somewhat. It does
> change semantics of import_lv, but that function is never used outside _add_lv
> anyway (would it make sense to make it static _import_lv, in a separate
> patch?).
ok, I'll move it to separate patch

>> +		//FIXME: cow still in VG, fix count, remove this later
>> +		if (lv->status & SNAPSHOT)
>> +			lv->vg->lv_count++;
> ^^ This is indeed ugly (see also my previous mail: it might be worth getting
> rid of lv_count altogether) ... although this patch is a definite improvement,
> it is still suboptimal in this respect.

later patch removes that, I keep it here just that every separate patch can pass
full testing.

Milan


