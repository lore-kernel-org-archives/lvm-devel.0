From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 30 Jun 2010 22:35:54 +0100
Subject: [PATCH] restore the "removemissing" behaviour of lvconvert --repair --use-policies
In-Reply-To: <876310jjmb.fsf@twilight.int.mornfall.net.>
References: <87y6dwjlo6.fsf@twilight.int.mornfall.net.>
	<20100630205925.GS23989@agk-dp.fab.redhat.com>
	<876310jjmb.fsf@twilight.int.mornfall.net.>
Message-ID: <20100630213554.GU23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 30, 2010 at 11:28:12PM +0200, Peter Rockai wrote:
> Ah, this is not mentioned in the patch since it was not changed. The
> missing piece of the puzzle is this:
> 
>    1567                 if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
>    1568                         _remove_missing_empty_pv(lv->vg, lp->failed_pvs);
                                                                  ^^^^
So the code - what? - generates one list of PVs then uses another?!

Ack.

Alasdair


