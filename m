From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 Mar 2012 11:33:51 +0000
Subject: [PATCH] Remove fifos on dmeventd shutdown
In-Reply-To: <4F60A9CB.5050000@redhat.com>
References: <4F60A9CB.5050000@redhat.com>
Message-ID: <20120315113351.GC6774@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 14, 2012 at 03:23:07PM +0100, Peter Rajnoha wrote:
>  	/* Set the rest of the signals to cause '_exit_now' to be set */
> +	signal(SIGTERM, &_exit_handler);
>  	signal(SIGINT, &_exit_handler);
>  	signal(SIGHUP, &_exit_handler);
>  	signal(SIGQUIT, &_exit_handler);

I'd prefer it if we used sigaction() directly like we do elsewhere in lvm
so we can specify precisely the behaviour we intend.

signal() has a bad history and, as the man page states, should be avoided.
 
Alasdair


