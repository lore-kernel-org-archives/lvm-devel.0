From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 8 Jul 2010 19:25:19 +0100
Subject: [PATCH] clvmd should create its own pid file
In-Reply-To: <4C361677.2030904@redhat.com>
References: <4C35CCEB.4020300@redhat.com>
	<20100708145916.GT22664@agk-dp.fab.redhat.com>
	<4C361677.2030904@redhat.com>
Message-ID: <20100708182519.GU22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 08, 2010 at 08:18:31PM +0200, Fabio M. Di Nitto wrote:
> Do you have anything against atexit() handler? That's what we use in  
> cluster daemons to unlink the pid files.

I can't think of any problems with that in the daemon context.

Alasdair


