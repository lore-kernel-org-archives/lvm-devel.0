From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 7 Jul 2010 19:19:42 +0100
Subject: [PATCH 5/6] Better alligned debug message - memlock
In-Reply-To: <7279c49cc495586ad959774a958cc00241c8586a.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
	<7279c49cc495586ad959774a958cc00241c8586a.1278505444.git.zkabelac@redhat.com>
Message-ID: <20100707181942.GD22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ack.

On Wed, Jul 07, 2010 at 02:29:35PM +0200, Zdenek Kabelac wrote:
> -	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
> -		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
> +	log_debug("m%slock %10ldKiB %12lx - %12lx %c%c%c%c%s",
> +		  (lock == LVM_MLOCK) ? "" : "un",

?!

Alasdair


