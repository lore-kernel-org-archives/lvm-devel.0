From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 02 Dec 2009 19:00:21 -0500
Subject: [PATCH 2 of 2] [RFC] handle a temporary secondary mirror device failure
In-Reply-To: <a0324c61e9fc527d6a9d.1259576550@localhost>
References: <patchbomb.1259576548@localhost>
	<a0324c61e9fc527d6a9d.1259576550@localhost>
Message-ID: <4B16FF95.6010603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/30/09 05:22, Malahal Naineni wrote:
> If "retry" policy is selected, then the mirror DSO uses "dmsetup"
> command to restart a resync. Right now, it is done immediately but we
> should do it after a configured time. Also, this is done endlessly but
> should be done only few configured times.

It sounds good to me. This feature would work in a variety of
environments by adding configurable parameter as you mentioned.

> Calling 'lvchange --refresh' to re-integrate the secondary mirror upon a
> leg failure works if there are no device failures while the "lvchange"
> is running.  Otherwise, the failed device is replaced with "error"
> target which is not what we want. For now, this patch calls "dmsetup",
> but should be replaced with a suitable "LVM" command.

> +	snprintf(cmd_str, CMD_SIZE, "dmsetup suspend %s-%s", vg, lv);
> +	syslog(LOG_ERR, "Running command: %s", cmd_str);

We need to re-queue blocked I/Os instead of finishing them by -EIO.
I think that "--noflush" option is necessary for "dmsetup suspend."

Thanks,
Taka


