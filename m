From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 4 Jan 2011 23:59:08 +0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c tools ...
In-Reply-To: <20101222153643.20331.qmail@sourceware.org>
References: <20101222153643.20331.qmail@sourceware.org>
Message-ID: <20110104235908.GC10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 03:36:43PM -0000, zkabelac at sourceware.org wrote:
> 	Add backtraces for backup and backup_remove fail paths
 
> +	if (!backup_remove(vg->cmd, vg->name))
> +		stack;
  
We also have:

int backup_remove(struct cmd_context *cmd, const char *vg_name)
{
...
        /*
         * Let this fail silently.
         */
        unlink(path);
        return 1;
}

I suggest you change that into a log_sys_debug() now rather than a void cast.
(No harm logging ENOENT and could be useful to know that sometimes.)

Alasdair


