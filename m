From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 May 2010 21:40:21 +0100
Subject: [PATCH 1/5] Add pvid_from_devname() lvmcache function.
In-Reply-To: <1272470142-13843-2-git-send-email-dwysocha@redhat.com>
References: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
	<1272470142-13843-2-git-send-email-dwysocha@redhat.com>
Message-ID: <20100505204021.GH27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 11:55:38AM -0400, Dave Wysochanski wrote:
> Add supporting function for mappings from devname -> pvid -> vgname.
 
> +++ b/lib/cache/lvmcache.c
> @@ -747,6 +747,27 @@ struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,

> +	info = (struct lvmcache_info *) label->info;

Unused?

Alasdair


