From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Jul 2010 17:16:56 +0100
Subject: [PATCH] check for running cluster log daemon, not just log module
In-Reply-To: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
References: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
Message-ID: <20100716161656.GA6506@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 16, 2010 at 09:39:47AM -0500, Jon Brassow wrote:
> +int dm_daemon_is_running(const char* lockfile)

> +	/* Should we also read and check pid? */

Yes - check /proc/<pid>/fd/*  if available?

(cf. _get_filename in tools/lvmcmdline.c)

Alasdair


