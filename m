From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 26 Nov 2007 20:51:37 -0500
Subject: [PATCH] Cleanup partial failure of activation
In-Reply-To: <20071122024210.GS22843@agk.fab.redhat.com>
References: <47445603.1000602@ce.jp.nec.com>	<20071121224217.GQ22843@agk.fab.redhat.com>	<4744E68C.3050601@ce.jp.nec.com>
	<20071122024210.GS22843@agk.fab.redhat.com>
Message-ID: <474B7829.5090708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> I don't believe this problem can be resolved with such a tiny patch.
> 
> There are two approaches:
>   1) have proper reversion code inside the guts of the library activation code
>   2) let the caller, which possesses knowledge about the *sequence* of steps
> making up the operation, handle reversion sensibly
> 
> I expect a mixture of the two - mostly (2) in the places we need it now (quick
> and easy and a few cases already done), but eventually more use of (1) which is
> technically a better solution (but harder).

Thanks for the explanation.
I see the point.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


