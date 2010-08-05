From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Thu, 5 Aug 2010 18:46:22 -0400
Subject: [PATCH] Specified PVs being ignored when performing mirror split (repost)
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865E8@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/05/10 18:23, Jonathan Brassow wrote:
...
> Fix for bug 619221 - log device splitting regression
> 
> An incorrect fix an annoyance has caused a regression.  The offending
> check-in was: 
> http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c?cvsroot=lvm2&f=h#rev1.140
> 
> This check-in caused any PVs specified on the command line to be
> ignored when performing a mirror split.
> 
> This patch reverses the aforementioned check-in (solving the regressions)
> and posits a new solution to the list reversal problem.  The original
> problem was that we would always take the lowest mimage LVs from a mirror
> when performing a split, but what we really want is to take the highest
> mimage LVs.  This patch accomplishes that by working through the list in
> reverse order - choosing the higher numbered mimages first.  (This also
> reduces the amount of processing necessary.)

Thank you for updating the patch.

Reviewed-by: Takahiro Yasui <takahiro.yasui@hds.com>

Thanks,
Taka


