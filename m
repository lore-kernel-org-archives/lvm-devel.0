From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 01:02:31 +0000
Subject: [PATCH 10/23] Fix memory leak of dev_filter on error path
In-Reply-To: <4D10E22B.3020009@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<f5f89efaed261f30fa5ce4b21aee5d567ca1f3c0.1292945707.git.zkabelac@redhat.com>
	<4D10E22B.3020009@redhat.com>
Message-ID: <20110105010231.GK10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 06:21:47PM +0100, Milan Broz wrote:
> Why not move it to the caller instead - the same like previous two?

Oh, consistency, yes please!

Alasdair


