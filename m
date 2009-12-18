From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 18 Dec 2009 11:10:33 -0600
Subject: [PATCH 2 of 4] Handle transient secondary mirror leg failures
In-Reply-To: <1e369d480df09d0fac6c.1260695924@localhost>
References: <patchbomb.1260695922@localhost>
	<1e369d480df09d0fac6c.1260695924@localhost>
Message-ID: <178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

hmmm, I wonder how well this is going to work.

1) I've seen code ('dm_task_suppress_identical_reload') that  
suppresses table reloads if the tables are identical - will that  
obstruct what you are trying to do here?

2) If you don't get a new table loaded, it will behave as a suspend/ 
resume only.  Recent code changes in dm-raid1.c are causing  
'log_failure' and 'leg_failure' to not be reset in those cases.  IOW,  
all these steps could be for nothing.  :(

3) How does this work in a cluster?  dmsetup is not cluster-aware.  If  
you don't go through the LVM commands (I recognize the additional  
pain), none of this will be coordinated.

  brassow


On Dec 13, 2009, at 3:18 AM, Malahal Naineni wrote:

> +	/* FIXME: should be running an LVM command that is pinned.
> +	 * dmsetup command may not be pinned in memory all the time.
> +	 * "lvchange --refresh vg/lv" only works if there are no device
> +	 * failures while it is running. Otherwise, the failed device
> +	 * is replaced with "error" target which is not what we want.
> +	 */
> +	snprintf(cmd_str, CMD_SIZE, "dmsetup suspend --noflush %s-%s", vg,  
> lv);
> +	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
> +	r = system(cmd_str);
> +
> +	snprintf(cmd_str, CMD_SIZE, "dmsetup table %s-%s | dmsetup load "
> +			"%s-%s", vg, lv, vg, lv);
> +	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
> +	r |= system(cmd_str);
> +
> +	snprintf(cmd_str, CMD_SIZE, "dmsetup resume %s-%s", vg, lv);
> +	syslog(LOG_NOTICE, "Running command: %s", cmd_str);
> +	r |= system(cmd_str);


