From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 21 Nov 2007 22:42:17 +0000
Subject: [PATCH] Cleanup partial failure of activation
In-Reply-To: <47445603.1000602@ce.jp.nec.com>
References: <47445603.1000602@ce.jp.nec.com>
Message-ID: <20071121224217.GQ22843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 21, 2007 at 11:00:03AM -0500, Jun'ichi Nomura wrote:
> If activate_lv() fails, callers won't call deactivate_lv().
> However, activate_lv() may succeeded activation partially.
 
> Attached patch deactivates a partially activated LV so that
> callers of activate_lv() don't need to care about partial failure.

But could the deactivation call deactivate something that was active *before*
it was called?  Are you sure this will always accurately return things to the
state they were in prior to the failed call, and not deactivate something that
was previously active?

Alasdair
-- 
agk at redhat.com


