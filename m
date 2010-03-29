From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Mar 2010 16:38:12 +0200
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
In-Reply-To: <20100326154537.2860.qmail@sourceware.org>
	(snitzer@sourceware.org's message of "26 Mar 2010 15:45:37 -0000")
References: <20100326154537.2860.qmail@sourceware.org>
Message-ID: <871vf3b3cb.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

snitzer at sourceware.org writes:
> Modified files:
> 	.              : WHATS_NEW 
> 	daemons/clvmd  : clvmd-singlenode.c 
>
> Log message:
> 	Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
Interesting. Is this because /dev/null is always "ready" for reading? Is
there a less complicated workaround for that problem?

Yours,
   Petr.


