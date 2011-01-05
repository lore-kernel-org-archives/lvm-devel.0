From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:15:37 +0000
Subject: [PATCH 19/23] Warning - dead code problem elimination
In-Reply-To: <87mxny2lqm.fsf@twilight.int.mornfall.net.>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<2e3abc21f31d172f75c96f74e483dfbee6d9dd07.1292945707.git.zkabelac@redhat.com>
	<4D10EA2E.8080404@redhat.com>
	<87mxny2lqm.fsf@twilight.int.mornfall.net.>
Message-ID: <20110105021537.GS10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > I think you should return DM_WAIT_RETRY if info fails then (so the code _was_ correct)?

> Jeez, I wish I knew! I don't think I wrote this code. Anyway, it would
> make sense to add ret = DM_WAIT_RETRY in the else branch (i.e. get_info
> fails). Not that this is likely to ever trigger...

Do that then.

Alasdair


