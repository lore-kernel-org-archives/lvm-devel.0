From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 24 Oct 2006 16:27:24 +0100
Subject: LVM2 ./WHATS_NEW man/lvchange.8 tools/args.h t ...
In-Reply-To: <cb25965068fcc60d0dc73882c222e4a1@redhat.com>
References: <20061023230356.28539.qmail@sourceware.org>
	<453D5BA4.9000107@ce.jp.nec.com>
	<cb25965068fcc60d0dc73882c222e4a1@redhat.com>
Message-ID: <20061024152724.GA29513@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> >This "active = 1" should be set only if info.exists is true,

Yes

> I also think we lost the ability to distinguish between clustered 
> (active = -1) and active (active = 1).
 
Correct - there's no mechanism yet to distinguish between those cases: if
it's not active locally, we don't reactivate.

Alasdair
-- 
agk at redhat.com


