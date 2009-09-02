From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Sep 2009 14:45:53 +0100
Subject: [PATCH 8/9] Refactor vgsplit - reorder _vgsplit_from and _vgsplit_to based on flag.
In-Reply-To: <1250198823-11591-9-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-3-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-4-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-5-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-6-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-7-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-8-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-9-git-send-email-dwysocha@redhat.com>
Message-ID: <20090902134553.GO1655@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2009 at 05:27:02PM -0400, Dave Wysochanski wrote:
> Should be no functional change but there is one bug.  If we open the
> destination first, we cannot know the 'fmt'.  So in this case we rely on the
> user specifying the value in the --metadatatype variable if the destination
> is a new VG.  

That's OK because for most people now, it's always lvm2 format and the default
is correct, and everyone else quickly learns they need to use that option
sometimes.

> +		/* FIXME: in this case we don't know the vg_from->fid->fmt */
> +		if (!arg_count(cmd, metadatatype_ARG))
> +			log_warn("Unable to set format based on "
> +				 "source VG format");

As elsewhere in the code, delete those lines and just use cmd->fmt directly.

Later, once you *do* know the correct format, verify it matches and if it
doesn't, abort with an error telling people to use that option.

Alasdair


