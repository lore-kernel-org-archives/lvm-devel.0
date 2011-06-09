From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 9 Jun 2011 15:32:06 +0100
Subject: [PATCH] Workaround for kernel 3.0 & uname
In-Reply-To: <1307214215-13987-1-git-send-email-mbroz@redhat.com>
References: <1307214215-13987-1-git-send-email-mbroz@redhat.com>
Message-ID: <20110609143206.GD13427@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Jun 04, 2011 at 09:03:35PM +0200, Milan Broz wrote:
> +		_kernel_release = 0;

Let's move those (noops) out of the way to the initialisation,
  static int _kernel_major = 0;

Then the if test can be simplified:
	/* Kernels with a major number of 2 always had 3 parts. */
	if (parts < 1 || (_kernel_major < 3 && parts < 3))

>  		log_error("Could not determine kernel version used.");
>  		return 0;
>  	}

Alasdair


