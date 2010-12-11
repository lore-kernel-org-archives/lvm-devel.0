From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 11 Dec 2010 00:07:20 +0000
Subject: [PATCH] Scan also special metadata areas (like metadata/dirs) in fmt_from_vgname
In-Reply-To: <20101130044337.GA18385@agk-dp.fab.redhat.com>
References: <4CEFD75D.6060509@redhat.com>
	<20101130044337.GA18385@agk-dp.fab.redhat.com>
Message-ID: <20101211000720.GB27182@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 30, 2010 at 04:43:37AM +0000, Alasdair G Kergon wrote:
> So that provides an alternative fix I think: add parameter to fmt_from_vgname

I've committed a fix along these lines.

Alasdair


