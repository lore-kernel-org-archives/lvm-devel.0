From: Petr Rockai <prockai@redhat.com>
Date: Tue, 26 Oct 2010 16:05:31 +0200
Subject: [PATCH 0/5] Fix NULL dereference
In-Reply-To: <20101026135759.GL29400@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Tue, 26 Oct 2010 14:57:59 +0100")
References: <cover.1288097372.git.zkabelac@redhat.com>
	<20101026135759.GL29400@agk-dp.fab.redhat.com>
Message-ID: <87vd4p1238.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> Well the ones I've looked at here seem to be more about dealing with
> shortcomings in the static analysis code rather than fixing real bugs.
talking about static analysis. We used to have access to Coverity
Prevent reports about LVM, right? If I try to go to scan.coverity.com
and click "sign in" near the LVM2 project, I get a connection
refused... the link is sending me to

http://scan2.coverity.com:7494/

Alasdair, I suppose you are the Coverity's "contact" -- could you maybe
ask what's up with that, and maybe get me an account so I can see the
report as well? I reckon it could be useful...

Yours,
   Petr.


