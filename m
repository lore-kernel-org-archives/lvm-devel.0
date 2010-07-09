From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Jul 2010 14:09:51 +0100
Subject: [PATCH] pid files cleanup
In-Reply-To: <4C36E604.6090106@redhat.com>
References: <4C36E604.6090106@redhat.com>
Message-ID: <20100709130950.GX22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 09, 2010 at 11:04:04AM +0200, Fabio M. Di Nitto wrote:
> +	/* Create pidfile */
> +	if (create_lockfile(CLVMD_PIDFILE) < 0) {

For functions in lvm, our convention is to return 1 on success or 0 on failure.

> +++ b/daemons/cmirrord/Makefile.in

> +LVMLIBS = $(LVMINTERNAL_LIBS)

Hmmm.

We still have already:
  cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a

- Does the definition above mean this bit can come out?

> +++ b/lib/misc/lvm-file.c
> +	return 0;

return 1;

> +	return -errno;

return 0;

(This function already handled/reported errno appropriately.)

Looks good - ack.

Alasdair



