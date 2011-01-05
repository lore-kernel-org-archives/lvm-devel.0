From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:44:04 +0000
Subject: [PATCH 02/23] Remove dead assignment
In-Reply-To: <5ad58b8832a98a0d53fc939b89dbac3940521747.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<5ad58b8832a98a0d53fc939b89dbac3940521747.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105024404.GX10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:34PM +0100, Zdenek Kabelac wrote:
> Variables 'lv_total' and 'lv_capasity_total' are unused.

Ack.

Probably LVM1 used to display these, but we never bothered to
reimplement lvscan fully as there are better commands to use
instead.

Alasdair


