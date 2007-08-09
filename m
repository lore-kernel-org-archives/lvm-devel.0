From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 09 Aug 2007 18:21:19 -0400
Subject: [LVM2 PATCH] Fix 'lvconvert -s' to work again
In-Reply-To: <46BB5463.50708@ce.jp.nec.com>
References: <46BB5463.50708@ce.jp.nec.com>
Message-ID: <1186698079.4531.18.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2007-08-09 at 13:52 -0400, Jun'ichi Nomura wrote:
> Hi,
> 
> In current CVS head, 'lvconvert -s' doesn't work.
>  # lvconvert -s testvg/lvol0 testvg/lvol1
>  --snapshots argument cannot be mixed with --mirrors or --log
>  lvconvert: Change logical volume layout
> 
> This is due to the lvconvert parameter check uses
> 'count' variable uninitialized for non-mirror case.
>         int count;
> ...
>         if (arg_count(cmd, log_ARG) || arg_count(cmd, mirrors_ARG))
>                 count = 1;
>         count += arg_count(cmd, snapshot_ARG);
> 
> While the code around the _read_params() could be tidied up
> some more, I hope this fix is included for now.
> 

Looks like an obvious initialization bug.


