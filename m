From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 22 Nov 2007 02:42:10 +0000
Subject: [PATCH] Cleanup partial failure of activation
In-Reply-To: <4744E68C.3050601@ce.jp.nec.com>
References: <47445603.1000602@ce.jp.nec.com>
	<20071121224217.GQ22843@agk.fab.redhat.com>
	<4744E68C.3050601@ce.jp.nec.com>
Message-ID: <20071122024210.GS22843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 21, 2007 at 09:16:44PM -0500, Jun'ichi Nomura wrote:
> Currently, mirror, snapshot and pvmove are only stacking-type LVs.
> They don't allow partial activation.
> # Is this assumption correct?
> 
> If the above is correct, the tree is either activated or deactivated
> as a whole. So, if activation failed, deactivating the LV would
> return it to the state before activation is called.
 
Have all the code paths been audited?

The general "self-correcting" philosophy throughout the activation code is to
ensure the LV is in a known final state when they return success, and to cope
with a broad range of initial states.

This patch would represent a change in the semantics of the functions,
reducing the range of initial states handled sensibly.

Look at the lv_resume code path, for example.  Wouldn't it be more sensible to
revert to the previous table on failure than to attempt to remove the device?

I don't believe this problem can be resolved with such a tiny patch.

There are two approaches:
  1) have proper reversion code inside the guts of the library activation code
  2) let the caller, which possesses knowledge about the *sequence* of steps
making up the operation, handle reversion sensibly

I expect a mixture of the two - mostly (2) in the places we need it now (quick
and easy and a few cases already done), but eventually more use of (1) which is
technically a better solution (but harder).

Alasdair
-- 
agk at redhat.com


