From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:16:44 -0500
Subject: [PATCH] Cleanup partial failure of activation
In-Reply-To: <20071121224217.GQ22843@agk.fab.redhat.com>
References: <47445603.1000602@ce.jp.nec.com>
	<20071121224217.GQ22843@agk.fab.redhat.com>
Message-ID: <4744E68C.3050601@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Wed, Nov 21, 2007 at 11:00:03AM -0500, Jun'ichi Nomura wrote:
>> If activate_lv() fails, callers won't call deactivate_lv().
>> However, activate_lv() may succeeded activation partially.
>  
>> Attached patch deactivates a partially activated LV so that
>> callers of activate_lv() don't need to care about partial failure.
> 
> But could the deactivation call deactivate something that was active *before*
> it was called?  Are you sure this will always accurately return things to the
> state they were in prior to the failed call, and not deactivate something that
> was previously active?

Currently, mirror, snapshot and pvmove are only stacking-type LVs.
They don't allow partial activation.
# Is this assumption correct?

If the above is correct, the tree is either activated or deactivated
as a whole. So, if activation failed, deactivating the LV would
return it to the state before activation is called.


And if, in future, partial activation is allowed, I think the
current activation implementation can't handle this case anyway:
  1. activate partial tree
  2. activate other tree on top of the partial tree
  ..
  3. deactivate the other tree
  <but don't want to deactivate the partial tree>

I'm not whether there actually is such a use case.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


