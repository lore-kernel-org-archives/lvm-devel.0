From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 08 Jul 2010 20:18:31 +0200
Subject: [PATCH] clvmd should create its own pid file
In-Reply-To: <20100708145916.GT22664@agk-dp.fab.redhat.com>
References: <4C35CCEB.4020300@redhat.com>
	<20100708145916.GT22664@agk-dp.fab.redhat.com>
Message-ID: <4C361677.2030904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/08/2010 04:59 PM, Alasdair G Kergon wrote:
> Does this work OK with clvmd -S?

Yes. It appears to be working fine.

> Should we have FD_CLOEXEC ?
>
> (See pidfile.c in multipathd.)

I don't have any special preference. I noticed that the pid file 
implementations in other daemons (within lvm2) don't use it nor unlink 
the pid file on exit.

> Also, let's make it library code rather than copying it from cmirrord.

Works for me.

I am going to make it a lib call and cleanup both cmirrord/dmeventd/clvmd.

Do you have anything against atexit() handler? That's what we use in 
cluster daemons to unlink the pid files.

Cheers
Fabio


