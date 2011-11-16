From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 16 Nov 2011 13:07:34 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <20111116105953.GD3294@agk-dp.fab.redhat.com>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
Message-ID: <20111116130734.GE3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 16, 2011 at 10:59:53AM +0000, Alasdair G Kergon wrote:
> - a minimum size needs to be passed into lvextend (to avoid repeated calls if
> there is rapid growth or if snapshot_autoextend_threshold was set too small)
> - the trigger logic needs improving and needs to take account of the actual
> space used as well as the percentage (and set the mininum extension size
> appropriately)

So this line of thought leads to lvextend --use-polices calculating:

   (new_size = old_size + amount_to_extend_by) > 
	old_size_in_use + ((100 + autoextend_percent) - autoextend_threshold) / (100+autoextend_percent) * (old_size + amount_to_extend_by)

IOW we scale the parameters based on the amount currently in use.

For example:

    snapshot_autoextend_threshold = 70
    snapshot_autoextend_percent = 20

Means if it was 70% full, the percentage of free space after extension would
be:

  ((100 + 20) - 70) / (100 + 20) = ((100 + autoextend_percent) - autoextend_threshold) / (100+autoextend_percent)

If it's more than 70% full, we extend it so that we obtain that same percentage
of free space.

As the check interval is 5%, we impose a minimum autoextend_percent of 6% of
old size (so > 5% of new size)

The plugin keeps track of the current size (from the status line) and if
the size increased it discovers this the next time it reads the status line
and resets its check at that point.

Separately, the plugin should perhaps record the maximum amount of growth
during a check interval and use that as a minimum amount of extension, if the
actual extension would otherwise be less.

Alasdair


