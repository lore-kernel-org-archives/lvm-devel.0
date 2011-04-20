From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 20 Apr 2011 22:36:30 +0100
Subject: [PATCH 1/1] Fix use of vgname and vgid
In-Reply-To: <846e0fef3eefcc011e9ff4b70d9a8be007d475b1.1303302985.git.zkabelac@redhat.com>
References: <cover.1303302985.git.zkabelac@redhat.com>
	<846e0fef3eefcc011e9ff4b70d9a8be007d475b1.1303302985.git.zkabelac@redhat.com>
Message-ID: <20110420213630.GG3439@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 20, 2011 at 02:37:07PM +0200, Zdenek Kabelac wrote:
> As get_pv_from_vg_by_id() may call lvmcache_label_scan() keep the vgname
> and vgid copied localy on the stack as vginfo may dissapear and code was
> then accessing garbage in memory.
 
Currently, vginfo structs must not be held across calls to vg_read (or used as
parameters).

Have you audited the code to check there are no similar problems elsewhere?

I'm not too happy with the workaround in this patch, but it'll do for now,
as a proper fix would take quite a bit longer to develop.

> +		/*
> +		 * get_pv_from_vg_by_id() may lead to
> +		 * lvmcache_label_scan() so it can drop
> +		 * vginfo and all referenced data.
> +		 */

Document the restriction I mentioned above at the vg_read* entry point.

Alasdair


