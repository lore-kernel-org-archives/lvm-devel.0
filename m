From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 14 Mar 2007 20:10:42 +0000
Subject: Re: striped LVM1 volumes
In-Reply-To: <20070313140738.GH29428@agk.surrey.redhat.com>
References: <45F6702F.4090803@redhat.com>
	<20070313140738.GH29428@agk.surrey.redhat.com>
Message-ID: <20070314201042.GO29428@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 13, 2007 at 02:07:38PM +0000, Alasdair G Kergon wrote:
> I don't want to remove checks like that.
> Two possibilities:
>   the check is being performed wrongly and needs fixing 
>     - unlikely since it works with LVM2 metadata
>   the LVM1 format metadata isn't being set up correctly
>     - fix it in the format lvm1 code

Well, as expected, it is pretty clear that the bug is
in the lvm1 format code.

Easily reproduced - just create a format1 striped LV of more than 2
extents using lvm2 and find that lvm2 cannot read it back!

There's a factor of #stripes missing from the code that sets the
segment size when building up the segments, and the algorithm used to
detect the size of a segment is also bogus.  (It seems to be trying to
handle an extended lvm1 format we once had that supported lvm2-like
striping extensions.)
 
Alasdair
-- 
agk at redhat.com


