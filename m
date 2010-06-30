From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 23:28:12 +0200
Subject: [PATCH] restore the "removemissing" behaviour of lvconvert --repair --use-policies
In-Reply-To: <20100630205925.GS23989@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 30 Jun 2010 21:59:25 +0100")
References: <87y6dwjlo6.fsf@twilight.int.mornfall.net.>
	<20100630205925.GS23989@agk-dp.fab.redhat.com>
Message-ID: <876310jjmb.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:

> On Wed, Jun 30, 2010 at 10:43:53PM +0200, Peter Rockai wrote:
>> -	struct dm_list *failed_pvs = NULL;
>
>> -	if (!(failed_pvs = _failed_pv_list(lv->vg)))
>> +	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
>
> How does the patch work?

Ah, this is not mentioned in the patch since it was not changed. The
missing piece of the puzzle is this:

   1567                 if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
   1568                         _remove_missing_empty_pv(lv->vg, lp->failed_pvs);
                                                                 ^^^^

Yours,
   Petr.


