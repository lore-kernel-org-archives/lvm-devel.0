From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 14:52:46 +0100
Subject: [PATCH 3/5] Ensure first is not NULL before dereference
In-Reply-To: <f89a9f77dcb9846146ebbe014ac9958ce76c9b32.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<f89a9f77dcb9846146ebbe014ac9958ce76c9b32.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026135246.GK29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:24PM +0200, Zdenek Kabelac wrote:
> +	if (!first) {
> +		log_error(INTERNAL_ERROR "Unexpected empty PV list.");
> +		return 0;

We already have a 'list empty' check prior to calling this function.

I think it's more readable with the check in the caller and the
comment inside the function, instead of moving the check inside
the function.

No need to change this that I can see.

What is the code path that could trigger this condition?
(It's a static function only called from one place.)

What am I missing?

Alasdair


