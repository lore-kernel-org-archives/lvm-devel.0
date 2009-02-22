From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 22 Feb 2009 23:11:11 +0000
Subject: [PATCH 08/12] Add lvm_errno(), lvm_strerror, lvm_vg_mode.
In-Reply-To: <1234467041-21522-9-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
Message-ID: <20090222231111.GF15443@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 12, 2009 at 02:30:37PM -0500, Dave Wysochanski wrote:
> Create struct lib_context to store lvm_errno field as well as cmd_context.
> Create error APIs - lvm_errno, lvm_strerror.

As we discussed on the call last week, let't see first if we can get an error
number and messages integrated into the existing log_error() reporting
mechanism.

> +int lvm_errno(lvm_handle_t libh)
> +{
> +	return libh->lvm_errno;
> +}

Eventually, yes, but as we discussed last week, a static global variable
is likely to be the quickest way to get this working until libh is
available at all levels of the stack.

> +char *lvm_strerror(lvm_handle_t libh)
> +{
> +	return strerror(libh->lvm_errno);
> +}

No need for a wrapper around strerror - call it directly!

What we should do though is store the specific error messages issued
and provide a way to return them all in one go.
Again, this is likely to be a simple multi-line string for now, that gets
cleared on each new library call.

Alasdair
-- 
agk at redhat.com


