From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 15:02:37 +0100
Subject: [PATCH 1/5] Check type is not NULL before access
In-Reply-To: <fa6078b0a1e1a7eba4dc339f425715eada3ad826.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<fa6078b0a1e1a7eba4dc339f425715eada3ad826.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026140237.GM29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:22PM +0200, Zdenek Kabelac wrote:
> Check type before dereference and report internal error in case
> it's undefined and return from the function.
 
> +			if (!type) {
> +				log_error(INTERNAL_ERROR "Type is not defined.");
> +				return;
> +			}

Is this one really an internal library error?

Can it be triggered if someone usees the API incorrectly?

If so, it should be treated like validation.

Alasdair


