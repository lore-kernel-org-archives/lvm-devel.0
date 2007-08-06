From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 6 Aug 2007 20:33:02 +0100
Subject: const correctness, first cut
In-Reply-To: <87odhkd741.fsf@rho.meyering.net>
References: <87odhkd741.fsf@rho.meyering.net>
Message-ID: <20070806193302.GK2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 06, 2007 at 05:18:22PM +0200, Jim Meyering wrote:
> I find it easier to read code that uses "const" whenever possible.

All looks sane, thanks.

>  		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
> -				      &lvdisplay_full);
> +				      (process_single_lv_fn_t)lvdisplay_full);

Is there a nice way to avoid those casts?
  
Alasdair
-- 
agk at redhat.com


