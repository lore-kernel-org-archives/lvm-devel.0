From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 May 2010 18:36:01 +0100
Subject: [PATCH] Provide a new --sysinit switch for vgchange and lvchange
In-Reply-To: <4BE18115.1030200@redhat.com>
References: <4BE16BD5.7030402@redhat.com>
	<878w7y1mtu.fsf@twilight.int.mornfall.net.>
	<4BE18115.1030200@redhat.com>
Message-ID: <20100505173601.GC27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 05, 2010 at 04:30:45PM +0200, Peter Rajnoha wrote:
> Well, both dracut and initscripts should have the same options/switches
> used I think, including monitoring. Dracut already uses --ignoremonitoring
> and rc.sysinit is about to change to include this one...
 
If we do find they need to differ, go for --initrd to save having to update
the dracut package every time.

Alasdair


