From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 13 Jul 2009 21:02:11 +0100
Subject: [PATCH 2/5] Add default cmd->cmd_line initialization for liblvm lvm_create().
In-Reply-To: <1247458358-24590-3-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-2-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-3-git-send-email-dwysocha@redhat.com>
Message-ID: <20090713200211.GB31951@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 13, 2009 at 12:12:35AM -0400, Dave Wysochanski wrote:
> +	cmd->cmd_line = (char *)"liblvm";

Don't see why that isn't const - I've changed it.

Alasdair


