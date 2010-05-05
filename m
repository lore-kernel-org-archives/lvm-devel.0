From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 May 2010 19:00:08 +0100
Subject: [PATCH] Provide a new --sysinit switch for vgchange and lvchange
In-Reply-To: <4BE16BD5.7030402@redhat.com>
References: <4BE16BD5.7030402@redhat.com>
Message-ID: <20100505180008.GD27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 05, 2010 at 03:00:05PM +0200, Peter Rajnoha wrote:
> -	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
> -		suppress_messages = 1;

Can't remove the getenv!

Also add a comment somewhere describing exactly what --sysinit is equivalent to.

Update the man pages to say the argument sets options appropriate for
initscripts and should only be used from there.  

Alasdair


