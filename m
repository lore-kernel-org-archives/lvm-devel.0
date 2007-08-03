From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 03 Aug 2007 13:18:49 -0400
Subject: [LVM2 PATCH 1/2] lvrename: factor out core routine
In-Reply-To: <46AA1020.8060600@ce.jp.nec.com>
References: <46AA1020.8060600@ce.jp.nec.com>
Message-ID: <1186161529.4398.9.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2007-07-27 at 11:32 -0400, Jun'ichi Nomura wrote:
> Hi,
> 
> This patch factors out core renaming function from lvrename()
> as a preparation for mirrored LV renaming.
> 
> No functional change except for the order of the validity check.
> It used to be:
>   - check if the new name is not yet used in the VG
>   - check if the old name really exists in the VG
> This order is now reversed.
> As the VG is locked, it should have no problem.
> 
> Also the following cleanups are included:
>   - converting "stack; return 0;" to "return_0"
>   - removing duplicated mirrored LV check
>     (there were 2 identical checks)
> 
> Applicable to the CVS head.
> 

This looks fine and is a nice cleanup.  Will probably move the new
function out of the tools dir though.


