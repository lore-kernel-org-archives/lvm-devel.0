From: Milan Broz <mbroz@redhat.com>
Date: Thu, 26 Aug 2010 10:10:44 +0200
Subject: [PATCH] Do not scan snapshot origin for labels while 'ignore_suspended_devices()' is set
In-Reply-To: <1282747088.10709.1.camel@hydrogen.msp.redhat.com>
References: <1282747088.10709.1.camel@hydrogen.msp.redhat.com>
Message-ID: <4C762184.9000307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/25/2010 04:38 PM, Jonathan Brassow wrote:

> +		 * Snapshot origin could be sitting on top of a mirror which
> +		 * could be blocking I/O.  Skip snapshot origins entirely for
> +		 * now.
> +		 *
> +		 * FIXME: rather than skipping origin, check if mirror is
> +		 * underneath and if the mirror is blocking I/O.
> +		 */
> +		if (target_type && !strcmp(target_type, "snapshot-origin") &&
> +		    ignore_suspended_devices()) {
> +			log_debug("%s: Snapshot-origin device %s not usable.",
> +				  dev_name(dev), name);
> +			goto out;

Well, if no one can find situation where this breaks some existing config,
let's try that - we need something working in this release.

The code need rewrite here anyway... ack from me for now.

Milan


