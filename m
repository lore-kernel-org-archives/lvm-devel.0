From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 27 Jul 2015 15:51:05 +0100
Subject: master - clvmd: Fix freeze if client dies holding locks.
In-Reply-To: <877fplwtfl.fsf@lant.ki.iif.hu>
References: <20150723222626.8A47A61043@fedorahosted.org>
	<877fplwtfl.fsf@lant.ki.iif.hu>
Message-ID: <20150727145105.GA30959@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 27, 2015 at 04:45:18PM +0200, Ferenc Wagner wrote:
> Just an outsider question: why do you use stderr here instead of some
> generic logging function?  If clvmd is run as a daemon, stderr is
> /dev/null, thus these messages are lost.

Because I used a quick cut-and-paste.  Yes, syslog would be better...

Alasdair


