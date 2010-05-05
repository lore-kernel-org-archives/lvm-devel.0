From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 May 2010 21:49:44 +0100
Subject: [PATCH 2/5] Add lvmcache function to lookup a vgname from a pvid.
In-Reply-To: <1272470142-13843-3-git-send-email-dwysocha@redhat.com>
References: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
	<1272470142-13843-2-git-send-email-dwysocha@redhat.com>
	<1272470142-13843-3-git-send-email-dwysocha@redhat.com>
Message-ID: <20100505204944.GI27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 11:55:39AM -0400, Dave Wysochanski wrote:
> +char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)

> +	if (!(vgname = dm_pool_alloc(cmd->mem, NAME_LEN+1))) {
> +		log_errno(ENOMEM, "vgname allocation failed");
> +		return NULL;
> +	}
> +	strncpy(vgname, info->vginfo->vgname, NAME_LEN);
> +	return vgname;


dm_pool_strdup()

Alasdair


