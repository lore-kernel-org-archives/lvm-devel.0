From: Jim Meyering <jim@meyering.net>
Date: Wed, 16 Jan 2008 21:47:26 +0100
Subject: Re: [PATCH] Fix 'make check' to use dmsetup built in DMDIR
In-Reply-To: <478E6AFB.30007@ce.jp.nec.com> (Jun'ichi Nomura's message of
	"Wed, 16 Jan 2008 15:37:15 -0500")
References: <478E6AFB.30007@ce.jp.nec.com>
Message-ID: <871w8ho5up.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> wrote:
> If DMDIR is specified in configuration script,
> 'make check' should use it to check DM_DEV_DIR support.
...
> Index: LVM2.work/test/Makefile.in
...
> +	test -n "@DMDIR@" && ln -s "@DMDIR@/dmsetup/dmsetup" bin/dmsetup

Looks good.


