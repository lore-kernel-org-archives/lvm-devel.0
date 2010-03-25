From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 25 Mar 2010 17:51:01 -0400
Subject: [PATCH v2] improve activation monitoring option processing
In-Reply-To: <20100324154359.GA845@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
	<4BA9D905.9090107@redhat.com> <20100324130736.GA19258@redhat.com>
	<20100324154359.GA845@redhat.com>
Message-ID: <20100325215100.GA27929@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 24 2010 at 11:44am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:
>
> Update _process_config() to establish '_dmeventd_monitor' global based
> on lvm.conf.  This allows clvmd's calls to create_toolcontext() and
> refresh_toolcontext() to (re)establish dmeventd monitoring based on
> lvm.conf (rather than always using DEFAULT_DMEVENTD_MONITOR).
> 
> clvmd's do_lock_lv() already properly controls dmeventd monitoring based
> on LCK_DMEVENTD_MONITOR_MODE in lock_flags -- which currently gets set
> based on the '_dmeventd_monitor' global.

Actually, it looks like we never offered/tested the ability to disable
monitoring across the cluster.

clvmd's do_lock_lv() will _not_ call init_dmeventd_monitor(0) unless
dmeventd monitoring is disabled (which will currently never happen
because '_dmeventd_monitor' defaults to enabled; the _process_config
patch, described in 1st paragraph above, will address that).

Also, dmeventd_monitor_mode() does not return a binary value.  That is
the low hanging fruit (I'm working on a patch to appropriately replace
dmeventd_monitor_mode() calls expecting a binary return with 
is_dmeventd_monitor_enabled()).

I think those 2 patches fix the ability to disable monitoring with
clvmd.  Tracing seems to show it works.  Does this sound reasonable?

I'll post the patches shortly.
Mike


p.s. overview of current cluster dmeventd_monitor propagation:

static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;

int dmeventd_monitor_mode(void)
{
        return _dmeventd_monitor;
}

lib/locking/cluster_locking.c:_lock_for_cluster() {
...
        if (dmeventd_monitor_mode())
                args[1] |= LCK_DMEVENTD_MONITOR_MODE;
}

daemons/clvmd/lvm-functions.c:do_lock_lv() {
...
        if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
                init_dmeventd_monitor(0);

        ...

        if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
                init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
}


